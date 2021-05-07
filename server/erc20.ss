(import  :std/net/httpd :std/srfi/13 :std/format
         :mukn/gloui/server/process
         :mukn/gloui/server/ftw)
(export #t)
(import :mukn/ethereum/erc20 :mukn/ethereum/ethereum
        :mukn/ethereum/testing :mukn/ethereum/json-rpc
        :clan/persist/db :clan/poo/object :clan/poo/mop
        :mukn/gloui/server/json :std/text/json :clan/decimal
        :gerbil/gambit/threads
        :std/misc/uuid)

(def erc20-contracts
  (map (match <> ([symbol address description]
                  (.o () symbol address description)))
       '(("QASCED" "0xcC0bAe359385e28c37550f28D04A5d26D243E1C8"
          "Quality Assurance Specie on Cardano EVM Devnet")
         ("RBTCED" "0xf9c0d1C68BfA06a4c80A32E391e4231E309e772f"
          "Random Barter Token on Cardano EVM Devnet")
         ;; ("ASS" "0x62Cf950CE51e8f1f8AD8F8a54439c02353d380Fd"
        ;;  "Alice's Special Specie" )
         )))

(def (json<-erc20-contracts)
  (with-output-to-string
    "" (cut write-json (map (cut json<- JSON <>) erc20-contracts))))

(define-json-endpoint erc20-contracts "/erc20/contracts")

(def (erc20-contracts/GET)
  (respond/JSON (json<-erc20-contracts)))

(define-json-endpoint erc20-balance "/erc20/balance")

(def (erc20-balance/POST)
  (def contact (http-request-body-json*))
  (def address (hash-ref contact 'address))
  (error "ADdress" address)
  )

(define-json-endpoint erc20-transfer "/erc20/transfer")

(def (spawn-green fn . args)
  (def uuid (uuid->string (random-uuid)))
  (def out "")
  (def proc (cons [out] #f))
  (hash-put! processes uuid proc)

  (set-cdr!
   proc
   (spawn (lambda () (with-output-to-string out (cut apply fn args)))))
  uuid)

(def (erc20-transfer/POST)
  (def xfer (http-request-body-json*))
  (def from (hash-ref (hash-ref xfer 'from) 'address))
  (def to (hash-ref (hash-ref xfer 'to) 'address))
  (def erc20 (hash-ref (hash-ref xfer 'token) 'address))
  (def sym (hash-ref (hash-ref xfer 'token) 'symbol))
  (def amount
    (* (decimal<-string (hash-ref xfer 'amount)) (expt 10 17)))
  (def nw (hash-ref (hash-ref xfer 'network) 'shortName))
  (def erc20-address (address<-0x erc20))
  (def from-address (address<-0x from))
  (def to-address (address<-0x to))
  (ensure-db-connection "Alice")
  (ensure-ethereum-connection nw)
  (def from-balance (erc20-balance erc20-address from-address))
  (def to-balance (erc20-balance erc20-address to-address))
  (def stdout [(with-output-to-string
                 "" (lambda ()
                      (printf "\nSending ~a tokens from ~a to ~a on ERC20 contract ~a on network ~a...\n"
                              amount from to erc20 nw)
         (printf "Balance for ~a on ERC20 contract ~a before: ~a\n"
                 from sym from-balance)
         (printf "Balance for ~a on ERC20 contract ~a before: ~a\n"
                 to sym to-balance)))])

  (def uuid
    (spawn-green
     (lambda ()
       (erc20-transfer erc20-address from-address to-address amount)
       (printf "Balance for ~a on ERC20 contract ~a after: ~a\n"
               from erc20 (erc20-balance erc20-address from-address))
       (printf "Balance for ~a on ERC20 contract ~a after: ~a\n"
               to erc20 (erc20-balance erc20-address to-address)))))
  (set-car! (hash-ref processes uuid) stdout)
  (def json (json<-process-properties uuid))

  (respond/JSON json))
