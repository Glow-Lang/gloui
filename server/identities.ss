(import :mukn/glow/cli/identities :mukn/ethereum/known-addresses
        :mukn/gloui/server/json  :mukn/ethereum/ethereum
        :mukn/gloui/server/ftw
        :mukn/ethereum/testing :std/text/json
        (only-in :gerbil/gambit/random random-integer)
        :clan/poo/mop :clan/poo/brace :clan/poo/object)
(export #t)

(def (random-tags)
  (def tags  [["foo" "bar" "send" "rps"]
              ["bar" "moonshine" "send"]
              ["foo" "moonshine" "rps"]])
  (list-ref tags (random-integer (length tags))))

(def (json<-list-identities from: (from #f))
  (def ids
    (map (match <> ([name . kp] (list name (0x<-address (keypair-address kp))
                                      (random-tags))))
         (hash->list (load-identities from: from))))
  (def jsos (map (match <> ([name address tags]
                            (json<- JSON
                             (.o () name address tags))))
                 ids))
  (def testjsos [(json<- JSON { name: "Alice" address: (0x<-address alice)
                                tags: (cons "ERC20" (random-tags))
                               })
                 (json<- JSON { name: "Bob" address: (0x<-address bob)
                                tags: (cons "ERC20" (random-tags))
                               })
                 (json<- JSON { name: "Trent" address: (0x<-address trent)
                                tags: (cons "ERC20" (random-tags))
                               })
                 (json<- JSON { name: "Croesus" address: (0x<-address croesus)
                                tags: (cons "ERC20" (random-tags))
                               })])
  (with-output-to-string "" (cut write-json (append testjsos jsos))))


(define-endpoint list-identities "/list-identities")

(def (list-identities/GET)
  (respond/JSON (json<-list-identities)))
