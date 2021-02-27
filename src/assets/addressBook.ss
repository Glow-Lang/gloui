(import :js)
;; (js#declaration "console.log('Loaded Address Book')")

(def (random-hash) (js#expression "'Ox' + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);"))


(def (get-FROM-address-book pkey)
  [
     { name: "Alice Eat Me"
       hash: (random-hash)
       tags: ["foo" "bar" "rps"]
       private-key: "THISISPRIVATE" }
     { name: "Alice Drink Me"
       hash: (random-hash)
       tags: ["baz" "rps" "moonshine"]
       private-key: "THISISPRIVATE" }
     { name: "Bob"
       hash: (random-hash)
       tags: ["foo" "rps"] }
     { name: "Charlie Noble"
       hash: (random-hash)
       tags: ["bar"] }
     ]

  )
(def (get-TO-address-book)
  [
   { name: "Xavier "
     hash: (random-hash)
     tags: ["foo" "bar" "rps"] }
   { name: "Wyclef Jean"
     hash: (random-hash)
     tags: ["baz" "moonshine"] }
   { name: "Jimi Hendrix"
     hash: (random-hash)
     tags: ["foo" "rps"]}
   { name: "Yvonne Brown"
     hash: (random-hash)
     tags: ["bar" "foo" "baz"] }
   ]
 )


(def (filter-book-using-tags book tags)
  (js#expression #<<EOF
 ((book, tags) => {
   function hasTag(address, tag) {
     console.log('Has tag?', address, tag)
     return address.tags.find(t => t === tag) }
   console.log('b', book, 't', tags)
   function hasAllTags(add) {
     let address = RTS.scm2host(add);
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
(def (fees-and-totals amount unit blockchain)
  {fee: 0.42 total: (* amount 3.14) })


(def (add-labels book)
  (js#statement "((ab) => {
return ab.map(a => {
  if (a.label === undefined) {
   a.label = a.name + ' ' + a.hash
  }
  return a
 })
})(RTS.scm2host(@1@));" book)
  book)




;; (js#declaration "let findAddress = undefined")
;; (def (find-address name: (n #f) hash: (h #f) tags: (ts #f) pkey: (pkey #f))


;;   (def ab (ensure-address-book))
;;   (def dresses [])

;;   (js#statement "console.log('Find Address in', (@1@)" ab))

;; (js#statement "findAddress = (name, opts) => {

;; }")

(js#declaration "


function findAddressesByName (name, ab) {
  const needle = name.toLowerCase()
  const newAdds = ab.filter( a => {
     n = a.name.toLowerCase() ; return n.startsWith(needle)
  });
 return newAdds;
};")

(js#statement
 "
let getFromAddressBook = (@2@);
let getToAddressBook = (@3@);
let filterBookUsingTags = (@4@);
let feesAndTotals = (@5@)
module.exports = {
  findAddressesByName,
  getFromAddressBook,
  getToAddressBook,
  filterBookUsingTags,
  feesAndTotals
}"
 #f
 (js#scm->js (lambda (pk) (add-labels (get-FROM-address-book pk))))
 (js#scm->js (lambda () (add-labels (get-TO-address-book))))
 (js#scm->js filter-book-using-tags)
 (js#scm->js fees-and-totals)

 )
