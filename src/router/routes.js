import REPL from 'pages/REPL.vue';
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: 'AddAsset', component: () => import('pages/AddAsset.vue') },
      { path: 'AddAddress', component: () => import('pages/AddAddress.vue') },
      { path: 'AssetTransfer', component: () => import('pages/AssetTransfer.vue') },
      { path: 'Rolodex', component: () => import('pages/Rolodex.vue') },
      { path: '', component: () => import('pages/Index.vue') }
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
