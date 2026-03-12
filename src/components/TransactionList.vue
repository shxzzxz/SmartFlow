<script setup lang="ts">
import {
  ShoppingCart,
  Briefcase,
  ArrowRightLeft,
  CreditCard,
  ArrowDown,
  Utensils,
  Wallet,
  Landmark,
  ChevronLeft,
  ChevronRight
} from 'lucide-vue-next'
</script>

<template>
  <div class="bg-card rounded-xl border overflow-hidden">
    <div class="grid grid-cols-12 gap-4 px-6 py-4 bg-muted/50 border-b text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
      <div class="col-span-3 flex items-center gap-1">分类</div>
      <div class="col-span-2 flex items-center gap-1">账户</div>
      <div class="col-span-1">操作信息</div>
      <div class="col-span-2">属性</div>
      <div class="col-span-1">标签</div>
      <div class="col-span-2">时间</div>
      <div class="col-span-1 text-right">金额</div>
    </div>

    <div class="divide-y">
      <!-- Item 1 -->
      <div class="grid grid-cols-12 gap-4 px-6 py-5 hover:bg-muted/50 transition-colors items-center group">
        <div class="col-span-3 flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
            <ShoppingCart :size="20" />
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-sm font-bold truncate">超市购物</span>
            <span class="text-xs text-muted-foreground truncate">每周补货</span>
          </div>
        </div>
        <div class="col-span-2 flex items-center gap-2">
          <Wallet :size="18" class="text-muted-foreground" />
          <span class="text-xs font-semibold truncate">支付宝</span>
        </div>
        <div class="col-span-1 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-emerald-50 text-emerald-600 rounded">退0.62</span>
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-rose-50 text-rose-600 rounded">惠0.7</span>
        </div>
        <div class="col-span-2 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-muted text-muted-foreground rounded">不计预算</span>
        </div>
        <div class="col-span-1">
          <span class="text-[10px] font-medium px-2 py-0.5 border rounded-full">食品</span>
        </div>
        <div class="col-span-2 text-xs text-muted-foreground font-medium">
          3月3日 17:50
        </div>
        <div class="col-span-1 text-right flex flex-col">
          <span class="text-sm font-bold text-rose-600">-¥124.50</span>
          <span class="text-[10px] text-muted-foreground line-through">¥125.20</span>
        </div>
      </div>

      <!-- Item 2 -->
      <div class="grid grid-cols-12 gap-4 px-6 py-5 hover:bg-muted/50 transition-colors items-center group">
        <div class="col-span-3 flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0">
            <Briefcase :size="20" />
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-sm font-bold truncate">月度工资</span>
            <span class="text-xs text-muted-foreground truncate">公司发薪</span>
          </div>
        </div>
        <div class="col-span-2 flex items-center gap-2">
          <Landmark :size="18" class="text-muted-foreground" />
          <span class="text-xs font-semibold truncate">招商银行</span>
        </div>
        <div class="col-span-1 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-emerald-50 text-emerald-600 rounded">退0.62</span>
        </div>
        <div class="col-span-2 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-muted text-muted-foreground rounded">不计收入</span>
        </div>
        <div class="col-span-1">
          <span class="text-[10px] font-medium px-2 py-0.5 border rounded-full">收入</span>
        </div>
        <div class="col-span-2 text-xs text-muted-foreground font-medium">
          3月2日 09:00
        </div>
        <div class="col-span-1 text-right flex flex-col">
          <span class="text-sm font-bold text-emerald-600">+¥4,250.00</span>
        </div>
      </div>

      <!-- Item 3 -->
      <div class="grid grid-cols-12 gap-4 px-6 py-5 hover:bg-muted/50 transition-colors items-center group">
        <div class="col-span-3 flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-muted flex items-center justify-center text-muted-foreground shrink-0">
            <ArrowRightLeft :size="20" />
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-sm font-bold truncate">内部转账</span>
            <span class="text-xs text-muted-foreground truncate">月度储蓄</span>
          </div>
        </div>
        <div class="col-span-2 flex flex-col gap-1 justify-center">
          <div class="flex items-center gap-1.5">
            <CreditCard :size="14" class="text-muted-foreground" />
            <span class="text-[10px] font-medium truncate text-muted-foreground">信用卡</span>
          </div>
          <ArrowDown :size="12" class="text-muted-foreground/30 ml-0.5" />
          <div class="flex items-center gap-1.5">
            <Wallet :size="14" class="text-muted-foreground" />
            <span class="text-[10px] font-medium truncate text-muted-foreground">支付宝</span>
          </div>
        </div>
        <div class="col-span-1 flex flex-wrap gap-1">
        </div>
        <div class="col-span-2 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-muted text-muted-foreground rounded">不计预算</span>
        </div>
        <div class="col-span-1">
          <span class="text-[10px] font-medium px-2 py-0.5 border rounded-full">储蓄</span>
        </div>
        <div class="col-span-2 text-xs text-muted-foreground font-medium">
          2月28日 11:30
        </div>
        <div class="col-span-1 text-right flex flex-col justify-center">
          <span class="text-sm font-bold">¥500.00</span>
        </div>
      </div>

      <!-- Item 4 -->
      <div class="grid grid-cols-12 gap-4 px-6 py-5 hover:bg-muted/50 transition-colors items-center group">
        <div class="col-span-3 flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center text-amber-600 shrink-0">
            <Utensils :size="20" />
          </div>
          <div class="flex flex-col min-w-0">
            <span class="text-sm font-bold truncate">朋友聚餐</span>
            <span class="text-xs text-muted-foreground truncate">意大利餐厅</span>
          </div>
        </div>
        <div class="col-span-2 flex items-center gap-2">
          <Wallet :size="18" class="text-muted-foreground" />
          <span class="text-xs font-semibold truncate">支付宝</span>
        </div>
        <div class="col-span-1 flex flex-wrap gap-1">
          <span class="text-[10px] font-bold px-1.5 py-0.5 bg-blue-50 text-blue-600 rounded">报11.3</span>
        </div>
        <div class="col-span-2 flex flex-wrap gap-1">
        </div>
        <div class="col-span-1">
          <span class="text-[10px] font-medium px-2 py-0.5 border rounded-full">社交</span>
        </div>
        <div class="col-span-2 text-xs text-muted-foreground font-medium">
          2月23日 20:30
        </div>
        <div class="col-span-1 text-right flex flex-col">
          <span class="text-sm font-bold text-rose-600">-¥85.00</span>
          <span class="text-[10px] text-muted-foreground line-through">¥96.30</span>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div class="px-6 py-4 flex items-center justify-between border-t">
      <p class="text-xs text-slate-500">显示 4 / 128 条交易</p>
      <div class="flex items-center gap-2">
        <button class="p-2 rounded-lg border hover:bg-slate-50 transition-colors" aria-label="上一页">
          <ChevronLeft :size="16" />
        </button>
        <button class="px-3 py-1 text-sm font-bold rounded-lg bg-primary text-white" aria-label="第1页" aria-current="page">1</button>
        <button class="px-3 py-1 text-sm font-bold rounded-lg hover:bg-slate-50 transition-colors" aria-label="第2页">2</button>
        <button class="px-3 py-1 text-sm font-bold rounded-lg hover:bg-slate-50 transition-colors" aria-label="第3页">3</button>
        <button class="p-2 rounded-lg border hover:bg-slate-50 transition-colors" aria-label="下一页">
          <ChevronRight :size="16" />
        </button>
      </div>
    </div>
  </div>
</template>
