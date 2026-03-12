import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue'),
    },
    {
      path: '/accounts',
      name: 'accounts',
      component: () => import('@/views/AccountsView.vue'),
    },
    {
      path: '/accounts/manage',
      name: 'accounts-manage',
      component: () => import('@/views/AccountsManageView.vue'),
    },
    {
      path: '/accounts/new',
      name: 'account-new',
      component: () => import('@/views/AccountNewView.vue'),
    },
    {
      path: '/categories',
      name: 'categories',
      component: () => import('@/views/CategoriesView.vue'),
    },
    {
      path: '/categories/new',
      name: 'category-new',
      component: () => import('@/views/CategoryNewView.vue'),
    },
    {
      path: '/transactions',
      name: 'transactions',
      component: () => import('@/views/TransactionsView.vue'),
    },
    {
      path: '/transactions/calendar',
      name: 'transactions-calendar',
      component: () => import('@/views/TransactionsCalendarView.vue'),
    },
    {
      path: '/transactions/new',
      name: 'transaction-new',
      component: () => import('@/views/TransactionNewView.vue'),
    },
  ],
})

export default router
