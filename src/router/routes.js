const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/Index.vue') },
      { path: 'Contacts', component: () => import('pages/Contacts.vue') },
      { path: 'CreateContact', component: () => import('pages/CreateContact.vue') },
      { path: 'Networks', component: () => import('pages/Networks.vue') },
      // { path: 'AddAsset', component: () => import('pages/AddAsset.vue') },
      // { path: 'AddAddress', component: () => import('pages/AddAddress.vue') },
      // { path: 'AddContact', component: () => import('pages/AddContact.vue') },
      // { path: 'EditContact',
      //   props: { contact: null }, component: () => import('pages/EditContact.vue') },
      // { path: 'AssetTransfer', component: () => import('pages/AssetTransfer.vue') },
      // { path: 'Rolodex', component: () => import('pages/Rolodex.vue') },
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
