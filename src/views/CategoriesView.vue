<template>
  <AppLayout>
    <div class="max-w-6xl mx-auto px-8 py-5 w-full">
    <!-- Header -->
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
      <div class="flex items-end gap-3">
        <h2 class="text-3xl font-bold tracking-tight leading-none">分类管理</h2>
        <p class="text-sm text-muted-foreground leading-none pb-0.5">管理您的收入和支出分类</p>
      </div>
      <div class="flex gap-3">
        <Button @click="router.push('/categories/new')">
          <Plus class="h-4 w-4 mr-2" />
          添加分类
        </Button>
      </div>
    </header>

    <!-- Tabs -->
    <div class="flex border-b mb-5">
      <button
        v-for="tab in tabs"
        :key="tab.value"
        @click="activeTab = tab.value"
        :class="[
          'px-5 py-2.5 text-sm font-semibold transition-colors',
          activeTab === tab.value
            ? 'border-b-2 border-primary text-primary'
            : 'text-muted-foreground hover:text-foreground'
        ]"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Category List -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <section v-for="category in filteredCategories" :key="category.id" class="border rounded-lg p-4">
        <div class="flex items-center gap-2 pb-3 mb-3 border-b cursor-pointer hover:border-primary/50 transition-colors" @click="toggleCategory(category.id)">
          <div
            :class="[
              'w-8 h-8 rounded-lg flex items-center justify-center',
              category.colorClass
            ]"
          >
            <component :is="category.icon" class="h-4 w-4" />
          </div>
          <h4 class="text-base font-bold">{{ category.name }}</h4>
          <div class="flex items-center gap-1 ml-auto">
            <Button variant="ghost" size="icon" class="h-7 w-7" @click.stop="editCategory(category)">
              <Pencil class="h-3.5 w-3.5" />
            </Button>
            <Button variant="ghost" size="icon" class="h-7 w-7" @click.stop="deleteCategory(category.id)">
              <Trash2 class="h-3.5 w-3.5 text-destructive" />
            </Button>
              <ChevronDown
                :class="[
                  'h-4 w-4 text-muted-foreground transition-transform',
                  expandedCategories.has(category.id) ? 'rotate-180' : ''
                ]"
              />
          </div>
        </div>
        <div v-if="expandedCategories.has(category.id)" class="flex flex-wrap gap-2">
          <div
            v-for="sub in category.subcategories"
            :key="sub.id"
            class="group relative inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border bg-card hover:border-primary/50 hover:bg-accent/50 transition-colors cursor-pointer"
          >
            <component :is="sub.icon" class="h-3.5 w-3.5 text-muted-foreground" />
            <span class="text-sm font-medium">{{ sub.name }}</span>
            <GripVertical class="h-3 w-3 text-muted-foreground/50 opacity-0 group-hover:opacity-100 transition-opacity cursor-grab ml-0.5" />
          </div>
          <button
            @click="addSubcategory(category.id)"
            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border-2 border-dashed hover:border-primary/50 hover:bg-accent/50 text-muted-foreground hover:text-foreground transition-colors"
          >
            <PlusCircle class="h-3.5 w-3.5" />
            <span class="text-sm font-medium">添加</span>
          </button>
        </div>
      </section>
    </div>

    <!-- Tip -->
    <Card class="mt-8 border-amber-200 bg-amber-50 dark:bg-amber-950/20">
      <CardContent class="p-4 flex gap-3">
        <div class="bg-amber-100 dark:bg-amber-900/30 p-1.5 rounded-lg h-fit text-amber-600 dark:text-amber-400">
          <Lightbulb class="h-5 w-5" />
        </div>
        <div>
          <h4 class="text-amber-800 dark:text-amber-300 font-semibold text-sm mb-0.5">温馨提示</h4>
          <p class="text-amber-700/80 dark:text-amber-400/80 text-xs leading-relaxed">
            将分类组织成子分类可以帮助您更详细地了解支出习惯。使用拖动手柄可以在组内重新排序项目。
          </p>
        </div>
      </CardContent>
    </Card>

  </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/AppLayout.vue'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import {
  Plus,
  ChevronDown,
  Pencil,
  Trash2,
  GripVertical,
  PlusCircle,
  Lightbulb,
  UtensilsCrossed,
  Coffee,
  ShoppingBag,
  Car
} from 'lucide-vue-next'

const router = useRouter()

// State
const activeTab = ref('expense')
const expandedCategories = ref(new Set<string>(['1', '2']))

// Mock data
const tabs = [
  { label: '支出', value: 'expense' },
  { label: '收入', value: 'income' }
]

const mockCategories = ref([
  {
    id: '1',
    name: '餐饮美食',
    icon: UtensilsCrossed,
    colorClass: 'bg-orange-100 dark:bg-orange-500/20 text-orange-600 dark:text-orange-400',
    subcategories: [
      { id: '1-1', name: '日常餐饮', icon: UtensilsCrossed },
      { id: '1-2', name: '餐厅聚餐', icon: UtensilsCrossed },
      { id: '1-3', name: '咖啡店', icon: Coffee }
    ]
  },
  {
    id: '2',
    name: '交通出行',
    icon: Car,
    colorClass: 'bg-blue-100 dark:bg-blue-500/20 text-blue-600 dark:text-blue-400',
    subcategories: [
      { id: '2-1', name: '加油', icon: Car },
      { id: '2-2', name: '公共交通', icon: Car }
    ]
  },
  {
    id: '3',
    name: '购物消费',
    icon: ShoppingBag,
    colorClass: 'bg-purple-100 dark:bg-purple-500/20 text-purple-600 dark:text-purple-400',
    subcategories: [
      { id: '3-1', name: '服装', icon: ShoppingBag },
      { id: '3-2', name: '电子产品', icon: ShoppingBag }
    ]
  }
])

// Computed
const filteredCategories = computed(() => {
  return mockCategories.value
})

// Methods
const toggleCategory = (id: string) => {
  if (expandedCategories.value.has(id)) {
    expandedCategories.value.delete(id)
  } else {
    expandedCategories.value.add(id)
  }
}

const editCategory = (category: any) => {
  console.log('Edit category:', category)
}

const deleteCategory = (id: string) => {
  console.log('Delete category:', id)
}

const addSubcategory = (parentId: string) => {
  console.log('Add subcategory to:', parentId)
  router.push('/categories/new')
}
</script>
