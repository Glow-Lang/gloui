(import :js)
(extern namespace: gloui/widgets
  default-server-url glow-server.get glow-server.post
  q-select v-model-input js#.then)

(def (list-contacts (server default-server-url))
  (js#.then
   (glow-server.get server "/list-contacts")
   (cut js#jso-ref <> data:)))

(js#stmt
 "module.exports = {
  listContacts: (@1@)
}"
 (js#scm->js list-contacts))
