import '../../core/errors/failure.dart';
import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../enums/accounting_enums.dart';
import 'posting_command.dart';
import 'posting_service.dart';

abstract interface class TransactionService {
  Future<Result<PostTransactionResult>> createExpense(
    CreateExpenseCommand command,
  );

  Future<Result<PostTransactionResult>> createIncome(
    CreateIncomeCommand command,
  );

  Future<Result<PostTransactionResult>> createTransfer(
    CreateTransferCommand command,
  );
}

class TransactionServiceImpl implements TransactionService {
  const TransactionServiceImpl(this._postingService);

  final PostingService _postingService;

  @override
  Future<Result<PostTransactionResult>> createExpense(
    CreateExpenseCommand command,
  ) {
    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.dailyExpense,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.primaryExpense,
            amount: command.amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.expenseAccountId,
            direction: EntryDirection.debit,
            amount: command.amount,
          ),
          PostEntryInput(
            accountId: command.paidFromAccountId,
            direction: EntryDirection.credit,
            amount: command.amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> createIncome(
    CreateIncomeCommand command,
  ) {
    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.dailyIncome,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.primaryIncome,
            amount: command.amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.receiveAccountId,
            direction: EntryDirection.debit,
            amount: command.amount,
          ),
          PostEntryInput(
            accountId: command.incomeAccountId,
            direction: EntryDirection.credit,
            amount: command.amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> createTransfer(
    CreateTransferCommand command,
  ) {
    final feeFailure = command._validateFee();
    if (feeFailure != null) {
      return Future.value(Result.failure(feeFailure));
    }

    final feeAmount = command.feeAmount;
    final feeExpenseAccountId = command.feeExpenseAccountId;
    final hasFee = feeAmount != null && feeAmount.minorUnits > 0;
    final totalPaid = hasFee ? command.amount + feeAmount : command.amount;

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.transfer,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.transferMain,
            amount: command.amount,
          ),
          if (hasFee)
            PostTransactionDetailInput(
              lineNo: 2,
              type: TransactionDetailType.transferFee,
              amount: feeAmount,
            ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.toAccountId,
            direction: EntryDirection.debit,
            amount: command.amount,
          ),
          if (hasFee)
            PostEntryInput(
              accountId: feeExpenseAccountId!,
              direction: EntryDirection.debit,
              amount: feeAmount,
            ),
          PostEntryInput(
            accountId: command.fromAccountId,
            direction: EntryDirection.credit,
            amount: totalPaid,
          ),
        ],
      ),
    );
  }
}

class CreateExpenseCommand {
  const CreateExpenseCommand({
    required this.amount,
    required this.paidFromAccountId,
    required this.expenseAccountId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int paidFromAccountId;
  final int expenseAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateIncomeCommand {
  const CreateIncomeCommand({
    required this.amount,
    required this.receiveAccountId,
    required this.incomeAccountId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int receiveAccountId;
  final int incomeAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateTransferCommand {
  const CreateTransferCommand({
    required this.amount,
    required this.fromAccountId,
    required this.toAccountId,
    required this.occurredAt,
    this.feeAmount,
    this.feeExpenseAccountId,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int fromAccountId;
  final int toAccountId;
  final DateTime occurredAt;
  final Money? feeAmount;
  final int? feeExpenseAccountId;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;

  Failure? _validateFee() {
    if (feeAmount == null) {
      return feeExpenseAccountId == null
          ? null
          : const Failure(
              code: 'transfer_fee_amount_required',
              message: 'Transfer fee amount is required when fee account is set.',
            );
    }

    if (feeAmount!.currency != amount.currency) {
      return const Failure(
        code: 'transfer_fee_currency_mismatch',
        message: 'Transfer fee currency must match transfer amount currency.',
      );
    }
    if (feeAmount!.minorUnits < 0) {
      return const Failure(
        code: 'transfer_fee_negative',
        message: 'Transfer fee cannot be negative.',
      );
    }
    if (feeAmount!.minorUnits == 0) {
      return feeExpenseAccountId == null
          ? null
          : const Failure(
              code: 'transfer_fee_positive_required',
              message: 'Transfer fee must be positive when fee account is set.',
            );
    }
    if (feeExpenseAccountId == null) {
      return const Failure(
        code: 'transfer_fee_account_required',
        message: 'Transfer fee account is required when fee amount is positive.',
      );
    }

    return null;
  }
}
