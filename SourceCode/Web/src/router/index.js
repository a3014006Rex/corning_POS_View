import { createRouter, createWebHashHistory } from 'vue-router'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    { path: '/', redirect: '/pos' },
    {
      path: '/development',
      name: 'development',
      component: () => import('@/views/development/simulation-lab.vue'),
      meta: { title: '刷卡流程驗證' },
    },
    {
      path: '/admin',
      component: () => import('@/layouts/AdminLayout.vue'),
      children: [
        { path: '', redirect: '/admin/transactions' },
        { path: 'transactions', name: 'admin-transactions', component: () => import('@/views/admin/transaction-lab.vue'), meta: { title: '測試交易紀錄' } },
      ],
    },
    {
      path: '/pos',
      name: 'pos',
      component: () => import('@/views/pos/pos-view.vue'),
      meta: { title: '用餐刷卡' },
    },
    {
      path: '/system',
      name: 'system',
      component: () => import('@/views/system/system-status.vue'),
      meta: { title: '系統狀態' },
    },
    { path: '/:pathMatch(.*)*', redirect: '/pos' },
  ],
})

router.afterEach((to) => {
  document.title = `${to.meta.title || '康寧餐卡'} · 康寧 POS`
})

export default router
