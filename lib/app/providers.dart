import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/database/database_provider.dart';
import '../data/repositories/drift_account_repository.dart';
import '../data/repositories/drift_posting_repository.dart';
import '../data/repositories/drift_transaction_query_repository.dart';
import '../domain/entities/account.dart';
import '../domain/enums/accounting_enums.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/posting_repository.dart';
import '../domain/repositories/transaction_query_repository.dart';
import '../domain/services/account_service.dart';
import '../domain/services/category_service.dart';
import '../domain/services/posting_service.dart';
import '../domain/services/transaction_query_service.dart';
import '../domain/services/transaction_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return DriftAccountRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return DriftAccountRepository(ref.watch(appDatabaseProvider));
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
  );
}

@Riverpod(keepAlive: true)
TransactionQueryService transactionQueryService(Ref ref) {
  return TransactionQueryServiceImpl(
    ref.watch(transactionQueryRepositoryProvider),
  );
}

@riverpod
Stream<List<Account>> accountList(Ref ref) {
  return ref.watch(accountServiceProvider).watchAccounts();
}

@riverpod
Stream<List<CategoryNode>> categoryTree(Ref ref, AccountType type) {
  return ref.watch(categoryServiceProvider).watchCategoryTree(type);
}

@riverpod
Stream<List<TransactionListItem>> transactionList(
  Ref ref, {
  int? accountId,
}) {
  return ref
      .watch(transactionQueryServiceProvider)
      .watchTransactions(TransactionListQuery(accountId: accountId));
}

@riverpod
Stream<TransactionDetailView?> transactionDetail(Ref ref, int transactionId) {
  return ref
      .watch(transactionQueryServiceProvider)
      .watchTransactionDetail(transactionId);
}
