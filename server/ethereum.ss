(import  :std/net/httpd :std/srfi/13 :std/format :std/text/json
         :mukn/gloui/server/process :std/ref :std/sugar
         :mukn/gloui/server/ftw (only-in :gerbil/gambit open-string))
(export #t)
(import :mukn/ethereum/cli :mukn/ethereum/ethereum
        :mukn/ethereum/assets
        :mukn/ethereum/pet-contracts
        :mukn/ethereum/testing :mukn/ethereum/json-rpc
        :mukn/ethereum/network-config
        :mukn/ethereum/types
        :clan/persist/db :clan/poo/object
        :mukn/ethereum/known-addresses
        :mukn/glow/cli/identities
        :clan/poo/brace
        :mukn/gloui/server/json :std/text/json :clan/decimal
        :gerbil/gambit/threads
        :std/misc/uuid :clan/crypto/secp256k1 :std/text/hex
        :clan/poo/io :std/logger
        )

#;(begin
  (register-test-keys)
  (def drewc "0x72Ab1A268DeD7fE3c6cA81caFF268E41796Ed1E9")
  (def alice "0x94314828752f41550F8E40d3C454747A1EDD0eA3")
  (def croesus "0x25c0bb1A5203AF87869951AEf7cF3FEdD8E330fC"
    ;; (address<-nickname "t/croesus")
    )

  (def trans (make-transfer "pet" drewc alice "0.42"))
  (def inval (make-transfer "pet" drewc alice "100.42"))
  (def faucet (make-transfer "pet" croesus drewc "5")))

#;(def alice { address: "0x94314828752f41550F8E40d3C454747A1EDD0eA3"
             key: "

0x3ad24210623d9d71e1c4667f5e9ecd749f5da2cf118a60f54790f7a77011b1bb

"})
 (extern (display-exception display-exception))

(def (with-JSON-catch thunk)
  (try (thunk)
       (catch (e)
         (let ((str (with-output-to-string "" (cut display-exception e))))
           (debug str)
           (respond/JSON code: 500 str)))))

(def (ensure-address ?) (if (not (string? ?)) ? (parse-address ?)))

(def (keypair<-private-key 0x)
  (keypair<-secret-key (<-string Bytes32 0x)))

(def (address<-private-key 0x)
  (keypair-address (keypair<-private-key 0x)))

(def (string<-secret-key k)
  (hex-encode (secp256k1-seckey-data k)))

(define-json-endpoint address-from-identity "/eth/address-from-identity")

(def (address-from-identity/POST)
  (def (giver)
    (def id (http-request-body-json*))
    (def pk (ref id 'key))
    (def 0x (0x<-address (address<-private-key pk)))
    (respond/JSON 0x))
  (with-JSON-catch giver))

(def baz #f)

(def (make-transfer net from to amount)
  (def fromTable from)
  (def fromName (ref from 'owner 'name))
  (def sec (try (ref from 'address 'secret)
                (catch (e) (error "From: Address does not have a secret key"))))
  (def from0x (try (ref from 'address 'number)
                   (catch (e) (error "From: Address does not have a number"))))

  (def keypair (keypair<-private-key sec))

  (set! from (ensure-address from0x))

  (set! to (ensure-address to))
  (set! amount (if (number? amount)
                 (number->string amount)
                 amount))
  (def currency (.@ (ethereum-config) nativeCurrency))
  (def value (parse-currency-value amount currency))

  { net to from amount currency value fromName
    wrapper: (lambda (thunk)
               (register-keypair fromName keypair)
               (try (thunk)
                    (finally (unregister-keypair fromName))))
    openBalance: #f
    closeBalance: #f
    process: #f
    outputString: ""
    errorString: ""
    error: #f })

(def (with-transfer t thunk)
  ((.@ t wrapper) thunk))

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
    (with-transfer
     tran
     (cut cli-send-tx tran confirmations: 0)))
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
    (begin0
        (if (not (valid-transfer? tran))
          (invalid-transfer "From account does not have enough")
          (start-transfer-process! tran out err))))

    (parameterize ((current-output-port out)
                   (current-error-port err))
      (with-network net proc)))

(def (json<-transfer tran)
  (def net (.@ tran net))
  (def error (if (equal? (transfer-process-state tran) "error")
              #t
               #f))

  (def proc (.@ tran process))
  (def t (if proc (.@ proc thread) #f))

  (def errorMessage (if (or (not t)
                            (not (thread-state-abnormally-terminated?
                             (thread-state t))))
                      #f
                      (with-output-to-string
                        ""
                        (cut display-exception
                       (thread-state-abnormally-terminated-reason
                       (thread-state t))))))

  ; (def ttstate (thread-state transfer-thread))


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
                ["errorMessage" errorMessage ...]
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
  ;; {
  ;;  "id":"5d0f23de-d758-46ee-8b6b-58dd5fe792df",
  ;;  "assets":[ {"from":{
  ;;                      "owner": {"id":"17985a9d-1c29-4a2f-97ae-f01efb9020c6","name":"Thor Therdhal","description":"WCFC!!"},
  ;;                      "address":{"secret":"0x3ad24210623d9d71e1c4667f5e9ecd749f5da2cf118a60f54790f7a77011b1bb",
  ;;                                 "number":"0x94314828752f41550F8E40d3C454747A1EDD0eA3",
  ;;                                 "label":"This is working well",
  ;;                                 "id":"a31fb8d8-ad25-45c9-8f47-970b6b9e95d1"}},
  ;;              "to":{"owner":{"name":"adzv31tqea","description":"dfqegds","id":"de981cf7-46d5-4f1c-b7c4-a2bec65ab088"},
  ;;                    "address":{"secret":"0x3ad24210623d9d71e1c4667f5e9ecd749f5da2cf118a60f54790f7a77011b1bb",
  ;;                               "number":"0x94314828752f41550F8E40d3C454747A1EDD0eA3",
  ;;                               "label":"Test","id":"f1db5d00-119a-44d6-b22e-3b8d57bfaf94"}
  ;;                    },
  ;;              "amount":"12",
  ;;              "network":"pet"}
  ;;             ]}
  (def net (ref trans 'network))
  (def from (ref trans 'from))

  (def to (ref trans 'to 'address 'number))
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
  (def t (.@ tranny thread))
  (def errorMessage (if (not(thread-state-abnormally-terminated?
                             (thread-state t)))
                      #f
                      (display-exception
                       (thread-state-abnormally-terminated-reason
                       (thread-state t)))))
  (list->hash-table
   [ [ "id" (.@ tranny id) ... ]
     [ "transfers" (map json<-transfer (.@ tranny transfers)) ... ]
     [ "state" (transaction-state tranny) ... ]
     [ "errorMessage" errorMessage ... ]
     [ "remaining" (.@ tranny remaining) ... ]
     ]))


(def transactions (make-hash-table))

(define-json-endpoint eth-transfer "/eth/transfer")

(def (eth-transfer/GET)
  (def (tget)
    (def id (GET-parameter* "id"))
    (def tranny (hash-get transactions id))
    (def jso (and tranny (json<-transaction tranny)))
    (respond/JSON jso))

  (with-JSON-catch tget))

(def (eth-transfer/POST)
  (def (tfer)
    (ensure-db-connection "Live")
                                        ;  (load-identities)
                                        ; (register-test-keys)
    (def jbody (http-request-body-json*))
    (def tranny (make-transaction-from-POST jbody))
    (hash-put! transactions (.@ tranny id) tranny)
    (process-transaction! tranny)
    (respond/JSON (json<-transaction tranny)))

  (with-JSON-catch tfer)
  ;(tfer)
  )
