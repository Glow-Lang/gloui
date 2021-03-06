const routes = [
    {
        path: '/',
        component: () => import('layouts/MainLayout.vue'),
        children: [
            { path: '', component: () => import('pages/Index.vue') },
            { path: 'contact/:cid', name: 'contact', props: true, component: () => import('pages/Contact.vue') },
            { path: 'contacts', name: 'contacts', component: () => import('pages/Contacts.vue') },
            { path: 'create-contact', name: 'create-contact', component: () => import('pages/CreateContact.vue') },
            { path: 'edit-contact/:cid', name: 'edit-contact', props: true, component: () => import('pages/EditContact.vue') },
            { path: 'generate-identity', name: 'generate-identity', props: true, component: () => import('pages/GenerateIdentity.vue') },
            { path: 'networks', component: () => import('pages/Networks.vue') },
            { path: 'start-transaction', name: 'start-transaction', props: true, component: () => import('pages/StartTransaction.vue') },
            { path: 'run-transaction', name: 'run-transaction', props: true, component: () => import('pages/RunTransaction.vue') },
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
