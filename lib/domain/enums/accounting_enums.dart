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

/// 计息方式（与利率单位 [InterestRatePeriod] 不同：
/// 后者表达"输入的利率值按年/月/日折算"，前者决定"每期利息怎么算"）。
/// - [daily]：每期利息 = 余额 × 日利率 × 实际天数；
///   等额本息下每期还款额按现金流折现求解。
/// - [monthly]：每期利息 = 余额 × 月利率，与天数无关；
///   等额本息下用标准月供公式。
enum InterestAccrualMethod { daily, monthly }

enum InstallmentContractStatus { active, settled, closed }

enum InstallmentScheduleStatus { pending, paid, skipped }

enum InstallmentRepaymentType { regular, extraPrincipal, earlySettlement }
