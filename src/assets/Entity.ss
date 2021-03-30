(import :mukn/gloui/js/entity :js)


(js#decl #<<EOF
function Entity (obj = {}) {
  this.$entity.self = this;
  Object.assign(this, obj);
};

Entity.prototype.$entity = function () {
  const obj = Object.create(null);
  this.$entity.slots.forEach(slot => {
    const slotValue = this[slot]
    obj[slot] = (slotValue === undefined) ? null : slotValue
  })
    return obj;
}
Entity.prototype.$entity.slots = []
Entity.prototype.$entity.initSlots = {}
Entity.prototype.$entity.self = null

function createEntity (fn, slots = {}, proto = Entity.prototype) {
  const entitySlots = (slots instanceof Array) ? slots : Object.keys(slots);
  const parentSlots = proto.$entity.slots
  const entityInit = (() => {
    if (slots instanceof Array) {
      const obj = {}
      slots.forEach(k => { obj[k] = proto[k] === undefined ? null : proto[k] })
      return obj
    } else {
      return slots;
    }
  })();

  fn.prototype = Object.create(proto)
  fn.prototype.$entity = function () { return proto.$entity.call(this) };
  Object.assign(fn.prototype.$entity, proto.$entity)
  fn.prototype.$entity.slots = [...new Set([...entitySlots, ...parentSlots])]
  fn.prototype.$entity.initSlots = { ...proto.$entity.initSlots,  ...entityInit }
  Object.defineProperty(
    fn.prototype.$entity, 'JSON',
    Object.getOwnPropertyDescriptor(
      Entity.prototype.$entity, 'JSON'));

  fn.create = fn.prototype.create

  for (const [key, value] of Object.entries(entityInit)) {
    Object.defineProperty(fn.prototype, key, {
      value: value,
      writable: true, configurable: true})
  }
  return fn;
};

Entity.prototype.create = function (fn, slots = {}, proto = false) {
  const eproto = (proto) ? proto : this.prototype;
  return createEntity(fn, slots, eproto)
}

Entity.create = Entity.prototype.create;

Entity.prototype.mix = function () {
  entities = [...arguments];
  const obj = entities[0]
  function mix () { obj.call(this, ...arguments)};
  const superE = (entities.length > 1) ?
        this.mixEntities(...entities.slice(1)) : Entity
  return superE.create(mix, obj.prototype.$entity.initSlots);
}
Entity.mix = Entity.prototype.mix;

Object.defineProperty(Entity.prototype.$entity, 'JSON', {
  get() {
    return JSON.stringify(this.call(this.self))
  },
  enumerable: false
})

EOF
)

(define-entity
  (Network
   @ []
     name ;; ie. "Ethereum Mainnet"
     shortName ;; ie: "eth"
     chain ;; the chain that this network is supporting, e.g. "ETH"
     description ;; A string describing the network
     infoURL ;; A URL to look at for more information
     currency ;; A String for a Symbol (also a string) in the Currency store
     test ;; a boolean saying if this is not the master for its chain
     type ;; default "ethereum"
  )
  type: "ethereum")

(define-entity (Foo @ [] slots))

(js#stmt "window.Bar = (@1@);  module.exports = Entity; window.Network = (@2@)"
         Foo (js#foreign->js Network))
