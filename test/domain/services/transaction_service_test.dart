import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/core/result/result.dart';
import 'package:smartflow/domain/entities/account.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';
import 'package:smartflow/domain/repositories/account_repository.dart';
import 'package:smartflow/domain/services/posting_command.dart';
import 'package:smartflow/domain/services/posting_service.dart';
import 'package:smartflow/domain/services/transaction_service.dart';

void main() {
  group('TransactionService', () {
    late _RecordingPostingService postingService;
    late TransactionService service;

    setUp(() {
      postingService = _RecordingPostingService();
      service = TransactionServiceImpl(postingService);
    });

    test('translates an expense command into posting details and entries', () async {
      final result = await service.createExpense(
        CreateExpenseCommand(
          amount: const Money(minorUnits: 2000),
          paidFromAccountId: 1,
          expenseAccountId: 101,
          occurredAt: DateTime(2026, 5),
          counterpartyName: 'Coffee shop',
          note: 'Latte',
        ),
      );

      expect(result, isA<Success<PostTransactionResult>>());
      final command = postingService.lastCommand!;
      expect(command.businessPurpose, BusinessPurpose.dailyExpense);
      expect(command.primaryAmount, const Money(minorUnits: 2000));
      expect(command.counterpartyName, 'Coffee shop');
      expect(command.note, 'Latte');
      expect(command.details, hasLength(1));
      expect(command.details.single.type, TransactionDetailType.primaryExpense);
      expect(command.details.single.amount, const Money(minorUnits: 2000));
      expect(command.entries, hasLength(2));
      expect(command.entries[0].accountId, 101);
      expect(command.entries[0].direction, EntryDirection.debit);
      expect(command.entries[0].amount, const Money(minorUnits: 2000));
      expect(command.entries[1].accountId, 1);
      expect(command.entries[1].direction, EntryDirection.credit);
      expect(command.entries[1].amount, const Money(minorUnits: 2000));
    });

    test('translates an income command into posting details and entries', () async {
      final result = await service.createIncome(
        CreateIncomeCommand(
          amount: const Money(minorUnits: 1000000),
          receiveAccountId: 2,
          incomeAccountId: 201,
          occurredAt: DateTime(2026, 5),
        ),
      );

      expect(result, isA<Success<PostTransactionResult>>());
      final command = postingService.lastCommand!;
      expect(command.businessPurpose, BusinessPurpose.dailyIncome);
      expect(command.details.single.type, TransactionDetailType.primaryIncome);
      expect(command.entries, hasLength(2));
      expect(command.entries[0].accountId, 2);
      expect(command.entries[0].direction, EntryDirection.debit);
      expect(command.entries[1].accountId, 201);
      expect(command.entries[1].direction, EntryDirection.credit);
    });

    test('translates a transfer with fee into posting details and entries', () async {
      final result = await service.createTransfer(
        CreateTransferCommand(
          amount: const Money(minorUnits: 100000),
          fromAccountId: 2,
          toAccountId: 1,
          feeAmount: const Money(minorUnits: 200),
          feeExpenseAccountId: 103,
          occurredAt: DateTime(2026, 5),
        ),
      );

      expect(result, isA<Success<PostTransactionResult>>());
      final command = postingService.lastCommand!;
      expect(command.businessPurpose, BusinessPurpose.transfer);
      expect(command.primaryAmount, const Money(minorUnits: 100000));
      expect(command.details.map((detail) => detail.type), [
        TransactionDetailType.transferMain,
        TransactionDetailType.transferFee,
      ]);
      expect(command.entries, hasLength(3));
      expect(command.entries[0].accountId, 1);
      expect(command.entries[0].direction, EntryDirection.debit);
      expect(command.entries[0].amount, const Money(minorUnits: 100000));
      expect(command.entries[1].accountId, 103);
      expect(command.entries[1].direction, EntryDirection.debit);
      expect(command.entries[1].amount, const Money(minorUnits: 200));
      expect(command.entries[2].accountId, 2);
      expect(command.entries[2].direction, EntryDirection.credit);
      expect(command.entries[2].amount, const Money(minorUnits: 100200));
    });

    test('rejects a positive transfer fee without a fee account', () async {
      final result = await service.createTransfer(
        CreateTransferCommand(
          amount: const Money(minorUnits: 100000),
          fromAccountId: 2,
          toAccountId: 1,
          feeAmount: const Money(minorUnits: 200),
          occurredAt: DateTime(2026, 5),
        ),
      );

      expect(result, isA<FailureResult<PostTransactionResult>>());
      expect(postingService.lastCommand, isNull);
    });

    test('rejects accounts used in the wrong transaction role', () async {
      service = TransactionServiceImpl(
        postingService,
        accountRepository: _FakeAccountRepository({
          1: _account(id: 1, type: AccountType.expense),
          101: _account(id: 101, type: AccountType.expense),
        }),
      );

      final result = await service.createExpense(
        CreateExpenseCommand(
          amount: const Money(minorUnits: 2000),
          paidFromAccountId: 1,
          expenseAccountId: 101,
          occurredAt: DateTime(2026, 5),
        ),
      );

      expect(result, isA<FailureResult<PostTransactionResult>>());
      expect(postingService.lastCommand, isNull);
    });
  });
}

class _RecordingPostingService implements PostingService {
  PostTransactionCommand? lastCommand;

  @override
  Future<Result<PostTransactionResult>> post(
    PostTransactionCommand command,
  ) async {
    lastCommand = command;
    return const Result.success(
      PostTransactionResult(
        transactionId: 1,
        rootTransactionId: 1,
      ),
    );
  }
}

class _FakeAccountRepository implements AccountRepository {
  const _FakeAccountRepository(this.accounts);

  final Map<int, Account> accounts;

  @override
  Future<List<Account>> findAccountsByIds(Set<int> ids) async {
    return [
      for (final id in ids)
        if (accounts[id] != null) accounts[id]!,
    ];
  }

  @override
  Future<Account?> findAccountById(int id) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Account>> watchAccounts(Set<AccountType> types) {
    throw UnimplementedError();
  }

  @override
  Future<Account> createAccount(command) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateAccount(command) {
    throw UnimplementedError();
  }
}

Account _account({
  required int id,
  required AccountType type,
}) {
  return Account(
    id: id,
    name: 'Account $id',
    type: type,
    currencyCode: Money.defaultCurrency,
    balance: Money.zero(),
  );
}
