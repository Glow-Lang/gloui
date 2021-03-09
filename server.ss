(import :drewc/ftw :std/text/json :std/srfi/13
        (only-in :gerbil/gambit shell-command display-exception)
        (only-in :gerbil/gambit/random random-integer)
        :std/misc/uuid :std/misc/process :gerbil/gambit/threads :gerbil/gambit/ports :std/misc/ports :std/srfi/1)

(export #t)

(def server-address "0.0.0.0:6741")
(def server-url (string-append "http://" server-address))

(def ftw-httpd #f)

(def (start-server! (restart? #f))
  (if (and ftw-httpd (not restart?)) ftw-httpd
      (begin
        (when ftw-httpd (stop-ftw-http-server! ftw-httpd))
        (set! ftw-httpd (start-ftw-http-server! server-address))))
  ftw-httpd)

(def processes (make-hash-table))

(def (read-process-lines process (setter (lambda (ls) (display ls))))
  (input-port-timeout-set! process -inf.0)
  (let rl ((go? #t))
    (setter (read-all-as-lines process))
    (when go?
      (if (not (process-status process 0 #f))
        (begin (thread-sleep! 1) (rl []))
        (rl #f)))))

(def (spawn-process fn . args)
  (def uuid (uuid->string (random-uuid)))
  (def proc (cons [] #f))
  (hash-put! processes uuid proc)

  (set-cdr!
   proc
   (spawn run-process
          [fn args ...]
          coprocess: (cut read-process-lines
                          <> (lambda (ls) (set-car! proc (append (car proc) ls))))
          pseudo-terminal: #t))
  uuid)

(def (thread-properties thread)
  (def tstate (thread-state thread))
  (def state (cond ((thread-state-running? tstate) 'running)
                   ((thread-state-waiting? tstate) 'waiting)
                   ((thread-state-abnormally-terminated? tstate) 'abnormally-terminated)
                   ((thread-state-normally-terminated? tstate) 'normally-terminated)))
  (def result (case state
                ((running) #t)
                ((waiting) (thread-state-waiting-for tstate))
                ((abnormally-terminated)
                 (with-output-to-string
                   "" (cut display-exception (thread-state-abnormally-terminated-reason tstate)
                                         (current-output-port))))
                ((normally-terminataed) (thread-state-normally-terminated-result tstate))))
  [["state" . state]
   ["result" . result]])

(def (uuid->process-properties uuid)
  (def proc (hash-get processes uuid))
  (match proc
    ([stdout . thread]
     (let ((threadp (thread-properties thread)))
       [["uuid" . uuid]
        ["thread" (list->hash-table threadp) ...]
        ["output" . stdout]]))))

(def (json<-process-properties uuid)
  (with-output-to-string "" (cut write-json (list->hash-table (uuid->process-properties uuid)))))

(def (random-tags)
  (def tags  [["foo" "bar" "send" "rps"]
              ["bar" "moonshine" "send"]
              ["foo" "moonshine" "rps"]])
  (list-ref tags (random-integer (length tags))))

(def (glow-find-identities)
  (def idstr (cdr (shell-command "env --unset=GERBIL_HOME glow list-identities" #t)))
  (def (ids) (let l ()
             (let ((ln (read-line)))
               (if (eof-object? ln) []
                   [ln (l) ...]))))
  (map (lambda (line)
         (let* ((nh (string-split line #\[))
                (name (string-trim-right (car nh)))
                (hash (string-trim-right (string-trim (car (string-split (cadr nh) #\]))))))
           [["name" . name ]
            ["hash" . hash]
            ["tags" (random-tags) ...]]))
       (with-input-from-string idstr ids)))

(def (glow-list-contacts)
  (def idstr (cdr (shell-command "env --unset=GERBIL_HOME glow list-contacts" #t)))
  (def (ids) (let l ()
             (let ((ln (read-line)))
               (if (eof-object? ln) []
                   [ln (l) ...]))))
  (map (lambda (line)
         (let* ((nh (string-split line #\[))
                (name (string-trim-right (car nh)))
                (hash (string-trim-right (string-trim (car (string-split (cadr nh) #\]))))))
           [["name" . name ]
            ["hash" . hash]
            ["tags" (random-tags) ...]]))
       (with-input-from-string idstr ids)))

(def (glow-list-evm-networks)
  (def evmstr (cdr (shell-command "env --unset=GERBIL_HOME glow list-evm-networks" #t)))
  (def evms (call-with-input-string evmstr read-all-as-lines))
  (map (lambda (line)
         (let* ((n (string-split line #\space))
                (n (list (car n) (list-ref n (- (length n) 1))
                         (string-join (remove (cut string=? "" <>) (drop-right (cdr n) 1)) " "))))
           (match n ([sym url name]
                     [["name" . name ]
                      ["symbol" . sym]
                      ["url"  . url]]))))
           evms))

(def (glow-meta)
  (def str (cdr (shell-command "env --unset=GERBIL_HOME glow meta" #t)))
  (def meta (string-split str #\space))
  (map string-trim-right meta))
(def (glow-version)
  (def str (cdr (shell-command "env --unset=GERBIL_HOME glow version" #t)))
  (string-trim-right str))

(def (json<-glow-find-identities)
  (with-output-to-string "" (cut write-json (map list->hash-table (glow-find-identities)))))

(def (json<-glow-homepage)
  (def ids (map list->hash-table (glow-find-identities)))
  (def cs (map list->hash-table (glow-list-contacts)))
  (def ns (map list->hash-table (glow-list-evm-networks)))
  (def meta (glow-meta))
  (def version (glow-version))
  (with-output-to-string
    "" (cut write-json (list->hash-table
                        [["version" . version ]
                         ["meta" . meta]
                         ["identities" . ids]
                         ["contacts" . cs ]
                         ["networks" . ns]]))))

(def (json/OPTIONS)
  (let (o (assget "Origin" (http-request-headers*)))
    (http-response-write*
     200 `(("Access-Control-Allow-Origin" . ,(or o "*"))
           ("Access-Control-Allow-Credentials" . "true")
           ("Access-Control-Allow-Methods" . "POST, GET, OPTIONS")
           ("Access-Control-Allow-Headers" . "Content-Type"))
     #f)))

(defsyntax (define-json-endpoint stx)
  (syntax-case stx ()
   ((macro name loc)
    (with-syntax ((opt (datum->syntax #'macro (string->symbol
                        (string-append (symbol->string (syntax->datum #'name))
                                       "/OPTIONS")))))
      #'(begin (def opt json/OPTIONS)
               (define-endpoint name loc))))))

(def (respond/json code: (code 200) json)
  (let ((o (assget "Origin" (http-request-headers*)))
        (js (if (not (string? json))
              (json-object->string json)
              json)))
    (http-response-write* code `(("Content-Type" . "application/json")
                                 ("Access-Control-Allow-Origin" . ,(or o "*"))
                                 ("Access-Control-Allow-Credentials" . "true"))
                          js)))

(def (http-request-body-json*)
  (with-input-from-u8vector (http-request-body*) read-json))

(define-endpoint list-identities "list-identities")

(def (list-identities/GET)
  (respond/json (json<-glow-find-identities)))

(define-endpoint default list priority: +inf.0)
(def (default/GET req)
  (respond/json (json<-glow-homepage)))

(define-json-endpoint transfer "transfer")

(def (transfer/POST)
  (let* ((transfer (http-request-body-json*))
         (to (hash-get transfer 'to))
         (from (hash-get transfer 'from))
         (amount (hash-get transfer 'amount))
         (net (hash-get transfer 'network))
         (cmd
          ["glow" "transfer"
           "--to" (hash-get to 'name)
           "--from" (hash-get from 'name)
           "--value" amount
           "--evm-network" (hash-get net 'symbol)])
         (uuid (apply spawn-process cmd))
         (json (json<-process-properties uuid)))
   ; (error (table->list transfer))
    (respond/json json)))

(define-json-endpoint process "process")
(def (process/POST)
  (let* ((proc (http-request-body-json*))
         (uuid (hash-get proc 'uuid)))
    (respond/json (json<-process-properties uuid))))
