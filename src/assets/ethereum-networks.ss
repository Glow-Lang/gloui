(import :js)
(extern namespace: gloui/widgets
  default-server-url glow-server.get glow-server.post
  q-select v-model-input js#.then)

(def (list-evm-networks (server default-server-url))
  (js#.then
   (glow-server.get server "/list-evm-networks")
   (cut js#jso-ref <> data:)))

(js#stmt
 "module.exports = {
  listEvmNetworks: (@1@)
}"
 (js#scm->js list-evm-networks))
