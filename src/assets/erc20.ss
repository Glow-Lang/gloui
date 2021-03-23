(import :js)

(extern namespace: gloui/widgets
  default-server-url glow-server.get glow-server.post
  q-select v-model-input js#.then)

(def (erc20-contracts (server default-server-url))
  (glow-server.get server "/erc20/contracts"))

(def (erc20-balance contact (server default-server-url))
 (js#.then (glow-server.post server "/erc20/balance"
                             contact)))

(def (erc20-transfer xfer (server default-server-url))
  (js#.then
   (glow-server.post server "/erc20/transfer" xfer)
   (cut js#jso-ref <> data:)))

(def (erc20-asset go _)
  (go { name: "ERC20Asset"
        components: { q-select: q-select }
        props: { value: {}
                 options: {}
                 label: { default: "ERC20" }}
      render: (js#function (h)  (h "q-select"
                   { props: { filled: #t
                              value: (js#jso-ref js#this value:)
                              options: (js#jso-ref js#this options:)
                              label: (js#jso-ref js#this label:)}
                     on: { input: (v-model-input js#this) }}))
        })
  )

(js#stmt "module.exports = {
 ERC20Contracts: (@1@),
 ERC20Asset: (@2@),
 ERC20Balance: (@3@),
 ERC20Transfer: (@4@)
}"
         (js#scm->js erc20-contracts)
         (js#scm->js erc20-asset)
         (js#scm->js erc20-balance)
         (js#scm->js erc20-transfer))
