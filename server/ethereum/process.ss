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
        ./network
        ./balance)

(def process-functions (make-hash-table))

(def (tranfer-process-function tran)
  (def type (ref (.@ tran resource) 'type))
  (def fn (ref process-functions type))
  (cut fn tran))

(def (native-transfer tran)
  (cli-send-tx tran confirmations: 0))

(hash-put! process-functions "Native" native-transfer)
