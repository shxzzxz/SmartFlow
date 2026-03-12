<template>
  <AppLayout>
    <Dialog :open="open" @update:open="closeModal">
      <DialogContent class="w-[95vw] sm:max-w-lg p-0 gap-0 max-h-[90vh] flex flex-col">
        <!-- Header -->
        <DialogHeader class="px-5 py-3 border-b">
          <div class="flex items-center gap-2">
            <Wallet class="text-primary w-5 h-5" />
            <DialogTitle class="text-lg font-bold">添加账户</DialogTitle>
          </div>
          <DialogDescription class="text-sm text-muted-foreground mt-2">
            创建新的资产或负债账户来管理您的财务
          </DialogDescription>
        </DialogHeader>

        <div class="flex-1 overflow-y-auto px-4 py-6 sm:px-6">
          <div class="space-y-6">
            <!-- Account Details Section -->
            <section class="space-y-4">
              <!-- Account Type Chips -->
              <div>
                <Label class="mb-2">账户类型</Label>
                <div class="flex flex-wrap gap-2">
                  <Button
                    v-for="type in accountTypes"
                    :key="type.value"
                    :variant="form.accountType === type.value ? 'default' : 'outline'"
                    @click="form.accountType = type.value"
                    class="rounded-full"
                  >
                    <component :is="type.icon" class="h-4 w-4 mr-2" />
                    {{ type.label }}
                  </Button>
                </div>
              </div>

              <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                <div class="space-y-2">
                  <Label>账户名称</Label>
                  <Input v-model="form.name" placeholder="例如：主活期账户" />
                </div>
                <div class="space-y-2">
                  <Label>初始余额 / 当前债务</Label>
                  <div class="relative">
                    <span class="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground font-medium">¥</span>
                    <Input v-model="form.balance" type="number" class="pl-8" placeholder="0.00" />
                  </div>
                </div>
                <div class="space-y-2">
                  <Label>币种</Label>
                  <Select v-model="form.currency">
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="CNY">CNY - 人民币</SelectItem>
                      <SelectItem value="USD">USD - 美元</SelectItem>
                      <SelectItem value="EUR">EUR - 欧元</SelectItem>
                      <SelectItem value="GBP">GBP - 英镑</SelectItem>
                      <SelectItem value="JPY">JPY - 日元</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <!-- Appearance Settings -->
              <div class="space-y-4">
                <div class="space-y-2">
                  <Label>账户图标</Label>
                  <div class="flex flex-wrap gap-2">
                    <Button
                      v-for="icon in iconOptions"
                      :key="icon.name"
                      :variant="form.icon === icon.name ? 'default' : 'outline'"
                      size="icon"
                      class="w-10 h-10"
                      @click="form.icon = icon.name"
                    >
                      <component :is="icon.component" class="h-5 w-5" />
                    </Button>
                  </div>
                </div>
                <div class="space-y-2">
                  <Label>主题颜色</Label>
                  <div class="flex flex-wrap gap-2">
                    <button
                      v-for="color in colorOptions"
                      :key="color"
                      @click="form.color = color"
                      :class="[
                        'w-8 h-8 rounded-lg transition-all',
                        color,
                        form.color === color ? 'ring-2 ring-offset-2 ring-primary' : 'hover:scale-105'
                      ]"
                    />
                  </div>
                </div>
              </div>
            </section>

            <!-- Advanced Fields (Credit/Liability Section) -->
            <Card v-if="form.accountType === 'liability'" class="border-primary/20 bg-primary/5">
              <CardContent class="p-5">
                <div class="flex items-center gap-2 mb-3">
                  <Info class="h-5 w-5 text-primary" />
                  <h3 class="font-semibold">债务详情</h3>
                </div>
                <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                  <div class="space-y-2">
                    <Label>账单日</Label>
                    <Input v-model="form.billingDate" type="number" min="1" max="31" placeholder="例如：1" />
                  </div>
                  <div class="space-y-2">
                    <Label>还款日</Label>
                    <Input v-model="form.paymentDate" type="number" min="1" max="31" placeholder="例如：20" />
                  </div>
                  <div class="space-y-2">
                    <Label>信用额度</Label>
                    <Input v-model="form.creditLimit" type="number" placeholder="¥ 5,000" />
                  </div>
                </div>
              </CardContent>
            </Card>

            <div class="space-y-2">
              <Label>备注</Label>
              <Input
                v-model="form.notes"
                placeholder="添加账号、卡尾号或具体备注..."
              />
            </div>
          </div>
        </div>

        <!-- Footer Actions -->
        <DialogFooter class="px-4 py-3 sm:px-6 sm:py-4 flex gap-3 border-t bg-muted/30">
          <Button variant="outline" class="flex-1 sm:flex-none sm:min-w-24" @click="closeModal">取消</Button>
          <Button class="flex-1" @click="handleSave">保存账户</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/AppLayout.vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import {
  Wallet,
  Banknote,
  Landmark,
  Home,
  Car,
  ShoppingBag,
  Plane,
  UtensilsCrossed,
  Dumbbell,
  GraduationCap,
  MoreHorizontal,
  Info
} from 'lucide-vue-next'

const router = useRouter()
const open = ref(false)

// Form state
const form = ref({
  accountType: 'asset',
  name: '',
  currency: 'CNY',
  balance: '',
  billingDate: '',
  paymentDate: '',
  creditLimit: '',
  notes: '',
  icon: 'Home',
  color: 'bg-gradient-to-br from-primary to-orange-600'
})

// Options
const accountTypes = [
  { label: '资金账户', value: 'asset', icon: Banknote },
  { label: '债务账户', value: 'liability', icon: Landmark }
]

const iconOptions = [
  { name: 'Home', component: Home },
  { name: 'Car', component: Car },
  { name: 'ShoppingBag', component: ShoppingBag },
  { name: 'Plane', component: Plane },
  { name: 'UtensilsCrossed', component: UtensilsCrossed },
  { name: 'Dumbbell', component: Dumbbell },
  { name: 'GraduationCap', component: GraduationCap },
  { name: 'MoreHorizontal', component: MoreHorizontal }
]

const colorOptions = [
  'bg-gradient-to-br from-primary to-orange-600',
  'bg-gradient-to-br from-blue-500 to-blue-600',
  'bg-gradient-to-br from-green-500 to-green-600',
  'bg-gradient-to-br from-purple-500 to-purple-600',
  'bg-gradient-to-br from-rose-500 to-rose-600',
  'bg-gradient-to-br from-amber-500 to-amber-600',
  'bg-gradient-to-br from-teal-500 to-teal-600'
]

onMounted(() => {
  open.value = true
})

// Methods
const closeModal = () => {
  open.value = false
  setTimeout(() => {
    router.back()
  }, 200)
}

const handleSave = () => {
  console.log('Save account:', form.value)
  closeModal()
}
</script>
