(import  :std/net/httpd :std/srfi/13 :std/format :std/text/json
         :mukn/gloui/server/process :std/ref :std/sugar
         :mukn/gloui/server/ftw (only-in :gerbil/gambit open-string))
(export #t)
(import :mukn/ethereum/cli :mukn/ethereum/ethereum
        :mukn/ethereum/testing :mukn/ethereum/json-rpc
        :mukn/ethereum/network-config :mukn/ethereum/types
        :clan/persist/db :clan/poo/object
        :mukn/ethereum/known-addresses
        :mukn/glow/cli/identities
        :clan/poo/brace
        :mukn/gloui/server/json :std/text/json :clan/decimal
        :gerbil/gambit/threads
        :std/misc/uuid)

(begin
  (register-test-keys)
  (def drewc "0x72Ab1A268DeD7fE3c6cA81caFF268E41796Ed1E9")
  (def alice "0x94314828752f41550F8E40d3C454747A1EDD0eA3")
  (def croesus "0x25c0bb1A5203AF87869951AEf7cF3FEdD8E330fC"
    #;(address<-nickname "t/croesus"))

  (def trans (make-transfer "pet" drewc alice "0.42"))
  (def inval (make-transfer "pet" drewc alice "100.42"))
  (def faucet (make-transfer "pet" croesus drewc "5")))


(def (ensure-address ?) (if (not (string? ?)) ? (parse-address ?)))


(def (make-transfer net from to amount)
  (set! to (ensure-address to))
  (set! from (ensure-address from))
  (set! amount (if (number? amount)
                 (number->string amount)
                 amount))
  (def currency (.@ (ethereum-config) nativeCurrency))
  (def value (parse-currency-value amount currency))
  { net to from amount currency value
    openBalance: #f
    closeBalance: #f
    process: #f
    outputString: ""
    errorString: ""
    error: #f })

(def (transfer-value tran) (.@ tran value))


(def (get-balance a) (eth_getBalance (ensure-address a)))

(def (transfer-balance tran)
  (def from (get-balance (.@ tran from)))
  (def to (get-balance (.@ tran to)))
  { from to })

(def (with-network net thunk)
  (parameterize ((current-ethereum-network #f))
    (ensure-ethereum-connection net)
    (thunk)))

(def (start-transfer-process! tran out err)
  (def (proc out err)
      (cli-send-tx tran confirmations: 0))
  (let ((thread (thread-start! (make-thread (cut proc out err)))))
    (set! (.@ tran process) { out err thread })
    tran))

(def (transfer-process-state tran)
  (def proc (.@ tran process))
  (if (and (not proc) (not (.@ tran error))) #!void
      (if (.@ tran error) "error"
      (let ((t (thread-state (.@ proc thread))))
        (cond
         ((thread-state-running? t) "running")
         ((thread-state-waiting? t) "waiting")
         ((thread-state-normally-terminated? t) "finished")
         ((or (thread-state-abnormally-terminated? t)
              (.@ tran error)) "error")
         (else "unknown"))))))

(def (transfer-process-output tran)
  (def proc (.@ tran process))
  (def out (or (and proc (.@ proc out))
               (open-string)))
  (def str (.@ tran outputString))
  (def newOut (string-append str (get-output-string out)))
  (set! (.@ tran outputString) newOut)
  newOut)

(def (transfer-process-error-output tran)
  (def proc (.@ tran process))
  (def out (or (and proc (.@ proc err))
               (open-string)))
  (def str (.@ tran errorString))
  (def newOut (string-append str (get-output-string out)))
  (set! (.@ tran outputString) newOut)
  newOut)

(def (transfer-open-balance tran)
  (def bal (.@ tran openBalance))
  (or bal (let ((bal (transfer-balance tran)))
            (set! (.@ tran openBalance) bal)
            bal)))
(def (transfer-close-balance tran)
  (def bal (.@ tran closeBalance))
  (def state (transfer-process-state tran))
  (if (not (equal? state "finished")) bal
      (or bal (let ((bal (transfer-balance tran)))
                (set! (.@ tran closeBalance) bal)
                bal))))

(def (valid-transfer? tran)
  (def fromBal (.@ (transfer-open-balance tran) from))
  (def val (transfer-value tran))
  (< val fromBal))

(def (amount<-value value)
  (decimal-string-ether<-wei value))

(def (process-transfer! tran)
  (def net (.@ tran net))
  (def out (open-string))
  (def err (open-string))
  (def (invalid-transfer reason)
    (set! (.@ tran error) #t)
    (set! (.@ tran errorString) reason)
    tran)
  (def (proc)
    (if (not (valid-transfer? tran))
      (invalid-transfer "From account does not have enough")
      (start-transfer-process! tran out err)))

    (parameterize ((current-output-port out)
                   (current-error-port err))
      (with-network net proc)))

(def (json<-transfer tran)
  (def net (.@ tran net))
  (def error (if (equal? (transfer-process-state tran) "error")
               (transfer-process-error-output tran)
               #f))
  (def openBal (with-network net (cut transfer-open-balance tran)))
  (def closeBal (with-network net (cut transfer-close-balance tran)))
  (with-network net (cut list->hash-table [
                ["net" net ...]
                ["from" (0x<-address(.@ tran from)) ...]
                ["to" (0x<-address(.@ tran to)) ...]
                ["currency" (.@ tran currency symbol) ...]
                ["amount" (.@ tran amount) ...]
                ["state" (transfer-process-state tran) ...]
                ["error" error ...]
                ["openBalance"
                 (list->hash-table [[ "from" (amount<-value (.@ openBal from)) ...]
                               [ "to" (amount<-value (.@ openBal to)) ...]])
                 ...]
                ["closeBalance" (if (not closeBal) closeBal
                                    (list->hash-table [[ "from" (amount<-value (.@ closeBal from)) ...]
                                             [ "to" (amount<-value (.@ closeBal to)) ...]]))
                 ...]

                ])))

(def (transfer<-json-POST trans)
  (def net (ref trans 'from 'resource 'network))
  (def from (ref trans 'from 'resource 'path))
  (def to (ref trans 'to 'resource 'path))
  (def amount (ref trans 'amount))
  (with-network net (cut make-transfer net from to amount)))

(def (make-transaction-from-POST tranny)
  (def assets (ref tranny 'assets))
  (def transfers (map transfer<-json-POST assets))
  (def id (ref tranny 'id))

  { id transfers
    remaining: (length transfers)
    thread: #f } )

(def (process-transaction! tranny)
  (def (proc)
    (let ptran ((trans (.@ tranny transfers)))
      (def tran (car trans))
      (process-transfer! tran)
      (thread-join! (.@ tran process thread))
      (def rem (.@ tranny remaining))
      (set! (.@ tranny remaining) (- rem 1))
      (if (null? (cdr trans)) #t
          (ptran (cdr trans)))))

  (def thread (thread-start! (make-thread proc)))

  (set! (.@ tranny thread) thread)
  tranny)

(def (transaction-state tranny)
  (def fers (.@ tranny transfers))
  (def rem (.@ tranny remaining))
  (def num (- (length fers) (if (zero? rem) 1 rem)))
  (def fer (ref fers num))
  (def st (transfer-process-state fer))

  (if (void? st) "starting" st))

(def (json<-transaction tranny)
  (list->hash-table
   [ [ "id" (.@ tranny id) ... ]
     [ "transfers" (map json<-transfer (.@ tranny transfers)) ... ]
     [ "state" (transaction-state tranny) ... ]
     [ "remaining" (.@ tranny remaining) ... ]
     ]))


(def transactions (make-hash-table))

(define-json-endpoint eth-transfer "/eth/transfer")

(def (eth-transfer/GET)
  (def id (GET-parameter* "id"))
  (def tranny (hash-get transactions id))
  ;(ensure-ethereum-connection "pet")
  (respond/JSON (and tranny (json<-transaction tranny))))

(def foo #f)
(def (eth-transfer/POST)
  (ensure-db-connection "userdb")
  (load-identities)
  (def jbody (http-request-body-json*))
  (def tranny (make-transaction-from-POST jbody))
  (hash-put! transactions (.@ tranny id) tranny)

  (set! foo tranny)

  (process-transaction! tranny)

  (respond/JSON (json<-transaction tranny) ))
