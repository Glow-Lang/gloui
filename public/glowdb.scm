(define %glowdb #f)

(##inline-host-declaration
 #<<EOF
 globalThis.$glowServer = '/cloud';
 const { openDB, deleteDB, wrap, unwrap } = require('idb');
 (() => {
     globalThis.$glowdb = false;
     globalThis.$glowdbPromise = false;
     const dbName = 'glow'
     const version = 42 //versions start at 1

     const entities = [];

     console.log('Loading DB')

  const db = openDB(dbName, version, {
    upgrade(db, oldVersion, newVersion, transaction) {
      console.log('Upgrading DB')
      entities.map(e => {
        console.log('Entity', e)
       if (!db.objectStoreNames.contains(e)) {
          db.createObjectStore(e)
       }
      })
     // db.deleteObjectStore('network')
      console.log('Upgrading Network')
     if (!db.objectStoreNames.contains('network')) {
       let objectStore = db.createObjectStore("network", { keyPath: "key" });
        objectStore.createIndex("description", "description", { unique: true });
        objectStore.createIndex("uri", "uri", { unique: true });
     }
     

     // const crypt = db.deleteObjectStore('crypto')
     // globalThis.$c = crypt;

      // console.log('Upgrading Crytpo')
      if (!db.objectStoreNames.contains('crypto')) {
        let objectStore = db.createObjectStore("crypto", { keyPath: "symbol" });
      }
      

      if (db.objectStoreNames.contains('address')) {
       db.deleteObjectStore('address')
        }
      if (!db.objectStoreNames.contains('address')) {
        console.log('Upgrading Address')
        let objectStore = db.createObjectStore("address", { keyPath: "id" });
      }
      

      if (db.objectStoreNames.contains('asset')) {
        db.deleteObjectStore('asset')
        }
      if (!db.objectStoreNames.contains('asset')) {
      
        console.log('Upgrading Asset')
      
        let objectStore = db.createObjectStore("asset", { keyPath: ["owner", "address"] });
      
        objectStore.createIndex("owner", "owner", { unique: false });
        objectStore.createIndex("address", "address", { unique: false });
      
      }
      

      console.log('Upgrading Resource Type')
      if (!db.objectStoreNames.contains('resourceType')) {
        console.log('Upgrading Resource Type')
        let objectStore = db.createObjectStore("resourceType", { keyPath: "name" });
      }
      

      if (db.objectStoreNames.contains('resource')) {
         db.deleteObjectStore('resource')
        }
      if (!db.objectStoreNames.contains('resource')) {
            console.log('Upgrading Resource')
        let objectStore = db.createObjectStore("resource", { keyPath: ["name", 'network'] });
      }
      

      // db.deleteObjectStore('identity')
      console.log('Upgrading Identity')
      if (!db.objectStoreNames.contains('identity')) {
        let objectStore = db.createObjectStore("identity", { keyPath: "name" });
      }
      

      // db.deleteObjectStore('contact')
      if (!db.objectStoreNames.contains('contact')) {
        console.log('Upgrading contact')
        let objectStore = db.createObjectStore("contact", { keyPath: "id" });
      }

    }
  })

  $glowdbPromise = db;

  db.then((d) => {
    console.log('finally Loaded DB')
    globalThis.$glowdb = d
    Object.assign(globalThis.$glowdb, module.exports);
    });
})()


EOF
)


(define (glowdb)
  (or %glowdb
      (let foo ()
        (let ((db (##inline-host-expression "@host2scm@($glowdb)")))
          (if db
            (begin (set! %glowdb db) db)
            (begin (thread-sleep! 0.01)
                   (foo)))))))

(##begin
  (##namespace ("_six/js#" six.infix))
  (##define-syntax six.infix
    (lambda (src)
      (##demand-module _six/six-expand)
      (_six/six-expand#six.infix-js-expand src))))

(define (store name)
  \`(glowdb).transaction(`name).objectStore(`name))

(define (store.add name object #!optional (key \undefined))
  \`(glowdb).transaction(`name, 'readwrite').objectStore(`name).add(`object,`key))

(define (store.put name object #!optional (key #!void))
  \`(glowdb).transaction(`name, 'readwrite').objectStore(`name).put(`object, `key))

(define (store.get name key #!optional (value #!void))
  (define store \`(glowdb).transaction(`name).objectStore(`name))
   (if (void? value)
     \(`store).get(`key)
     (begin
       \console.log((`store).indexNames)
      (let ((idx \(`store).index(`(keyword->string key))))
      \(`idx).get(`value)))))



(define (ensureNetwork nw)
  (if (list? nw)
    (##inline-host-expression "@host2scm@({ key: @scm2host@(@1@), description: @scm2host@(@2@), uri: @scm2host@(@3@),
   nativeCurrency: @scm2host@(@4@), test: @scm2host@(@5@)})"
                        (car nw) (cadr nw) (caddr nw) (cadddr nw) (cadddr (cdr nw)))
    nw))

(define (%network-add/put add/put nw)
  (define nwjs (ensureNetwork nw))
  (##inline-host-statement "console.log(@1@)" nwjs)
  (add/put "network" nwjs))

(define (network.add nw)
  (%network-add/put store.add nw))
(define (network.put nw)
  (%network-add/put store.put nw))

(define (network.get key #!optional (value #!void))
  (store.get "network" key value))

(define (add-networks)
  (let ((networks
       '(("ced"         "Cardano EVM Devnet"  "https://rpc-evm.portal.dev.cardano.org/" "ADA" #f)
        ("etc"         "Ethereum Classic Mainnet"            "https://ethereumclassic.network" "ETC" #f)
        ("eth"         "Ethereum Mainnet"                    "https://mainnet.infura.io/v3/${INFURA_API_KEY}" "ETH" #f)
        ("kot"         "Ethereum Classic Testnet Kotti"      "https://www.ethercluster.com/kotti" "ETC" #t)
        ("kov"         "Ethereum Testnet Kovan"             "https://kovan.poa.network" "ETH" #t)
        ("ogor"        "Optimistic Ethereum Testnet Goerli" "https://www.ethercluster.com/goerli" "ETH" #t)
        ("pet"         "Private Ethereum Testnet"
         "http://localhost:8545" "ETH" #t)
        ("rin"         "Ethereum Testnet Rinkeby"           "https://rinkeby.infura.io/v3/${INFURA_API_KEY}" "ETH" #t)
        ("rop"         "Ethereum Testnet Ropsten"           "https://ropsten.infura.io/v3/${INFURA_API_KEY}" "ETH" #t))))

  (map (lambda (nw) (let ((n (network.get (car nw))))
                      (if (void? n) (network.add nw)
                          (network.put nw))))
       networks)))
(define (list-networks)
  \`(store "network").getAll())



(##inline-host-declaration #<<EOF

function addResourceType(rt) {
  $glowdbPromise.then(db => {
    const trans = db.transaction('resourceType', 'readwrite').objectStore('resourceType')
    const obj = trans.put(rt)
  })
}

addResourceType({
  name: "Native",
  description: "The Native CryptoCurrency of a network",
  construct: {}
})

addResourceType({
  name: "ERC20",
  description: "An ERC20 Contract",
  construct: { address: "The address of this contract in '0x' format"}
})


function listResourceTypes() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('resourceType').objectStore('resourceType')
    return trans.getAll();
  })
}


function saveContact(ctct) {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('contact', 'readwrite').objectStore('contact')
    return trans.put(ctct)
  })
}
function deleteContact(ctct) {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('contact', 'readwrite').objectStore('contact')
    const obj = trans.delete(ctct.id)
    return ctct
  })
}
function listContacts() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('contact').objectStore('contact')
    return trans.getAll();
  })
}

// async function ensureContactEntity(ct) {
//   const contact (typeof ct === 'string') ? await findContact(ct) : ct;
//   contact.owner = (typeof contact.)

// }
function findContact(id) {
  if (typeof id === 'object') return id;
  return $glowdbPromise.then(db => {
    const trans = db.transaction('contact').objectStore('contact')
    return trans.get(id);
  })
}
function saveResource(ctct) {
  $glowdbPromise.then(db => {
    const trans = db.transaction('resource', 'readwrite').objectStore('resource')
    const obj = trans.put(ctct)
  })
}
function listResources() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('resource').objectStore('resource')
    return trans.getAll();
  })
}
function findResource(id) {
  if (typeof id === 'object') return id;
  return $glowdbPromise.then(db => {
    const trans = db.transaction('resource').objectStore('resource')
    return trans.get(id);
  })
}
function saveIdentity(ctct) {
  $glowdbPromise.then(db => {
    const trans = db.transaction('identity', 'readwrite').objectStore('identity')
    const obj = trans.put(ctct)
  })
}
function listIdentities() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('identity').objectStore('identity')
    return trans.getAll();
  })
}
function findIdentity(id) {
  if (typeof id === 'object') return id;
  return $glowdbPromise.then(db => {
    const trans = db.transaction('identity').objectStore('identity')
    return trans.get(id);
  })
}
function saveAsset(ctct) {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('asset', 'readwrite').objectStore('asset')
    const obj = trans.put(ctct)
  })
}
function deleteAsset(ctct) {
  $glowdbPromise.then(db => {
    const ass = {
      owner: (typeof ctct.owner === 'string') ? ctct.owner : ctct.owner.id,
      address: (typeof ctct.address === 'string') ? ctct.address : ctct.address.id
    }
    const key = [ass.owner, ass.address];

    console.log('trying to delete ,', ass, key)
    const trans = db.transaction('asset', 'readwrite').objectStore('asset')
    return trans.delete(key)
  })
}

function listAssets() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('asset').objectStore('asset')
    return trans.getAll();
  })
}


function findAsset(id) {
  if (typeof id === 'object') return id;
  return $glowdbPromise.then(db => {
    const trans = db.transaction('asset').objectStore('asset')
    return trans.get(id);
  })
}

async function findAssetEntity(as) {

  async function givr (give, thing) {
    const gThing = (typeof thing === 'string') ? await give(thing) : thing;
    return gThing;
  }

  const ass = await givr(findAsset, as);
  ass.address= await givr(findAddress, ass.address)
  ass.owner = await givr(findContact, ass.owner)

  return ass;

}

async function listAssetEntities() {
  const newEns = [];
  const ens = await listAssets();

  for (const i in ens) {
    const en = await findAssetEntity(ens[i])
    newEns.push(en)
  }

  return newEns;
}
function saveAddress(ctct) {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('address', 'readwrite').objectStore('address')
    const obj = trans.put(ctct)
    return ctct
  })
}
function deleteAddress(ctct) {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('address', 'readwrite').objectStore('address')
    const obj = trans.delete(ctct.id)
    return ctct
  })
}
function listAddresses() {
  return $glowdbPromise.then(db => {
    const trans = db.transaction('address').objectStore('address')
    return trans.getAll();
  })
}
function findAddress(id) {
  if (typeof id === 'object') return id;
  return $glowdbPromise.then(db => {
    const trans = db.transaction('address').objectStore('address')
    return trans.get(id);
  })
}

EOF
)

(##inline-host-statement "globalThis.$glowdb.addNetworks = @scm2host@(@1@);" add-networks)

(##inline-host-declaration #<<EOF
 module.exports = {
  listNetworks: () => {
   return $glowdb.transaction('network').objectStore('network').getAll();
  },

  addNetworks() {
    const nws = [{"key":"ced",
                  "description":"Cardano EVM Devnet","uri":"https://rpc-evm.portal.dev.cardano.org/",
                  "nativeCurrency":"ADA",
                  "test":false},
                 {"key":"etc","description":"Ethereum Classic Mainnet","uri":"https://ethereumclassic.network",
                  "nativeCurrency":"ETC","test":false},
                 {"key":"eth","description":"Ethereum Mainnet","uri":"https://mainnet.infura.io/v3/${INFURA_API_KEY}",
                  "nativeCurrency":"ETH","test":false},
                 {"key":"kot","description":"Ethereum Classic Testnet Kotti","uri":"https://www.ethercluster.com/kotti","nativeCurrency":"ETC","test":true},
                 {"key":"kov","description":"Ethereum Testnet Kovan","uri":"https://kovan.poa.network","nativeCurrency":"ETH","test":true},
                 {"key":"ogor","description":"Optimistic Ethereum Testnet Goerli","uri":"https://www.ethercluster.com/goerli","nativeCurrency":"ETH","test":true},
                 {"key":"pet","description":"Private Ethereum Testnet","uri":"http://localhost:8545","nativeCurrency":"ETH","test":true},
                 {"key":"rin","description":"Ethereum Testnet Rinkeby","uri":"https://rinkeby.infura.io/v3/${INFURA_API_KEY}","nativeCurrency":"ETH","test":true},
                 {"key":"rop","description":"Ethereum Testnet Ropsten","uri":"https://ropsten.infura.io/v3/${INFURA_API_KEY}","nativeCurrency":"ETH","test":true} ]
   return nws.map(nw => $glowdb.transaction('network', 'readwrite').objectStore('network').put(nw));
   },
  countObjectStore(store, query) {
   return $glowdbPromise.then(db =>
     db.transaction(store).objectStore(store).count(query).then(n => n))
  },
  addResourceType: addResourceType,
  listResourceTypes: listResourceTypes,
  saveAddress: saveAddress,
  findAddress: findAddress,
  listAddresses: listAddresses,
  saveContact: saveContact,
  findContact: findContact,
  listContacts: listContacts,
  saveIdentity: saveIdentity,
  findIdentity: findIdentity,
  listIdentities: listIdentities,
  saveResource: saveResource,
  findResource: findResource,
  listResources: listResources,
  saveAsset: saveAsset,
  deleteAsset: deleteAsset,
  listAssets: listAssets,
  listAssetEntities: listAssetEntities,

}

EOF
)
(##inline-host-declaration "
globalThis.randomUUID = function (){
    var dt = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (dt + Math.random()*16)%16 | 0;
        dt = Math.floor(dt/16);
        return (c=='x' ? r :(r&0x3|0x8)).toString(16);
    });
    return uuid;
}
"
)
