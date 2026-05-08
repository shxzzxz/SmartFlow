enum AccountType {
  asset,
  liability,
  equity,
  income,
  expense;
}

enum AccountSubtype {
  cash,
  bankCard,
  thirdParty,
  investment,
  reimbursement,
  creditCard,
  loan,
  consumerCredit;
}

enum EntryDirection {
  debit,
  credit;
}

enum BusinessPurpose {
  dailyExpense,
  dailyIncome,
  transfer,
  refund,
  reimbursementAdvance,
  reimbursementReceipt,
  reimbursementClose,
  debtRepayment,
  borrowing,
  openingBalance,
  balanceAdjustment;
}

enum MutationKind {
  original,
  correction,
  reversal;
}

enum MutationReason {
  correction,
  delete;
}

enum BusinessState {
  current,
  replaced,
  canceled,
  compensation;
}

enum TransactionDetailType {
  primaryExpense,
  primaryIncome,
  transferMain,
  transferFee,
  refundMain,
  reimbursementAdvanceMain,
  reimbursementReceiptMain,
  reimbursementCloseMain,
  reimbursementGapExpense,
  reimbursementGapIncome,
  repaymentPrincipal,
  repaymentInterest,
  repaymentFee,
  borrowingPrincipal,
  openingBalanceMain,
  balanceAdjustmentMain;
}

enum SourceKind {
  manual,
  import,
  auto;
}

enum SystemKey {
  openingBalance,
  reimbursementGapIncome,
  importFallback;
}
