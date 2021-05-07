(import  :std/net/httpd :std/srfi/13 :std/format
          :std/ref)
(export #t)
(import :mukn/ethereum/erc20 :mukn/ethereum/ethereum
        :mukn/ethereum/testing :mukn/ethereum/json-rpc
        :clan/persist/db :clan/poo/object :clan/poo/mop
        :mukn/gloui/server/json :std/text/json :clan/decimal
        :gerbil/gambit/threads
        :std/misc/uuid)

(import ./network ./balance ./process)

(def (address-resource-erc20-balance address resource)
  (def net (ref resource 'network))
  (def erc20-address (ensure-address (ref resource 'address)))
  (def from-address (ensure-address address))
  (with-network net (cut erc20-balance erc20-address from-address)))

(hash-put! balance-functions "ERC20" address-resource-erc20-balance)

(def (erc20-transfer-process tran)
  (def resource (.@ tran resource))
  (def erc20-address (ensure-address (ref resource 'address)))
  (def from-address (ensure-address (.@ tran from)))
  (def to-address (ensure-address (.@ tran to)))
  (def amount (.@ tran value))
  (erc20-transfer erc20-address from-address to-address amount))


(hash-put! process-functions "ERC20" erc20-transfer-process)
