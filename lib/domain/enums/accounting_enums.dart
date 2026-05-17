enum AccountType { asset, liability, equity, income, expense }

enum AccountSubtype {
  cash,
  bankCard,
  thirdParty,
  investment,
  reimbursement,
  creditCard,
  loan,
  consumerCredit,
}

enum EntryDirection { debit, credit }

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
  balanceAdjustment,
}

enum MutationKind { original, correction, reversal }

enum MutationReason { correction, delete }

enum BusinessState { current, replaced, canceled, compensation }

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
  repaymentDiscount,
  borrowingPrincipal,
  openingBalanceMain,
  balanceAdjustmentMain,
}

enum SourceKind { manual, import, auto }

enum SystemKey {
  openingBalance,
  reimbursementGapIncome,
  debtInterestExpense,
  debtFeeExpense,
  discountIncome,
  lendingExpense,
  borrowingIncome,
  importFallback,
}

enum AccountSource { builtin, user, import }

enum InstallmentSourceType { disbursement, billConversion }

enum InstallmentRepaymentMethod {
  equalInstallment,
  equalPrincipal,
  interestFirst,
  flatFee,
  custom,
}

enum InterestRatePeriod { annual, monthly, daily }

enum InstallmentContractStatus { active, settled, closed }

enum InstallmentScheduleStatus { pending, paid, skipped }

enum InstallmentRepaymentType { regular, extraPrincipal, earlySettlement }
