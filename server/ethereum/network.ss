
(export #t)

(import  :std/net/httpd :std/srfi/13 :std/format :std/text/json
         :mukn/gloui/server/process :std/ref :std/sugar
         :mukn/gloui/server/ftw (only-in :gerbil/gambit open-string))
(import :mukn/ethereum/cli :mukn/ethereum/ethereum
        :mukn/ethereum/assets
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
        :clan/poo/io :std/logger)

(def (with-network net thunk)
  (parameterize ((current-ethereum-network (current-ethereum-network)))
    (ensure-ethereum-connection net)
    (thunk)))
