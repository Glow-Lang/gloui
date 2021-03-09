(import :js)

;; (def (on-click ctr)
;;   (js#jso
;;    click: (lambda _
;;             (js#statement "console.log('counter:', (@1@), 'change this')" (js#jso-ref ctr count:))
;;             (js#++ (js#jso-ref ctr count:)))))
(js#declaration "const Quasar = require ('quasar');")


(def q-select (js#js->foreign (js#expression "Quasar.QSelect;")))
(def q-inner-loading (js#js->foreign (js#expression "Quasar.QInnerLoading;")))
(def q-spinner-gears (js#js->foreign (js#expression "Quasar.QSpinnerGears;")))

(def (v-model-input this)
  (lambda (e)
    (js#statement "(@1@).$emit('input', (@2@))"
                  (if (foreign? this) (js#foreign->js this) this)
                    (js#scm->js e))))

(def (ensure-scheme-book book)
  (if (and (< 0 (vector-length book))
           (not (foreign? (vector-ref book 0))))
    (vector-map js#js->foreign book)
    book))

(def (filter-book-name-starts-with book starts-with)
  (if starts-with
    (vector-filter
     (lambda (i)
       (string-prefix-ci? starts-with (js#jso-ref i name:)))
     book)
    book))

(def (filter-book this (name-starts-with #f))
  (def newbook (let ((book (js#jso-ref this book:))
                     (tags (js#jso-ref this tags:)))
                 (filter-book-name-starts-with
                  (if (not (js#undefined? tags))
                    (filter-book-using-tags book tags)
                    book)
                  name-starts-with)))
    (js#stmt "console.log('filter-book', (@1@))" this)
  (if (and (< 0 (vector-length newbook))
           (not (foreign? (vector-ref newbook 0))))
    (js#js->scm newbook)
    newbook))

#;(def (filter-book-fn this)
  (js#function (val update _)
    (js#stmt "console.log('filterng', (@1@))" this)
    (update (lambda ()
              (set! (js#jso-ref this filtered-book:)
                (filter-book this val))))))

;;; Add to runtime

(def (round num) (js#js->scm "Math.round(@1@)" (js#scm->js num)))

(def (filter pred lst)
  (cond ((null? lst) '())
        ((pred (car lst))
         (cons (car lst) (filter pred (cdr lst))))
        (else (filter pred (cdr lst)))))

(def (vector-filter pred vec)
  (##list->vector (filter pred (vector->list vec))))

(def (string= ci: (ci #f) s1 s2 (start1 0) (end1 #f) (start2 0) (end2 #f))
  (if (or (not (string? s1))
          (not (string? s2)))
    #f
    (begin
      (unless end1 (set! end1 (string-length s1)))
      (unless end2 (set! end2 (string-length s2)))
      ))

  (js#expression "((s1, s2) => {
 if (@7@) {
  s1 = RTS.host2scm(s1.toString().toLowerCase().toUpperCase());
  s2 = RTS.host2scm(s2.toString().toLowerCase().toUpperCase());
 }
 let v1 = s1.codes.slice((@1@), (@2@));
 let v2 = s2.codes.slice((@3@), (@4@));


 if (v2.length !== v1.length) { return false };

  for(let i = 0 ; i < v1.length ; i++) {

  if (v1[i] !== v2[i]) { return false }
 }

 return true;

})((@5@), (@6@));"
                 start1 end1 start2 end2 s1 s2 ci))

(def (string-prefix-ci? s1 s2)
  ;; SRFI 13
  ;;; Is s1 a prefix/suffix of s2?
  (string= ci: #t s2 s1 0 (string-length s1)))

(def (string-prefix=? str prefix)
  (string= str prefix 0 (string-length prefix)))

(def address-select
  (lambda (resolve _)
    (resolve
     (js#jso
      name: "AddressSelect"
      props: { "value" {}
               tags: { default: #() }
               "new-value-mode" {}
               "book" {}
               label: { default: "Select Address" } }
      data: (lambda _ { filtered-book: #f scheme-book: #f})
      components: { q-select: q-select }
      render:
      (js#function (h)
        (def self js#this)
        (def book (js#jso-ref self book:))
        (def val (js#jso-ref self value:))
        (def new? (js#jso-ref self new-value-mode:))
        (def label (js#jso-ref self label:))
        (def b (js#jso-ref self scheme-book:))
        (def fb (js#jso-ref self filtered-book:))
        (unless (js#undefined? book)

          (js#stmt "console.log('render-book', @1@)" (js#ref self book:))
          (unless fb (set! fb (filter-book self)))
          (h "q-select"
           { props: { use-chips: #t
                      filled: #t
                      use-input: #t
                      options: fb
                      value: val
                      new-value-mode: new?
                      label: label
                      input-debounce: 0 }
            on: { input: (v-model-input js#this)
                  filter:  (lambda  (val update _)
                             (set! fb (filter-book self val))
                             (update (lambda ()
                                       (set! (js#jso-ref self filtered-book:) fb)
                                       #t)
))}})))))))


 ;; const amountOptions = ['All at From: Address']
 ;; <q-select
 ;; filled v-model="amount" label="Amount" :options="amountOptions"
 ;; use-input
 ;; use-chips
 ;; new-value-mode="add"
 ;; />


(def amount
  (lambda (go _)
    (go
    { name: "Amount"
      components: { q-select: q-select }
      props: { value: {}
               options: { default: (lambda _ ["All at From: Address"]) }
               label: { default: "Amount" }}
      render: (js#function (h)
                (h "q-select"
                   { props: { filled: #t use-input: #t use-chips: #t
                              new-value-mode: "add"
                              value: (js#jso-ref js#this value:)
                              options: (js#jso-ref js#this options:)
                              label: (js#jso-ref js#this label:)}
                     on: { input: (v-model-input js#this) }}))})))
(def (asset go _)
  (go { name: "Asset"
        components: { q-select: q-select }
        props: { value: {}
                 options: { default: (lambda _ ["Native Token" "Moonshine" "CAD"]) }
                 label: { default: "Asset" }}
      render: (js#function (h)  (h "q-select"
                   { props: { filled: #t
                              value: (js#jso-ref js#this value:)
                              options: (js#jso-ref js#this options:)
                              label: (js#jso-ref js#this label:)}
                     on: { input: (v-model-input js#this) }}))
        })
  )
(def (target go _)
  (go { name: "Target"
        components: { q-select: q-select }
        props: { value: {}
                 options: { default: (lambda _ ["CAD"]) }
                 label: { default: "Target (fiat)" }}
      render: (js#function (h)  (h "q-select"
                   { props: { filled: #t
                              value: (js#jso-ref js#this value:)
                              options: (js#jso-ref js#this options:)
                              label: (js#jso-ref js#this label:)}
                     on: { input: (v-model-input js#this) }}))
        })
  )
(def (exchange-rate go _)
  (go { name: "ExchangeRate"
       components: { q-inner-loading: q-inner-loading q-spinner-gears: q-spinner-gears }
        props: { value: {}
                 target: {}
                 asset: {}
                 label: { default: "Target (fiat)" }}
        data: (lambda _
                { loading: #f live: #f curr: 0 target-symbol: "" token-symbol: "" } )
      render: (js#function (h)
                (def val (js#jso-ref js#this value:))
                (def curr (js#jso-ref js#this curr:))
                (def token (js#jso-ref js#this asset:))
                (def token-symbol (js#jso-ref token symbol:))
                (def fiat (js#jso-ref js#this target:))

                (unless (number? val)
                  (set! val (js#js->scm
                             (js#expr "(() => { try { return Number(@1@) } catch (e) {  return (@1@) }})();"
                                      (js#scm->js val)))))

                (js#stmt "console.warn('Excnage', Number(@1@), @2@, @3@)" val token fiat)

                (when (and (number? val) (> val 0))

                  (when (or (not (= val
                                    (js#jso-ref js#this curr:)))
                            (not (string= token-symbol (js#jso-ref js#this token-symbol:))))
                    (set! (js#jso-ref js#this loading:) #t)
                    (set! (js#jso-ref js#this live:) #f)
                    (set! (js#jso-ref js#this curr:) val))

                  (when (and (js#jso-ref js#this loading:)
                             (not (js#jso-ref js#this live:)))
                    (set! (js#jso-ref js#this token-symbol:) token-symbol)
                    (set! (js#jso-ref js#this live:) #t)
                    (js#.then (coinlayer-live { params: { target: (js#jso-ref fiat symbol:)
                                                          symbols: token-symbol} })
                              (lambda (l)
                                (set! (js#jso-ref js#this loading:) #f)
                                (set! (js#jso-ref js#this live:)
                                  (* val (js#jso-ref l rates: token-symbol)))
                                (js#stmt "console.warn('clist', (@1@))" (js#jso-ref l rates: token-symbol)))))

                  (h "div" [
                             (h "span" { props: { showing: (not (js#jso-ref js#this loading:)) } }
                                ["$" (js#js->scm
                                      (js#expr "(Math.round((@1@ + Number.EPSILON) * 100) / 100).toFixed(2)"
                                               (js#ref js#this live:)))
                                 " "
                             (js#jso-ref fiat symbol:) "<-" token-symbol ])
                             (h "q-inner-loading"
                                { props: { showing: (js#jso-ref js#this loading:) } }
                                [(h "q-spinner-gears" { props: { size: "50px" color: "primary" } })])
                            ]

                 )))
        })
  )
(def (filter-book-using-tags book tags)
  (js#expression #<<EOF
 ((book, tags) => {
   function hasTag(address, tag) {
     // console.log('Has tag?', address, tag)
     return address.tags.find(t => t === tag) }
   // console.log('b', book, 't', tags)
   function hasAllTags(add) {
     let address = add instanceof RTS.Foreign ? RTS.scm2host(add) : add;
     for (const tag of tags) {
       if (!hasTag(address, tag)) { return false };
     }
     return true;
   }
 
   return book.filter(address => hasAllTags(address))
 })((@1@), RTS.scm2host(@2@));
EOF
book tags
))

(js#decl "const axios = require('axios')")

(def coinlayer-key "bbe3ecfc186356e177696808b423aff6")

(def coinlayer-instance
  (js#js->foreign
   (js#expr "axios.create({
   baseURL: 'http://api.coinlayer.com/',
   timeout: 10000,
   params: { access_key: (@1@) }})"
            (js#scm->js coinlayer-key))))

(def (coinlayer.get url (args {}))
  (js#js->foreign
   (js#expr "(() => {return (@1@).get(@2@, (@3@))})();"
            (js#foreign->js coinlayer-instance)
            (js#scm->js url)
            (js#foreign->js args))))

(def (coinlayer-list (args {}))
 (js#.then (coinlayer.get "/list" args)
           (lambda (r)
               (js#jso-ref r data:))))
(def (coinlayer-live (args {}))
 (js#.then (coinlayer.get "/live" args)
           (lambda (r)
               (js#jso-ref r data:))))

(def (axios.get url)
  (js#stmt "console.error('Getting URL', (@1@))"
           (js#scm->js url))
  (js#js->foreign
   (js#expr "(() => {return axios.get(@1@)})();"
            (js#scm->js url))))


(def (js#.then promise fn)
  (js#js->foreign
   (js#expr "((p) => p.then(RTS.scm2host(@1@)))(@2@);"
            fn (if (foreign? promise)
                 (js#foreign->js promise)
                 promise))))

(def default-server-url "http://localhost:6741/")

(def (glow-server-instance (url default-server-url))
  (js#js->foreign
   (js#expr "axios.create({
   baseURL: (@1@),
   timeout: 100000
});
" (js#scm->js url))))

(def (glow-server.get server url (args {}))
  (js#js->foreign
   (js#expr "(() => {return (@1@).get(@2@, (@3@))})();"
            (js#foreign->js (glow-server-instance server))
            (js#scm->js url)
            (js#foreign->js args))))

(def (glow-server.post server url (args {}))
  (js#js->foreign
   (js#expr "(() => {return (@1@).post(@2@, (@3@))})();"
            (js#foreign->js (glow-server-instance server))
            (js#scm->js url)
            (js#foreign->js args))))

(def (post-transfer transfer (server default-server-url))
  (glow-server.post server "/transfer"  transfer ))

(def (post-process process (server default-server-url))
  (glow-server.post server "/process" process))

(def (get-server-home (server default-server-url))
  (js#.then (glow-server.get server "")
            (lambda (r)
              (js#jso-ref r data:))))


(def (add-labels book)
  (js#statement "((ab) => {
 ab.map(a => {
  if (a.label === undefined) {
   a.label = a.name + ' ' + a.hash
  }
  return a
 });
})(RTS.scm2host(@1@));" book)
  book)


(def (get-list-identities (callback (lambda (d) d)))
  (js#.then (axios.get "http://localhost:6741/list-identities")
           (lambda (r)
             (let ((nb (add-labels (js#jso-ref r data:))))
             (js#stmt "console.error('got it!', (@1@))" nb)
             (callback nb)))))





(js#statement "module.exports = {
 AddressSelect: (@1@),
 Amount: (@2@),
 Asset: (@3@),
 getListIdentities: (@4@),
 coinlayerList: (@5@),
 Target: (@6@),
 ExchangeRate: (@7@),
 getServerHome: (@8@),
 postTransfer: (@9@),
 postProcess: (@10@)
};
// console.log('butn', module.exports)"
              (js#scm->js address-select)
              (js#scm->js amount)
              (js#scm->js asset)
              (js#scm->js get-list-identities)
              (js#scm->js coinlayer-list)
              (js#scm->js target)
              (js#scm->js exchange-rate)
              (js#scm->js get-server-home)
              (js#scm->js post-transfer)
              (js#scm->js post-process)

              )
