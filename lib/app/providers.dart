import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/database/database_provider.dart';
import '../data/repositories/drift_account_repository.dart';
import '../data/repositories/drift_financial_metrics_repository.dart';
import '../data/repositories/drift_posting_repository.dart';
import '../data/repositories/drift_system_account_resolver.dart';
import '../data/repositories/drift_transaction_query_repository.dart';
import '../domain/entities/account.dart';
import '../domain/enums/accounting_enums.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/financial_metrics_repository.dart';
import '../domain/repositories/posting_repository.dart';
import '../domain/repositories/system_account_resolver.dart';
import '../domain/repositories/transaction_query_repository.dart';
import '../domain/services/account_service.dart';
import '../domain/services/category_service.dart';
import '../domain/services/financial_metrics_service.dart';
import '../domain/services/posting_service.dart';
import '../domain/services/transaction_query_service.dart';
import '../domain/services/transaction_service.dart';
import '../core/time/month_key.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SystemAccountResolver systemAccountResolver(Ref ref) {
  return DriftSystemAccountResolver(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return DriftAccountRepository(
    ref.watch(appDatabaseProvider),
    systemAccounts: ref.watch(systemAccountResolverProvider),
  );
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return DriftAccountRepository(
    ref.watch(appDatabaseProvider),
    systemAccounts: ref.watch(systemAccountResolverProvider),
  );
}

@Riverpod(keepAlive: true)
PostingRepository postingRepository(Ref ref) {
  return DriftPostingRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TransactionQueryRepository transactionQueryRepository(Ref ref) {
  return DriftTransactionQueryRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
FinancialMetricsRepository financialMetricsRepository(Ref ref) {
  return DriftFinancialMetricsRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) {
  return AccountServiceImpl(ref.watch(accountRepositoryProvider));
}

@Riverpod(keepAlive: true)
CategoryService categoryService(Ref ref) {
  return CategoryServiceImpl(ref.watch(categoryRepositoryProvider));
}

@Riverpod(keepAlive: true)
PostingService postingService(Ref ref) {
  return PostingServiceImpl(ref.watch(postingRepositoryProvider));
}

@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) {
  return TransactionServiceImpl(
    ref.watch(postingServiceProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    transactionQueryRepository: ref.watch(transactionQueryRepositoryProvider),
    systemAccountResolver: ref.watch(systemAccountResolverProvider),
    postingRepository: ref.watch(postingRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
TransactionQueryService transactionQueryService(Ref ref) {
  return TransactionQueryServiceImpl(
    ref.watch(transactionQueryRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
FinancialMetricsService financialMetricsService(Ref ref) {
  return FinancialMetricsServiceImpl(
    ref.watch(financialMetricsRepositoryProvider),
  );
}

@riverpod
Stream<List<Account>> accountList(Ref ref) {
  return ref.watch(accountServiceProvider).watchAccounts();
}

@riverpod
Stream<List<Account>> accountsByTypes(Ref ref, Set<AccountType> types) {
  return ref.watch(accountRepositoryProvider).watchAccounts(types);
}

@riverpod
Stream<List<CategoryNode>> categoryTree(Ref ref, AccountType type) {
  return ref.watch(categoryServiceProvider).watchCategoryTree(type);
}

@riverpod
Stream<List<TransactionListItem>> transactionList(Ref ref, {int? accountId}) {
  return ref
      .watch(transactionQueryServiceProvider)
      .watchTransactions(
        TransactionListQuery(
          accountId: accountId,
          topLevelOnly: accountId == null,
        ),
      );
}

@riverpod
Stream<List<TransactionListItem>> homeMonthTransactions(
  Ref ref, {
  required int year,
  required int month,
}) {
  final from = DateTime(year, month);
  final until = DateTime(year, month + 1);
  return ref
      .watch(transactionQueryServiceProvider)
      .watchTransactions(
        TransactionListQuery(
          topLevelOnly: true,
          occurredFrom: from,
          occurredUntil: until,
        ),
      );
}

@riverpod
Stream<CashflowComparison> homeMonthCashflowComparison(
  Ref ref, {
  required int year,
  required int month,
}) {
  final now = DateTime.now();
  final selectedMonth = MonthKey(year: year, month: month);
  return ref
      .watch(financialMetricsServiceProvider)
      .watchCashflowComparison(
        CashflowComparisonQuery(
          month: selectedMonth,
          asOfDate:
              now.year == selectedMonth.year && now.month == selectedMonth.month
                  ? now
                  : null,
        ),
      );
}

@riverpod
Stream<List<DailyCashflowSummary>> homeMonthDailyCashflowSummaries(
  Ref ref, {
  required int year,
  required int month,
}) {
  return ref
      .watch(financialMetricsServiceProvider)
      .watchDailyCashflowSummaries(
        DailyCashflowSummaryQuery(month: MonthKey(year: year, month: month)),
      );
}

@riverpod
Stream<BalanceSheetComparison> balanceSheetComparison(Ref ref) {
  final now = DateTime.now();
  return ref
      .watch(financialMetricsServiceProvider)
      .watchBalanceSheetComparison(
        BalanceSheetComparisonQuery(
          month: MonthKey.fromDate(now),
          asOfExclusive: now,
        ),
      );
}

@riverpod
Stream<List<NetAssetTrendPoint>> netAssetTrend(Ref ref, {int months = 6}) {
  final now = DateTime.now();
  return ref
      .watch(financialMetricsServiceProvider)
      .watchNetAssetTrend(
        NetAssetTrendQuery(
          endMonth: MonthKey.fromDate(now),
          months: months,
          currentAsOfExclusive: now,
        ),
      );
}

@riverpod
Stream<TransactionDetailView?> transactionDetail(Ref ref, int transactionId) {
  return ref
      .watch(transactionQueryServiceProvider)
      .watchTransactionDetail(transactionId);
}
