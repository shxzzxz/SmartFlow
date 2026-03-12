<script setup lang="ts">
import {
  List,
  Calendar,
  Plus,
  ChevronLeft,
  ChevronRight
} from 'lucide-vue-next'
import AppLayout from '@/components/AppLayout.vue'
import TransactionList from '@/components/TransactionList.vue'
import CalendarCell from '@/components/CalendarCell.vue'
import { RouterLink } from 'vue-router'
import { ref, computed } from 'vue'
import dayjs from 'dayjs'

const currentDate = ref(dayjs())
const currentYearMonth = computed(() => currentDate.value.format('YYYY年M月'))

// 示例数据
const calendarData = [
  { date: 1, income: 1200, expense: 450 },
  { date: 2, income: 0, expense: 24.50 },
  { date: 3 },
  { date: 4, income: 0, expense: 120 },
  { date: 5, income: 250, expense: 12, isToday: true, hasPaymentDue: true },
  { date: 6, income: 0, expense: 89.99 },
  { date: 7 },
  { date: 8 },
  { date: 9, income: 0, expense: 310 },
  { date: 10, income: 85, expense: 0 },
  { date: 11 },
  { date: 12, income: 0, expense: 15 },
  { date: 13, income: 0, expense: 45.50 },
  { date: 14 },
  { date: 15, income: 450, expense: 0 },
  { date: 16 },
  { date: 17, income: 0, expense: 20 },
  { date: 18 },
  { date: 19, income: 0, expense: 15, hasPaymentDue: true },
  { date: 20, income: 0, expense: 210.30 },
  { date: 21 },
  { date: 22 },
  { date: 23 },
  { date: 24, income: 0, expense: 15.99 },
  { date: 25, income: 1500, expense: 0 },
  { date: 26, income: 0, expense: 45 },
  { date: 27 },
  { date: 28 },
  { date: 29 },
  { date: 30, income: 0, expense: 32 },
  { date: 31 },
  { date: 1, isNextMonth: true },
  { date: 2, isNextMonth: true },
  { date: 3, isNextMonth: true },
  { date: 4, isNextMonth: true }
]
</script>

<template>
  <AppLayout>
    <div class="max-w-6xl mx-auto p-8 w-full">

      <!-- Header Section -->
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4">
        <div>
          <h2 class="text-3xl font-bold">交易流水</h2>
          <p class="text-slate-500">查看和管理所有财务流水</p>
        </div>
        <div class="flex items-center gap-4">
          <div class="flex items-center bg-slate-200/50 p-1 rounded-xl w-fit">
            <RouterLink to="/transactions" class="flex items-center gap-2 px-6 py-2 text-slate-500 text-sm font-semibold hover:text-primary transition-colors">
              <List :size="16" />
              流水视图
            </RouterLink>
            <button class="flex items-center gap-2 px-6 py-2 bg-white shadow-sm rounded-lg text-sm font-semibold">
              <Calendar :size="16" />
              日历视图
            </button>
          </div>
          <RouterLink to="/transactions/new" class="flex items-center gap-2 px-6 py-2 bg-primary text-white rounded-xl shadow-lg shadow-primary/20 text-sm font-bold hover:opacity-90 transition-opacity">
            <Plus :size="20" />
            新建交易
          </RouterLink>
        </div>
      </div>

      <!-- Calendar Header & Navigation -->
      <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden mb-4">
        <div class="flex items-center justify-between px-4 py-2.5 border-b border-slate-100">
          <div class="flex items-center gap-2.5">
            <h2 class="text-base font-bold text-slate-900">{{ currentYearMonth }}</h2>
            <div class="flex items-center bg-slate-100 rounded-lg p-0.5">
              <button class="p-0.5 hover:bg-white rounded-md transition-all shadow-none hover:shadow-sm" aria-label="上个月">
                <ChevronLeft :size="16" />
              </button>
              <button class="p-0.5 hover:bg-white rounded-md transition-all shadow-none hover:shadow-sm" aria-label="下个月">
                <ChevronRight :size="16" />
              </button>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <div class="flex items-center gap-2 border-r border-slate-100 pr-3">
              <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider">收入</span>
              <span class="text-xs font-bold text-emerald-600">+¥250.00</span>
            </div>
            <div class="flex items-center gap-2 border-r border-slate-100 pr-3">
              <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider">支出</span>
              <span class="text-xs font-bold text-rose-600">-¥12.00</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider">净额</span>
              <span class="text-xs font-bold text-slate-900">+¥238.00</span>
            </div>
          </div>
        </div>

        <!-- Calendar Grid -->
        <div class="grid grid-cols-7 border-b border-slate-100">
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">日</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">一</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">二</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">三</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">四</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">五</div>
          <div class="py-1.5 text-center text-[10px] font-bold text-slate-400 uppercase tracking-wider">六</div>
        </div>

        <div class="grid grid-cols-7">
          <CalendarCell
            v-for="(day, index) in calendarData"
            :key="index"
            :date="day.date"
            :income="day.income"
            :expense="day.expense"
            :is-today="day.isToday"
            :has-payment-due="day.hasPaymentDue"
            :is-next-month="day.isNextMonth"
          />
        </div>
      </div>

      <!-- Daily Summary Section -->
      <div class="mb-8">
        <TransactionList />
      </div>

    </div>
  </AppLayout>
</template>
