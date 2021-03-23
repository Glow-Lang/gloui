(import :mukn/glow/cli/contacts :mukn/ethereum/known-addresses
        :mukn/gloui/server/json  :mukn/ethereum/ethereum
        :mukn/ethereum/testing :std/text/json
        :mukn/gloui/server/ftw
        (only-in :gerbil/gambit/random random-integer)
        :clan/poo/mop :clan/poo/brace :clan/poo/object)
(export #t)
(def (crandom-tags)
  (def tags  [["foo" "bar" "send" "rps"]
              ["bar" "moonshine" "send"]
              ["foo" "moonshine" "rps"]])
  (list-ref tags (random-integer (length tags))))

(def (json<-list-contacts (file #f))
  (def ids
    (map (match <> ([name . c] (list name (0x<-address (.@ c address))
                                     (crandom-tags))))
         (hash->list (load-contacts file))))
  (def jsos (map (match <> ([name address tags]
                            (json<- JSON
                             (.o () name address tags))))
                 ids))
  (def testjsos [(json<- JSON { name: "Alice" address: (0x<-address alice)
                                tags: (cons "ERC20" (crandom-tags))
                               })
                 (json<- JSON { name: "Bob" address: (0x<-address bob)
                                tags: (cons "ERC20" (crandom-tags))
                               })
                 (json<- JSON { name: "Trent" address: (0x<-address trent)
                                tags: (cons "ERC20" (crandom-tags))
                               })
                 (json<- JSON { name: "Croesus" address: (0x<-address croesus)
                                tags: (cons "ERC20" (crandom-tags))
                               })])
  (with-output-to-string "" (cut write-json (append testjsos jsos))))


(define-endpoint list-contacts "/list-contacts")

(def (list-contacts/GET)
  (respond/JSON (json<-list-contacts)))
