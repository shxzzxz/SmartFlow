<template>
  <AppLayout>
    <Dialog :open="open" @update:open="closeModal">
      <DialogContent class="max-w-lg p-0 gap-0">
        <!-- Header with Type Selector -->
        <DialogHeader class="px-5 py-3 border-b">
          <div class="flex items-center gap-2 mb-3">
            <Tag class="text-primary w-5 h-5" />
            <DialogTitle class="text-lg font-bold">添加分类</DialogTitle>
          </div>
          <DialogDescription class="text-sm text-muted-foreground mb-3">
            创建新的收入或支出分类来更好地管理您的财务记录
          </DialogDescription>
          <div class="flex bg-secondary p-1 rounded-xl w-full">
            <button
              v-for="type in categoryTypes"
              :key="type.value"
              @click="form.type = type.value"
              :class="[
                'flex-1 py-2 px-4 rounded-lg text-sm font-semibold transition-colors',
                form.type === type.value
                  ? 'bg-background shadow-sm text-primary'
                  : 'text-muted-foreground hover:text-foreground'
              ]"
            >
              {{ type.label }}
            </button>
          </div>
        </DialogHeader>

        <div class="p-5 space-y-4">
          <div class="space-y-2">
            <Label>父分类</Label>
            <Select v-model="form.parentId">
              <SelectTrigger>
                <SelectValue placeholder="选择父分类（可选）" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">无（顶级分类）</SelectItem>
                <SelectItem v-for="cat in mockCategories" :key="cat.id" :value="cat.id">
                  {{ cat.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div class="space-y-2">
            <Label>分类名称</Label>
            <Input v-model="form.name" placeholder="例如：餐饮、咖啡、健身..." />
          </div>

          <div class="space-y-2">
            <Label>选择图标</Label>
            <div class="grid grid-cols-6 gap-2">
              <Button
                v-for="icon in iconOptions"
                :key="icon.name"
                :variant="form.icon === icon.name ? 'default' : 'outline'"
                size="icon"
                @click="form.icon = icon.name"
              >
                <component :is="icon.component" class="h-5 w-5" />
              </Button>
            </div>
          </div>

          <div class="space-y-2">
            <Label>主题颜色</Label>
            <div class="flex flex-wrap gap-3">
              <button
                v-for="color in colorOptions"
                :key="color.value"
                @click="form.color = color.value"
                :class="[
                  'w-6 h-6 rounded-full ring-2 ring-offset-2',
                  color.class,
                  form.color === color.value ? 'ring-primary' : 'ring-transparent'
                ]"
              />
            </div>
          </div>
        </div>

        <DialogFooter class="p-4 border-t">
          <Button variant="outline" class="flex-1" @click="closeModal">取消</Button>
          <Button class="flex-1" @click="saveCategory">保存分类</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/AppLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import {
  Tag,
  UtensilsCrossed,
  Car,
  ShoppingBag,
  Home,
  Dumbbell,
  Film,
  CreditCard,
  Heart,
  GraduationCap,
  Plane,
  PartyPopper,
  Coffee
} from 'lucide-vue-next'

const router = useRouter()
const open = ref(false)

const form = ref({
  type: 'expense',
  parentId: 'none',
  name: '',
  icon: 'UtensilsCrossed',
  color: 'orange'
})

// 注意：分类在UI层面展示为"收入分类"和"支出分类"
// 但在底层会计模型中，它们本质上是 INCOME 和 EXPENSE 类型的账户
const categoryTypes = [
  { label: '支出', value: 'expense' },
  { label: '收入', value: 'income' }
]

const iconOptions = [
  { name: 'UtensilsCrossed', component: UtensilsCrossed },
  { name: 'Car', component: Car },
  { name: 'ShoppingBag', component: ShoppingBag },
  { name: 'Home', component: Home },
  { name: 'Dumbbell', component: Dumbbell },
  { name: 'Film', component: Film },
  { name: 'CreditCard', component: CreditCard },
  { name: 'Heart', component: Heart },
  { name: 'GraduationCap', component: GraduationCap },
  { name: 'Plane', component: Plane },
  { name: 'PartyPopper', component: PartyPopper },
  { name: 'Coffee', component: Coffee }
]

const colorOptions = [
  { value: 'red', class: 'bg-red-500' },
  { value: 'orange', class: 'bg-orange-500' },
  { value: 'yellow', class: 'bg-yellow-500' },
  { value: 'green', class: 'bg-green-500' },
  { value: 'blue', class: 'bg-blue-500' },
  { value: 'purple', class: 'bg-purple-500' }
]

const mockCategories = ref([
  { id: '1', name: '餐饮美食' },
  { id: '2', name: '交通出行' },
  { id: '3', name: '购物消费' }
])

onMounted(() => {
  open.value = true
})

const closeModal = () => {
  open.value = false
  setTimeout(() => {
    router.back()
  }, 200)
}

const saveCategory = () => {
  console.log('Save category:', form.value)
  closeModal()
}
</script>
