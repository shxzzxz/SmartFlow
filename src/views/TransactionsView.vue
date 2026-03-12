<script setup lang="ts">
import {
  List,
  Calendar,
  Plus,
  TrendingUp,
  TrendingDown,
  Search
} from 'lucide-vue-next'
import AppLayout from '@/components/AppLayout.vue'
import TransactionList from '@/components/TransactionList.vue'
import { RouterLink } from 'vue-router'
</script>

<template>
  <AppLayout>
    <div class="max-w-6xl mx-auto p-8 w-full">

      <!-- Header Section -->
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-8">
        <div>
          <h2 class="text-3xl font-bold">交易流水</h2>
          <p class="text-muted-foreground">查看和管理所有财务流水</p>
        </div>
        <div class="flex items-center gap-4">
          <div class="flex items-center bg-slate-100 p-1 rounded-xl w-fit">
            <button class="flex items-center gap-2 px-6 py-2 bg-white shadow-sm rounded-lg text-sm font-semibold">
              <List :size="16" />
              流水视图
            </button>
            <RouterLink to="/transactions/calendar" class="flex items-center gap-2 px-6 py-2 text-slate-500 text-sm font-semibold hover:text-primary transition-colors">
              <Calendar :size="16" />
              日历视图
            </RouterLink>
          </div>
          <RouterLink to="/transactions/new" class="flex items-center gap-2 px-6 py-2 bg-primary text-white rounded-xl shadow-lg shadow-primary/20 text-sm font-bold hover:opacity-90 transition-opacity">
            <Plus :size="20" />
            新建交易
          </RouterLink>
        </div>
      </div>

      <!-- Summary Bar -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-card p-6 rounded-xl border flex flex-col gap-1">
          <span class="text-sm font-medium text-muted-foreground">总收入</span>
          <span class="text-2xl font-bold text-emerald-600">+¥4,250.00</span>
          <span class="text-xs font-medium text-emerald-600/80 bg-emerald-50 px-2 py-0.5 rounded-full w-fit flex items-center gap-1">
            <TrendingUp :size="12" /> +5.2%
          </span>
        </div>
        <div class="bg-card p-6 rounded-xl border flex flex-col gap-1">
          <span class="text-sm font-medium text-muted-foreground">总支出</span>
          <span class="text-2xl font-bold text-rose-600">-¥2,840.50</span>
          <span class="text-xs font-medium text-rose-600/80 bg-rose-50 px-2 py-0.5 rounded-full w-fit flex items-center gap-1">
            <TrendingDown :size="12" /> -2.1%
          </span>
        </div>
        <div class="bg-card p-6 rounded-xl border flex flex-col gap-1">
          <span class="text-sm font-medium text-muted-foreground">净流入</span>
          <span class="text-2xl font-bold">+¥1,409.50</span>
          <span class="text-xs font-medium text-muted-foreground bg-muted px-2 py-0.5 rounded-full w-fit">最近30天</span>
        </div>
        <div class="bg-primary p-6 rounded-xl flex flex-col gap-1 text-primary-foreground">
          <span class="text-sm font-medium text-primary-foreground/80">活跃预算</span>
          <span class="text-2xl font-bold">¥1,200.00</span>
          <div class="w-full bg-primary-foreground/20 h-1.5 rounded-full mt-2">
            <div class="bg-primary-foreground h-full rounded-full w-[65%]"></div>
          </div>
        </div>
      </div>

      <!-- Filters and Search -->
      <div class="flex items-center justify-between mb-4 gap-4">
        <div class="flex items-center gap-2">
          <h3 class="text-lg font-bold">最近活动</h3>
        </div>
        <div class="relative max-w-xs w-full">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" :size="20" />
          <input
            type="text"
            placeholder="搜索..."
            class="w-full pl-10 pr-4 py-2 bg-white border rounded-lg focus:ring-2 focus:ring-ring focus:outline-none text-sm"
            aria-label="搜索交易"
          />
        </div>
      </div>

      <!-- Transaction List -->
      <TransactionList />

    </div>
  </AppLayout>
</template>
