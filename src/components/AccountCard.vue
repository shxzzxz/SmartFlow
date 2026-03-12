<template>
  <Card class="hover:shadow-md transition-shadow">
    <CardContent class="px-2 py-1">
      <div class="flex gap-2.5 mb-1.5">
        <div :class="['w-11 h-11 rounded-xl flex items-center justify-center shrink-0', iconBgClass]">
          <component :is="icon" :class="['h-5 w-5', iconColorClass]" />
        </div>
        <div class="flex-1 flex flex-col items-end justify-center min-w-0">
          <span class="text-xs font-bold text-muted-foreground truncate max-w-full leading-tight">{{ name }}</span>
          <div class="text-right">
            <h5 :class="['text-base font-black leading-tight', balanceClass]">{{ balance }}</h5>
          </div>
        </div>
      </div>
      <slot />
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import type { Component } from 'vue'
import { Card, CardContent } from '@/components/ui/card'

withDefaults(defineProps<{
  icon: Component
  iconBgClass?: string
  iconColorClass?: string
  name: string
  balance: string
  balanceClass?: string
}>(), {})
</script>
