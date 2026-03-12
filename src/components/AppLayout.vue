<script setup lang="ts">
import {
  Wallet,
  LayoutDashboard,
  ArrowLeftRight,
  Landmark,
  PieChart,
  Shapes,
  Database,
  Settings
} from 'lucide-vue-next'
import { RouterLink } from 'vue-router'
</script>

<template>
  <div class="flex min-h-screen h-screen bg-background-light text-slate-900 overflow-hidden">
    <!-- Sidebar Navigation -->
    <aside class="w-64 flex-shrink-0 bg-white border-r border-slate-200 flex flex-col overflow-hidden">
      <div class="p-6">
        <div class="flex items-center gap-3 mb-8">
          <div class="bg-primary rounded-xl p-2 text-white">
            <Wallet :size="24" />
          </div>
          <div>
            <h1 class="text-slate-900 font-bold text-lg leading-none">SmartFlow</h1>
            <p class="text-slate-500 text-xs mt-1">个人财务管理</p>
          </div>
        </div>
        <nav class="space-y-1">
          <RouterLink to="/" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors" active-class="bg-primary/10 text-primary">
            <LayoutDashboard :size="22" />
            <span class="text-sm font-medium">首页</span>
          </RouterLink>
          <RouterLink to="/transactions" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors" active-class="bg-primary/10 text-primary">
            <ArrowLeftRight :size="22" />
            <span class="text-sm font-semibold">交易流水</span>
          </RouterLink>
          <RouterLink to="/accounts" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors" active-class="bg-primary/10 text-primary">
            <Landmark :size="22" />
            <span class="text-sm font-medium">账户管理</span>
          </RouterLink>
          <a href="#" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            <PieChart :size="22" />
            <span class="text-sm font-medium">预算管理</span>
          </a>
          <a href="#" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            <Shapes :size="22" />
            <span class="text-sm font-medium">分类管理</span>
          </a>
          <a href="#" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
            <Database :size="22" />
            <span class="text-sm font-medium">数据管理</span>
          </a>
        </nav>
      </div>
      <div class="mt-auto p-6 border-t border-slate-100">
        <a href="#" class="flex items-center gap-3 px-3 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
          <Settings :size="22" />
          <span class="text-sm font-medium">设置</span>
        </a>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="flex-1 overflow-y-auto overflow-x-hidden scrollbar-hide">
      <slot />
    </main>
  </div>
</template>