(export #t)
(import :std/text/json :std/srfi/13
        (only-in :gerbil/gambit shell-command display-exception)
        (only-in :gerbil/gambit/random random-integer)
        :std/misc/uuid :std/misc/process
        :gerbil/gambit/threads
        :gerbil/gambit/ports
        :std/misc/ports :std/srfi/1)
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
                ((waiting) #!void ;(thread-state-waiting-for tstate)
                 )
                ((abnormally-terminated)
                 (with-output-to-string
                   "" (cut display-exception (thread-state-abnormally-terminated-reason tstate)
                                         (current-output-port))))
                ((normally-terminataed) #t
                 ;(thread-state-normally-terminated-result tstate)
                 )))
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
