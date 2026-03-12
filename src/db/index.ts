import Dexie, { type Table } from 'dexie'
import type { Account, Transaction, Entry } from '@/types'

export class SmartFlowDB extends Dexie {
  accounts!: Table<Account, number>
  transactions!: Table<Transaction, number>
  entries!: Table<Entry, number>

  constructor() {
    super('SmartFlowDB')
    this.version(1).stores({
      accounts: '++id, type, parentId',
      transactions: '++id, txType, txTime, source, parentTxId',
      entries: '++id, transactionId, accountId',
    })
  }
}

export const db = new SmartFlowDB()
