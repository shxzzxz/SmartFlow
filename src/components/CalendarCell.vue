<script setup lang="ts">
import { CreditCard } from 'lucide-vue-next'

interface Props {
  date: number
  income?: number
  expense?: number
  isToday?: boolean
  hasPaymentDue?: boolean
  isNextMonth?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  income: 0,
  expense: 0,
  isToday: false,
  hasPaymentDue: false,
  isNextMonth: false
})

const hasTransaction = props.income > 0 || props.expense > 0
</script>

<template>
  <div
    :class="[
      'p-1.5 border-r border-b border-slate-100 h-14 flex flex-col justify-between transition-colors',
      isToday ? 'border-primary/30 bg-primary/5' : 'hover:bg-slate-50',
      isNextMonth ? 'bg-slate-50 opacity-40' : ''
    ]"
  >
    <div v-if="isToday" class="flex justify-between items-center">
      <span class="text-[9px] font-bold text-primary uppercase">今天</span>
      <CreditCard v-if="hasPaymentDue" :size="12" class="text-primary" />
    </div>
    <div v-else class="flex justify-between items-center">
      <span :class="['text-xs font-semibold', isNextMonth ? 'text-slate-400 font-medium' : 'text-slate-500']">{{ date }}</span>
      <CreditCard v-if="hasPaymentDue" :size="12" class="text-slate-400" />
    </div>

    <div v-if="hasTransaction" class="grid grid-cols-3 text-[10px] font-bold">
      <p></p>
      <p class="text-emerald-600 text-center">+{{ income }}</p>
      <p class="text-rose-600 text-right">-{{ expense }}</p>
    </div>
  </div>
</template>
