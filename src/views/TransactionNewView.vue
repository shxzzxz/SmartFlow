<script setup lang="ts">
import { PlusCircle, Tag, FileText, Wallet, Calendar, ArrowRight, EyeOff, PiggyBank } from 'lucide-vue-next'
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/AppLayout.vue'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog'

const router = useRouter()
const amount = ref('0.00')
const txType = ref('expense')
const open = ref(false)

onMounted(() => {
  open.value = true
})

const closeModal = () => {
  open.value = false
  setTimeout(() => {
    router.back()
  }, 200)
}
</script>

<template>
  <AppLayout>
    <Dialog :open="open" @update:open="closeModal">
      <DialogContent class="w-[90vw] sm:w-[80vw] md:w-[70vw] lg:w-[60vw] xl:w-[50vw] max-w-130 p-0 gap-0 max-h-[90vh] overflow-y-auto">
        <!-- Header -->
        <DialogHeader class="px-4 sm:px-5 py-2.5 sm:py-3 border-b border-slate-100">
          <div class="flex items-center gap-2">
            <PlusCircle class="text-primary w-5 h-5" />
            <DialogTitle class="text-base sm:text-lg font-bold tracking-tight">新增交易</DialogTitle>
          </div>
          <DialogDescription class="text-sm text-muted-foreground mt-1">
            记录您的收入、支出或转账交易
          </DialogDescription>
        </DialogHeader>

        <!-- Type Selector -->
        <div class="px-4 sm:px-5 py-2.5 sm:py-3">
          <div class="flex p-0.5 bg-slate-100 rounded-lg">
            <label class="flex-1 cursor-pointer">
              <input v-model="txType" value="expense" class="sr-only peer" name="tx-type" type="radio" />
              <div class="py-1.5 text-center rounded-md text-xs font-semibold peer-checked:bg-white peer-checked:text-primary peer-checked:shadow-sm text-slate-500 transition-all">
                支出
              </div>
            </label>
            <label class="flex-1 cursor-pointer">
              <input v-model="txType" value="income" class="sr-only peer" name="tx-type" type="radio" />
              <div class="py-1.5 text-center rounded-md text-xs font-semibold peer-checked:bg-white peer-checked:text-primary peer-checked:shadow-sm text-slate-500 transition-all">
                收入
              </div>
            </label>
            <label class="flex-1 cursor-pointer">
              <input v-model="txType" value="refund" class="sr-only peer" name="tx-type" type="radio" />
              <div class="py-1.5 text-center rounded-md text-xs font-semibold peer-checked:bg-white peer-checked:text-primary peer-checked:shadow-sm text-slate-500 transition-all">
                退款
              </div>
            </label>
            <label class="flex-1 cursor-pointer">
              <input v-model="txType" value="reimburse" class="sr-only peer" name="tx-type" type="radio" />
              <div class="py-1.5 text-center rounded-md text-xs font-semibold peer-checked:bg-white peer-checked:text-primary peer-checked:shadow-sm text-slate-500 transition-all">
                报销
              </div>
            </label>
            <label class="flex-1 cursor-pointer">
              <input v-model="txType" value="transfer" class="sr-only peer" name="tx-type" type="radio" />
              <div class="py-1.5 text-center rounded-md text-xs font-semibold peer-checked:bg-white peer-checked:text-primary peer-checked:shadow-sm text-slate-500 transition-all">
                转账
              </div>
            </label>
          </div>
        </div>

        <!-- Amount Display -->
        <div class="px-4 sm:px-5 text-center bg-slate-50/50 py-3 sm:py-4">
          <div class="text-slate-500 text-xs font-medium mb-1 uppercase tracking-wider">金额</div>
          <div class="relative inline-block">
            <span class="absolute -left-5 sm:-left-6 top-1/2 -translate-y-1/2 text-lg sm:text-xl font-bold text-slate-400">¥</span>
            <input
              v-model="amount"
              class="bg-transparent border-none text-3xl sm:text-4xl font-bold text-slate-900 focus:ring-0 p-0 text-center w-full max-w-[200px] sm:max-w-[250px]"
              placeholder="0.00"
              type="text"
              aria-label="交易金额"
            />
          </div>
        </div>

        <!-- Form Content -->
        <div class="px-4 sm:px-5 py-2.5 sm:py-3 space-y-2.5 sm:space-y-3">
          <!-- Category Selector -->
          <button class="w-full flex items-center justify-between p-2.5 sm:p-3 bg-white border border-slate-200 rounded-lg hover:border-primary/50 cursor-pointer transition-colors group" aria-label="选择分类">
            <div class="flex items-center gap-2.5 sm:gap-3">
              <div class="w-7 sm:w-8 h-7 sm:h-8 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                <Tag class="w-3.5 sm:w-4 h-3.5 sm:h-4" />
              </div>
              <div>
                <p class="text-[10px] text-slate-500 font-medium uppercase tracking-tight">分类</p>
                <p class="text-xs sm:text-sm font-semibold">选择分类</p>
              </div>
            </div>
            <ArrowRight class="text-slate-400 group-hover:text-primary w-3.5 sm:w-4 h-3.5 sm:h-4" />
          </button>

          <div class="space-y-2">
            <div class="grid grid-cols-2 gap-2">
              <!-- From Account -->
              <button class="flex items-center gap-1.5 sm:gap-2 p-2 sm:p-2.5 border border-slate-200 rounded-lg hover:border-primary/30 cursor-pointer bg-white" aria-label="选择来源账户">
                <div class="w-6 sm:w-7 h-6 sm:h-7 rounded-full bg-blue-500 flex items-center justify-center text-white shrink-0">
                  <Wallet class="w-3 sm:w-3.5 h-3 sm:h-3.5" />
                </div>
                <div class="overflow-hidden">
                  <p class="text-[9px] text-slate-500 uppercase font-bold">来源账户</p>
                  <p class="text-xs font-bold truncate">支付宝</p>
                </div>
              </button>

              <!-- Date Picker -->
              <button class="flex items-center gap-1.5 sm:gap-2 p-2 sm:p-2.5 border border-slate-200 rounded-lg hover:border-primary/30 cursor-pointer bg-white" aria-label="选择日期">
                <div class="w-6 sm:w-7 h-6 sm:h-7 rounded-full bg-slate-100 flex items-center justify-center text-slate-600 shrink-0">
                  <Calendar class="w-3 sm:w-3.5 h-3 sm:h-3.5" />
                </div>
                <div>
                  <p class="text-[9px] text-slate-500 uppercase font-bold">日期</p>
                  <p class="text-xs font-bold">今天, 14:30</p>
                </div>
              </button>
            </div>

            <!-- To Account (Transfer Only) -->
            <button class="w-full flex items-center gap-1.5 sm:gap-2 p-2 sm:p-2.5 border border-slate-200 rounded-lg hover:border-primary/30 cursor-pointer bg-slate-50/50 border-dashed" aria-label="选择目标账户">
              <div class="w-6 sm:w-7 h-6 sm:h-7 rounded-full bg-emerald-500 flex items-center justify-center text-white shrink-0">
                <ArrowRight class="w-3 sm:w-3.5 h-3 sm:h-3.5" />
              </div>
              <div class="overflow-hidden flex-1">
                <p class="text-[9px] text-slate-500 uppercase font-bold">目标账户（仅转账）</p>
                <p class="text-xs font-bold truncate">选择目标账户</p>
              </div>
              <ArrowRight class="text-slate-400 w-3 sm:w-3.5 h-3 sm:h-3.5" />
            </button>
          </div>

          <!-- Tags and Remarks -->
          <div class="space-y-2">
            <div class="flex gap-2">
              <button class="flex-1 flex items-center justify-center gap-1.5 px-2.5 py-2 rounded-lg border border-primary bg-primary/10 text-primary text-[11px] font-bold transition-all shadow-sm hover:bg-primary/20" aria-label="不计预算">
                <EyeOff class="w-3.5 h-3.5" />
                不计预算
              </button>
              <button class="flex-1 flex items-center justify-center gap-1.5 px-2.5 py-2 rounded-lg border border-slate-200 text-slate-600 text-[11px] font-bold hover:border-primary/50 hover:text-primary transition-all bg-white" aria-label="不计收入">
                <PiggyBank class="w-3.5 h-3.5" />
                不计收入
              </button>
            </div>
          </div>

          <div class="space-y-2.5 sm:space-y-3 pt-2 border-t border-slate-100">
            <div class="flex items-center gap-2 border-b border-slate-100 pb-1.5">
              <Tag class="text-slate-400 w-4 h-4" />
              <input
                class="flex-1 bg-transparent border-none focus:ring-0 text-xs py-1"
                placeholder="添加标签（午餐、办公...）"
                type="text"
                aria-label="添加标签"
              />
            </div>
            <div class="flex items-center gap-2 border-b border-slate-100 pb-1.5">
              <FileText class="text-slate-400 w-4 h-4" />
              <input
                class="flex-1 bg-transparent border-none focus:ring-0 text-xs py-1"
                placeholder="添加备注..."
                type="text"
                aria-label="添加备注"
              />
            </div>
          </div>
        </div>

        <!-- Footer Actions -->
        <footer class="p-4 sm:p-5 flex gap-2 border-t border-slate-100 bg-slate-50/50">
          <button class="flex-1 py-2.5 px-3 border border-primary text-primary font-bold rounded-lg hover:bg-primary/5 transition-colors text-xs" aria-label="保存并继续">
            保存并继续
          </button>
          <button class="flex-1 py-2.5 px-3 bg-primary text-white font-bold rounded-lg hover:bg-primary/90 shadow-lg shadow-primary/20 transition-all text-xs" aria-label="快速保存">
            快速保存
          </button>
        </footer>
      </DialogContent>
    </Dialog>
  </AppLayout>
</template>
