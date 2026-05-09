import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../domain/enums/accounting_enums.dart';
import '../features/accounts/pages/account_form_page.dart';
import '../features/accounts/pages/account_transactions_page.dart';
import '../features/accounts/pages/accounts_page.dart';
import '../features/categories/pages/categories_page.dart';
import '../features/categories/pages/category_form_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/placeholder/pages/placeholder_page.dart';
import '../features/transactions/pages/refund_form_page.dart';
import '../features/transactions/pages/reimbursement_close_form_page.dart';
import '../features/transactions/pages/reimbursement_receipt_form_page.dart';
import '../features/transactions/pages/transaction_detail_page.dart';
import '../features/transactions/pages/transaction_form_page.dart';
import '../features/transactions/pages/transactions_page.dart';

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountsPage(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const PlaceholderPage(title: '日历'),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const PlaceholderPage(title: '统计'),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const PlaceholderPage(title: '我的'),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/transactions/new',
      builder: (context, state) => const TransactionFormPage(),
    ),
    GoRoute(
      path: '/transactions/:id',
      builder: (context, state) => TransactionDetailPage(
        transactionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/transactions/:id/refund',
      builder: (context, state) => RefundFormPage(
        parentTransactionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/transactions/:id/reimburse-receipt',
      builder: (context, state) => ReimbursementReceiptFormPage(
        advanceTransactionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/transactions/:id/reimburse-close',
      builder: (context, state) => ReimbursementCloseFormPage(
        advanceTransactionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/accounts/new',
      builder: (context, state) => const AccountFormPage(),
    ),
    GoRoute(
      path: '/accounts/:id',
      builder: (context, state) => AccountTransactionsPage(
        accountId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/categories/new',
      builder: (context, state) {
        final type = switch (state.uri.queryParameters['type']) {
          'income' => AccountType.income,
          'expense' => AccountType.expense,
          _ => AccountType.expense,
        };
        final parentId = int.tryParse(
          state.uri.queryParameters['parentId'] ?? '',
        );
        return CategoryFormPage(initialType: type, initialParentId: parentId);
      },
    ),
  ],
);
