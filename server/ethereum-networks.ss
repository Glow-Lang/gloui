(import :mukn/ethereum/network-config :mukn/gloui/server/json
        :mukn/gloui/server/ftw
        :clan/poo/object :clan/poo/mop :std/text/json :std/sugar)
(export #t)

(def (distinct-evm-networks)
  (def dnws (make-hash-table))
  (filter-map (match <>
                 ([_ . o]
                  (let ((n (.@ o network)))
                    (if (hash-ref dnws n #f)
                      #f
                      (begin (hash-put! dnws n #t) o)))))
               (hash->list ethereum-networks)))

(def (json<-list-evm-networks)
  (def nws (map (lambda (o)
                  (json<- JSON
                          (.o ()
                              name: (.@ o name)
                              shortName: (.@ o shortName)
                              network: (.@ o network)
                              chain: (.@ o chain)
                              description: (try (.@ o description)
                                                         (catch _ #f)))))
                (distinct-evm-networks)))
  (with-output-to-string "" (cut write-json nws)))


(define-endpoint list-evm-networks "/list-evm-networks")

(def (list-evm-networks/GET)
  (respond/JSON (json<-list-evm-networks)))
