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
