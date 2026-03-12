<template>
  <AppLayout>
    <div class="max-w-6xl mx-auto px-8 py-5 w-full">
    <!-- Header -->
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
      <div class="flex items-end gap-3">
        <h2 class="text-3xl font-bold tracking-tight leading-none">账户管理</h2>
        <p class="text-sm text-muted-foreground leading-none pb-0.5">高效管理您的资产和负债</p>
      </div>
      <div class="flex gap-3">
        <Button @click="handleTransfer">
          <ArrowLeftRight class="h-4 w-4 mr-2" />
          转账
        </Button>
        <Button variant="outline" @click="handleAdjustment">
          <FileEdit class="h-4 w-4 mr-2" />
          余额调整
        </Button>
      </div>
    </header>

    <!-- Net Worth Summary -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
      <div class="bg-primary p-4 rounded-xl text-primary-foreground flex flex-col gap-0.5">
        <span class="text-xs font-medium text-primary-foreground/80">总净资产</span>
        <span class="text-xl font-bold">¥{{ formatCurrency(netWorth.total) }}</span>
        <span class="text-[11px] font-medium text-primary-foreground/70 bg-primary-foreground/15 px-1.5 py-0.5 rounded-full w-fit flex items-center gap-1 mt-0.5">
          <TrendingUp :size="11" /> +2.4%
        </span>
      </div>
      <div class="bg-card p-4 rounded-xl border flex flex-col gap-0.5">
        <span class="text-xs font-medium text-muted-foreground">总资产</span>
        <span class="text-xl font-bold text-emerald-600">¥{{ formatCurrency(netWorth.assets) }}</span>
        <span class="text-[11px] text-muted-foreground mt-0.5">待报销 ¥1,200 / 已报销 ¥8,500</span>
      </div>
      <div class="bg-card p-4 rounded-xl border flex flex-col gap-0.5">
        <span class="text-xs font-medium text-muted-foreground">总负债</span>
        <span class="text-xl font-bold text-rose-600">-¥{{ formatCurrency(netWorth.liabilities) }}</span>
        <span class="text-[11px] text-muted-foreground mt-0.5">手续费 ¥150 / 利息 ¥420</span>
      </div>
      <div class="bg-card p-4 rounded-xl border flex flex-col gap-0.5">
        <span class="text-xs font-medium text-muted-foreground">投资收益</span>
        <span class="text-xl font-bold">¥{{ formatCurrency(netWorth.returns) }}</span>
        <span class="text-[11px] text-muted-foreground mt-0.5">盈利 ¥15,000 / 亏损 -¥2,550</span>
      </div>
    </div>

    <!-- Sections Container -->
    <div class="space-y-4">
      <!-- Assets -->
      <section>
        <div class="flex items-center gap-2 border-b pb-1.5 mb-3">
          <Landmark class="h-5 w-5 text-green-500" />
          <h4 class="text-lg font-bold">资产</h4>
          <Button variant="ghost" size="icon" class="ml-auto" @click="addAccount()">
            <Plus class="h-5 w-5" />
          </Button>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
          <AccountCard
            v-for="account in assetAccounts"
            :key="account.id"
            :icon="account.icon"
            :icon-bg-class="account.bgClass"
            :icon-color-class="account.iconClass"
            :name="account.name"
            :balance="`¥${formatCurrency(account.balance)}`"
            balance-class="text-green-500"
          >
            <div class="flex mt-1">
              <span class="px-2 py-0.5 text-[10px] text-muted-foreground">{{ account.description }}</span>
            </div>
          </AccountCard>
        </div>
      </section>

      <!-- Liabilities -->
      <section>
        <div class="flex items-center gap-2 border-b pb-1.5 mb-3">
          <CreditCard class="h-5 w-5 text-red-500" />
          <h4 class="text-lg font-bold">负债</h4>
          <Button variant="ghost" size="icon" class="ml-auto" @click="addAccount()">
            <Plus class="h-5 w-5" />
          </Button>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
          <AccountCard
            v-for="account in liabilityAccounts"
            :key="account.id"
            :icon="account.icon"
            :icon-bg-class="account.bgClass"
            :icon-color-class="account.iconClass"
            :name="account.name"
            :balance="`-¥${formatCurrency(Math.abs(account.balance))}`"
            balance-class="text-red-500"
          >
            <div class="mb-1.5">
              <div class="w-full bg-secondary h-1 rounded-full overflow-hidden">
                <div class="bg-primary h-full" :style="{ width: `${account.usage}%` }"></div>
              </div>
            </div>
            <div class="flex justify-between items-center text-[10px] text-muted-foreground">
              <span>{{ account.dueDate }}</span>
              <span>{{ account.type }}</span>
              <span class="font-bold text-foreground/70">{{ account.limit }}</span>
            </div>
          </AccountCard>
        </div>
      </section>

      <!-- Equity -->
      <section>
        <div class="flex items-center gap-2 border-b pb-1.5 mb-3">
          <Wallet class="h-5 w-5 text-blue-500" />
          <h4 class="text-lg font-bold">
            所有者权益
            <span class="text-xs font-normal text-muted-foreground ml-1">(只读)</span>
          </h4>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
          <AccountCard
            v-for="account in equityAccounts"
            :key="account.id"
            :icon="account.icon"
            icon-bg-class="bg-secondary"
            icon-color-class="text-muted-foreground"
            :name="account.name"
            :balance="`¥${formatCurrency(account.balance)}`"
          >
            <div class="flex mt-1">
              <span class="px-2 py-0.5 text-[10px] text-muted-foreground">{{ account.description }}</span>
            </div>
          </AccountCard>
        </div>
      </section>
    </div>
  </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/AppLayout.vue'
