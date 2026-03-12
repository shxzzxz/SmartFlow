export type AccountType = 'ASSET' | 'LIABILITY' | 'EQUITY' | 'INCOME' | 'EXPENSE'

export type TxType = 'EXPENSE' | 'INCOME' | 'TRANSFER' | 'REFUND' | 'ADJUSTMENT'

export type FlowDirection = 'DEBIT' | 'CREDIT'

export type DataSource = 'MANUAL' | 'IMPORT' | 'AUTO'

export interface Account {
  id?: number
  name: string
  type: AccountType
  parentId?: number | null
  currency: string
  balance: number
  iconUrl?: string | null
  billingDay?: number | null
  repaymentDay?: number | null
  isHidden: boolean
  createdAt: Date
}

export interface Transaction {
  id?: number
  txType: TxType
  amount: number
  originalAmount?: number | null
  txTime: Date
  payee?: string | null
  description?: string | null
  parentTxId?: number | null
  source: DataSource
  createdAt: Date
}

export interface Entry {
  id?: number
  transactionId: number
  accountId: number
  flowDirection: FlowDirection
  amount: number
  createdAt: Date
}