import AccountCard from '@/components/AccountCard.vue'
import { Button } from '@/components/ui/button'
import {
  Plus,
  ArrowLeftRight,
  FileEdit,
  TrendingUp,
  Landmark,
  CreditCard,
  Wallet,
  Banknote,
  Receipt,
  TrendingUpIcon,
  Home,
  CircleDollarSign,
  User
} from 'lucide-vue-next'

const router = useRouter()

// Mock data
const netWorth = ref({
  total: 124500,
  assets: 142000,
  liabilities: 17500,
  returns: 12450
})

const assetAccounts = ref([
  {
    id: '1',
    name: '现金钱包',
    balance: 1250,
    icon: Banknote,
    bgClass: 'bg-secondary',
    iconClass: 'text-muted-foreground',
    description: '实体钱包 • 随取随用'
  },
  {
    id: '2',
    name: '报销',
    balance: 850,
    icon: Receipt,
    bgClass: 'bg-orange-50 dark:bg-orange-900/20',
    iconClass: 'text-orange-600 dark:text-orange-400',
    description: '待结算费用'
  },
  {
    id: '3',
    name: '理财投资',
    balance: 25400,
    icon: TrendingUpIcon,
    bgClass: 'bg-purple-50 dark:bg-purple-900/20',
    iconClass: 'text-purple-600 dark:text-purple-400',
    description: '证券、基金账户'
  }
])

const liabilityAccounts = ref([
  {
    id: '4',
    name: 'Visa 白金卡',
    balance: -4250,
    icon: CreditCard,
    bgClass: 'bg-red-50 dark:bg-red-900/20',
    iconClass: 'text-red-500',
    usage: 42,
    dueDate: '每月15日',
    type: '主打消费',
    limit: '¥5,750'
  },
  {
    id: '5',
    name: '住房按揭贷款',
    balance: -12500,
    icon: Home,
    bgClass: 'bg-orange-50 dark:bg-orange-900/20',
    iconClass: 'text-orange-600',
    usage: 65,
    dueDate: '每月01日',
    type: '低息固贷',
    limit: '65%'
  }
])

const equityAccounts = ref([
  {
    id: '6',
    name: '期初余额',
    balance: 100000,
    icon: CircleDollarSign,
    description: '系统初始资金'
  },
  {
    id: '7',
    name: '所有者权益',
    balance: 7000,
    icon: User,
    description: '累计收支盈余'
  }
])

// Methods
const formatCurrency = (value: number) => {
  return value.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const handleTransfer = () => {
  console.log('Handle transfer')
}

const handleAdjustment = () => {
  console.log('Handle adjustment')
}

const addAccount = () => {
  router.push('/accounts/new')
}
</script>
