import '../../core/errors/failure.dart';
import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../entities/transaction.dart';
import '../enums/accounting_enums.dart';
import '../repositories/account_repository.dart';
import '../repositories/posting_repository.dart';
import '../repositories/system_account_resolver.dart';
import '../repositories/transaction_query_repository.dart';
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

  Future<Result<PostTransactionResult>> createRefund(
    CreateRefundCommand command,
  );

  Future<Result<PostTransactionResult>> createReimbursementAdvance(
    CreateReimbursementAdvanceCommand command,
  );

  Future<Result<PostTransactionResult>> createReimbursementReceipt(
    CreateReimbursementReceiptCommand command,
  );

  Future<Result<PostTransactionResult>> closeReimbursement(
    CloseReimbursementCommand command,
  );

  Future<Result<PostTransactionResult>> createRepayment(
    CreateRepaymentCommand command,
  );

  Future<Result<PostTransactionResult>> createBorrowing(
    CreateBorrowingCommand command,
  );

  Future<Result<PostTransactionResult>> adjustBalance(
    AdjustBalanceCommand command,
  );

  Future<Result<void>> updateTransactionMetadata(
    UpdateTransactionMetadataCommand command,
  );
}

class TransactionServiceImpl implements TransactionService {
  const TransactionServiceImpl(
    this._postingService, {
    AccountRepository? accountRepository,
    TransactionQueryRepository? transactionQueryRepository,
    SystemAccountResolver? systemAccountResolver,
    PostingRepository? postingRepository,
  })  : _accountRepository = accountRepository,
        _queryRepository = transactionQueryRepository,
        _systemAccounts = systemAccountResolver,
        _postingRepository = postingRepository;

  final PostingService _postingService;
  final AccountRepository? _accountRepository;
  final TransactionQueryRepository? _queryRepository;
  final SystemAccountResolver? _systemAccounts;
  final PostingRepository? _postingRepository;

  @override
  Future<Result<PostTransactionResult>> createExpense(
    CreateExpenseCommand command,
  ) async {
    final roleFailure = await _validateAccountRoles({
      command.paidFromAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      command.expenseAccountId: {AccountType.expense},
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

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
  ) async {
    final roleFailure = await _validateAccountRoles({
      command.receiveAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      command.incomeAccountId: {AccountType.income},
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

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
  ) async {
    final feeFailure = command._validateFee();
    if (feeFailure != null) {
      return Result.failure(feeFailure);
    }
    if (command.fromAccountId == command.toAccountId) {
      return const Result.failure(
        Failure(
          code: 'transfer_accounts_must_differ',
          message: 'Transfer source and target accounts must differ.',
        ),
      );
    }

    final feeAmount = command.feeAmount;
    final feeExpenseAccountId = command.feeExpenseAccountId;
    final hasFee = feeAmount != null && feeAmount.minorUnits > 0;
    final totalPaid = hasFee ? command.amount + feeAmount : command.amount;
    final accountRoles = <int, Set<AccountType>>{
      command.fromAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      command.toAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      if (hasFee) feeExpenseAccountId!: {AccountType.expense},
    };
    final roleFailure = await _validateAccountRoles(accountRoles);
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

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

  @override
  Future<Result<PostTransactionResult>> createRefund(
    CreateRefundCommand command,
  ) async {
    if (command.amount.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'refund_amount_not_positive',
          message: 'Refund amount must be positive.',
        ),
      );
    }
    final query = _requireQueryRepository();
    final parent = await query.findTransactionById(command.parentTransactionId);
    if (parent == null) {
      return const Result.failure(
        Failure(
          code: 'refund_parent_not_found',
          message: 'Original expense not found.',
        ),
      );
    }
    if (parent.businessPurpose != BusinessPurpose.dailyExpense) {
      return const Result.failure(
        Failure(
          code: 'refund_parent_not_expense',
          message: 'Refund can only be applied to a daily expense.',
        ),
      );
    }
    if (parent.businessState != BusinessState.current) {
      return const Result.failure(
        Failure(
          code: 'refund_parent_not_current',
          message: 'Refund can only be applied to a current expense.',
        ),
      );
    }
    if (parent.currencyCode != command.amount.currency) {
      return const Result.failure(
        Failure(
          code: 'refund_currency_mismatch',
          message: 'Refund currency must match the original expense.',
        ),
      );
    }

    final refunded = await query.getRefundedTotal(
      parent.rootTransactionId,
      currencyCode: parent.currencyCode,
    );
    final remaining = parent.primaryAmount - refunded;
    if (command.amount.minorUnits > remaining.minorUnits) {
      return Result.failure(
        Failure(
          code: 'refund_exceeds_remaining',
          message:
              'Refund exceeds remaining refundable amount '
              '(${remaining.format(withCurrency: true)}).',
        ),
      );
    }

    final originalExpenseAccountId =
        await _findExpenseAccountIdInParentEntries(parentId: parent.id);
    if (originalExpenseAccountId == null) {
      return const Result.failure(
        Failure(
          code: 'refund_expense_account_not_found',
          message: 'Original expense category cannot be located.',
        ),
      );
    }

    final roleFailure = await _validateAccountRoles({
      command.refundToAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.refund,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        rootTransactionId: parent.rootTransactionId,
        parentTransactionId: parent.id,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.refundMain,
            amount: command.amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.refundToAccountId,
            direction: EntryDirection.debit,
            amount: command.amount,
          ),
          PostEntryInput(
            accountId: originalExpenseAccountId,
            direction: EntryDirection.credit,
            amount: command.amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> createReimbursementAdvance(
    CreateReimbursementAdvanceCommand command,
  ) async {
    if (command.amount.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_amount_not_positive',
          message: 'Advance amount must be positive.',
        ),
      );
    }
    final roleFailure = await _validateAccountRoles({
      command.receivableAccountId: {AccountType.asset},
      command.paidFromAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      command.expenseCategoryId: {AccountType.expense},
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.reimbursementAdvance,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        reimbursementExpenseAccountId: command.expenseCategoryId,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.reimbursementAdvanceMain,
            amount: command.amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.receivableAccountId,
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
  Future<Result<PostTransactionResult>> createReimbursementReceipt(
    CreateReimbursementReceiptCommand command,
  ) async {
    if (command.amount.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_amount_not_positive',
          message: 'Receipt amount must be positive.',
        ),
      );
    }
    final query = _requireQueryRepository();
    final advance = await query.findTransactionById(command.advanceTransactionId);
    final advanceFailure = _validateAdvance(advance, command.amount.currency);
    if (advanceFailure != null) {
      return Result.failure(advanceFailure);
    }
    final summary = await query.getReimbursementSummary(advance!.id);
    if (summary == null) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_summary_unavailable',
          message: 'Cannot resolve reimbursement state.',
        ),
      );
    }
    if (summary.isClosed) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_already_closed',
          message: 'This reimbursement chain is already closed.',
        ),
      );
    }
    if (command.amount.minorUnits > summary.outstanding.minorUnits) {
      return Result.failure(
        Failure(
          code: 'reimbursement_receipt_exceeds_outstanding',
          message:
              'Receipt exceeds outstanding receivable '
              '(${summary.outstanding.format(withCurrency: true)}).',
        ),
      );
    }

    final roleFailure = await _validateAccountRoles({
      command.receiveAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.reimbursementReceipt,
        occurredAt: command.occurredAt,
        currencyCode: command.amount.currency,
        primaryAmount: command.amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        rootTransactionId: advance.rootTransactionId,
        parentTransactionId: advance.id,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.reimbursementReceiptMain,
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
            accountId: command.receivableAccountId,
            direction: EntryDirection.credit,
            amount: command.amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> closeReimbursement(
    CloseReimbursementCommand command,
  ) async {
    if (command.actualReceivedAmount.minorUnits < 0) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_close_amount_negative',
          message: 'Final receipt amount cannot be negative.',
        ),
      );
    }
    final query = _requireQueryRepository();
    final resolver = _requireSystemAccountResolver();
    final advance = await query.findTransactionById(command.advanceTransactionId);
    final advanceFailure = _validateAdvance(
      advance,
      command.actualReceivedAmount.currency,
    );
    if (advanceFailure != null) {
      return Result.failure(advanceFailure);
    }
    final summary = await query.getReimbursementSummary(advance!.id);
    if (summary == null || summary.isClosed) {
      return const Result.failure(
        Failure(
          code: 'reimbursement_already_closed',
          message: 'This reimbursement chain is already closed.',
        ),
      );
    }

    final outstanding = summary.outstanding;
    final actual = command.actualReceivedAmount;
    final gap = actual - outstanding;
    final hasOverGap = gap.minorUnits > 0;
    final hasUnderGap = gap.minorUnits < 0;

    final details = <PostTransactionDetailInput>[
      PostTransactionDetailInput(
        lineNo: 1,
        type: TransactionDetailType.reimbursementCloseMain,
        amount: outstanding,
      ),
      if (hasOverGap)
        PostTransactionDetailInput(
          lineNo: 2,
          type: TransactionDetailType.reimbursementGapIncome,
          amount: gap,
        ),
      if (hasUnderGap)
        PostTransactionDetailInput(
          lineNo: 2,
          type: TransactionDetailType.reimbursementGapExpense,
          amount: gap.abs(),
        ),
    ];

    final entries = <PostEntryInput>[
      if (actual.minorUnits > 0)
        PostEntryInput(
          accountId: command.receiveAccountId,
          direction: EntryDirection.debit,
          amount: actual,
        ),
      PostEntryInput(
        accountId: command.receivableAccountId,
        direction: EntryDirection.credit,
        amount: outstanding,
      ),
    ];

    if (hasOverGap) {
      final gapAccountId = await resolver.resolveReimbursementGapIncome(
        currencyCode: actual.currency,
      );
      entries.add(
        PostEntryInput(
          accountId: gapAccountId,
          direction: EntryDirection.credit,
          amount: gap,
        ),
      );
    } else if (hasUnderGap) {
      final originalExpenseId = advance.reimbursementExpenseAccountId;
      if (originalExpenseId == null) {
        return const Result.failure(
          Failure(
            code: 'reimbursement_close_expense_missing',
            message:
                'Original reimbursement expense category is not recorded.',
          ),
        );
      }
      entries.add(
        PostEntryInput(
          accountId: originalExpenseId,
          direction: EntryDirection.debit,
          amount: gap.abs(),
        ),
      );
    }

    final roleFailure = await _validateAccountRoles({
      if (actual.minorUnits > 0)
        command.receiveAccountId: {
          AccountType.asset,
          AccountType.liability,
        },
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.reimbursementClose,
        occurredAt: command.occurredAt,
        currencyCode: actual.currency,
        primaryAmount: actual.minorUnits > 0 ? actual : outstanding,
        counterpartyName: command.counterpartyName,
        note: command.note,
        rootTransactionId: advance.rootTransactionId,
        parentTransactionId: advance.id,
        reimbursementExpenseAccountId: advance.reimbursementExpenseAccountId,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: details,
        entries: entries,
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> createRepayment(
    CreateRepaymentCommand command,
  ) async {
    final principal = command.principal;
    final interest = command.interest;
    final fee = command.fee;
    if (principal.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'repayment_principal_not_positive',
          message: 'Repayment principal must be positive.',
        ),
      );
    }
    if (interest != null && interest.currency != principal.currency) {
      return const Result.failure(
        Failure(
          code: 'repayment_currency_mismatch',
          message: 'Repayment interest currency mismatch.',
        ),
      );
    }
    if (fee != null && fee.currency != principal.currency) {
      return const Result.failure(
        Failure(
          code: 'repayment_currency_mismatch',
          message: 'Repayment fee currency mismatch.',
        ),
      );
    }
    if (interest != null &&
        interest.minorUnits > 0 &&
        command.interestExpenseAccountId == null) {
      return const Result.failure(
        Failure(
          code: 'repayment_interest_account_required',
          message: 'Interest category is required when interest is positive.',
        ),
      );
    }
    if (fee != null &&
        fee.minorUnits > 0 &&
        command.feeExpenseAccountId == null) {
      return const Result.failure(
        Failure(
          code: 'repayment_fee_account_required',
          message: 'Fee category is required when fee is positive.',
        ),
      );
    }

    final hasInterest = interest != null && interest.minorUnits > 0;
    final hasFee = fee != null && fee.minorUnits > 0;
    final totalPaid = principal +
        (hasInterest ? interest : Money.zero(currency: principal.currency)) +
        (hasFee ? fee : Money.zero(currency: principal.currency));

    final roleFailure = await _validateAccountRoles({
      command.liabilityAccountId: {AccountType.liability},
      command.paidFromAccountId: {
        AccountType.asset,
        AccountType.liability,
      },
      if (hasInterest) command.interestExpenseAccountId!: {AccountType.expense},
      if (hasFee) command.feeExpenseAccountId!: {AccountType.expense},
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    final details = <PostTransactionDetailInput>[
      PostTransactionDetailInput(
        lineNo: 1,
        type: TransactionDetailType.repaymentPrincipal,
        amount: principal,
      ),
      if (hasInterest)
        PostTransactionDetailInput(
          lineNo: 2,
          type: TransactionDetailType.repaymentInterest,
          amount: interest,
        ),
      if (hasFee)
        PostTransactionDetailInput(
          lineNo: hasInterest ? 3 : 2,
          type: TransactionDetailType.repaymentFee,
          amount: fee,
        ),
    ];

    final entries = <PostEntryInput>[
      PostEntryInput(
        accountId: command.liabilityAccountId,
        direction: EntryDirection.debit,
        amount: principal,
      ),
      if (hasInterest)
        PostEntryInput(
          accountId: command.interestExpenseAccountId!,
          direction: EntryDirection.debit,
          amount: interest,
        ),
      if (hasFee)
        PostEntryInput(
          accountId: command.feeExpenseAccountId!,
          direction: EntryDirection.debit,
          amount: fee,
        ),
      PostEntryInput(
        accountId: command.paidFromAccountId,
        direction: EntryDirection.credit,
        amount: totalPaid,
      ),
    ];

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.debtRepayment,
        occurredAt: command.occurredAt,
        currencyCode: principal.currency,
        primaryAmount: totalPaid,
        counterpartyName: command.counterpartyName,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: details,
        entries: entries,
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> createBorrowing(
    CreateBorrowingCommand command,
  ) async {
    if (command.amount.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'borrowing_amount_not_positive',
          message: 'Borrowing amount must be positive.',
        ),
      );
    }

    final receiveAccountId = command.receiveAccountId;
    final useSystemEquity = receiveAccountId == null;
    final roleFailure = await _validateAccountRoles({
      command.liabilityAccountId: {AccountType.liability},
      if (!useSystemEquity)
        receiveAccountId: {AccountType.asset, AccountType.liability},
    });
    if (roleFailure != null) {
      return Result.failure(roleFailure);
    }

    final debitAccountId = useSystemEquity
        ? await _requireSystemAccountResolver().resolveOpeningBalance(
            currencyCode: command.amount.currency,
          )
        : receiveAccountId;

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.borrowing,
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
            type: TransactionDetailType.borrowingPrincipal,
            amount: command.amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: debitAccountId,
            direction: EntryDirection.debit,
            amount: command.amount,
          ),
          PostEntryInput(
            accountId: command.liabilityAccountId,
            direction: EntryDirection.credit,
            amount: command.amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<PostTransactionResult>> adjustBalance(
    AdjustBalanceCommand command,
  ) async {
    final repository = _accountRepository;
    if (repository == null) {
      return const Result.failure(
        Failure(
          code: 'account_repository_unavailable',
          message: 'AccountRepository is required to adjust balance.',
        ),
      );
    }
    final account = await repository.findAccountById(command.accountId);
    if (account == null) {
      return const Result.failure(
        Failure(
          code: 'account_not_found',
          message: 'Account does not exist.',
        ),
      );
    }
    if (account.archivedAt != null) {
      return const Result.failure(
        Failure(
          code: 'account_archived',
          message: 'Cannot adjust archived account.',
        ),
      );
    }
    if (account.type != AccountType.asset &&
        account.type != AccountType.liability) {
      return const Result.failure(
        Failure(
          code: 'account_not_adjustable',
          message: 'Only asset and liability accounts support balance adjustment.',
        ),
      );
    }
    if (account.currencyCode != command.targetBalance.currency) {
      return const Result.failure(
        Failure(
          code: 'balance_adjustment_currency_mismatch',
          message: 'Target balance currency must match account currency.',
        ),
      );
    }

    final deltaMinor = command.targetBalance.minorUnits - account.balance.minorUnits;
    if (deltaMinor == 0) {
      return const Result.failure(
        Failure(
          code: 'balance_adjustment_zero_delta',
          message: 'Balance is already at the target value.',
        ),
      );
    }

    final amount = Money(
      minorUnits: deltaMinor.abs(),
      currency: command.targetBalance.currency,
    );
    final increasesOnDebit = account.type == AccountType.asset;
    final increase = deltaMinor > 0;
    final accountDirection = increasesOnDebit
        ? (increase ? EntryDirection.debit : EntryDirection.credit)
        : (increase ? EntryDirection.credit : EntryDirection.debit);
    final equityDirection = accountDirection == EntryDirection.debit
        ? EntryDirection.credit
        : EntryDirection.debit;

    final equityAccountId =
        await _requireSystemAccountResolver().resolveOpeningBalance(
      currencyCode: amount.currency,
    );

    return _postingService.post(
      PostTransactionCommand(
        businessPurpose: BusinessPurpose.balanceAdjustment,
        occurredAt: command.occurredAt,
        currencyCode: amount.currency,
        primaryAmount: amount,
        counterpartyName: command.counterpartyName,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
        details: [
          PostTransactionDetailInput(
            lineNo: 1,
            type: TransactionDetailType.balanceAdjustmentMain,
            amount: amount,
          ),
        ],
        entries: [
          PostEntryInput(
            accountId: command.accountId,
            direction: accountDirection,
            amount: amount,
          ),
          PostEntryInput(
            accountId: equityAccountId,
            direction: equityDirection,
            amount: amount,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<void>> updateTransactionMetadata(
    UpdateTransactionMetadataCommand command,
  ) async {
    if (command.note == null &&
        command.isExcludedFromStats == null &&
        command.isExcludedFromBudget == null) {
      return const Result.success(null);
    }
    final repository = _postingRepository;
    if (repository == null) {
      return const Result.failure(
        Failure(
          code: 'posting_repository_unavailable',
          message: 'PostingRepository is required to update transaction metadata.',
        ),
      );
    }
    final query = _queryRepository;
    if (query != null) {
      final transaction = await query.findTransactionById(command.transactionId);
      if (transaction == null) {
        return const Result.failure(
          Failure(
            code: 'transaction_not_found',
            message: 'Transaction does not exist.',
          ),
        );
      }
    }
    try {
      await repository.updateTransactionMetadata(
        transactionId: command.transactionId,
        note: command.note,
        isExcludedFromStats: command.isExcludedFromStats,
        isExcludedFromBudget: command.isExcludedFromBudget,
      );
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(
        Failure(
          code: 'transaction_metadata_update_failed',
          message: 'Failed to update transaction metadata.',
          cause: error,
        ),
      );
    }
  }

  Failure? _validateAdvance(
    Transaction? advance,
    String currencyCode,
  ) {
    if (advance == null) {
      return const Failure(
        code: 'reimbursement_advance_not_found',
        message: 'Reimbursement advance not found.',
      );
    }
    if (advance.businessPurpose != BusinessPurpose.reimbursementAdvance) {
      return const Failure(
        code: 'reimbursement_parent_not_advance',
        message: 'Parent transaction is not a reimbursement advance.',
      );
    }
    if (advance.businessState != BusinessState.current) {
      return const Failure(
        code: 'reimbursement_advance_not_current',
        message: 'Reimbursement advance is not current.',
      );
    }
    if (advance.currencyCode != currencyCode) {
      return const Failure(
        code: 'reimbursement_currency_mismatch',
        message: 'Currency must match the reimbursement advance.',
      );
    }
    return null;
  }

  Future<int?> _findExpenseAccountIdInParentEntries({
    required int parentId,
  }) async {
    final query = _queryRepository;
    if (query == null) {
      return null;
    }
    final view = await query.watchTransactionDetail(parentId).first;
    if (view == null) return null;
    for (final entry in view.entries) {
      if (entry.accountType == AccountType.expense &&
          entry.direction == EntryDirection.debit) {
        return entry.accountId;
      }
    }
    return null;
  }

  TransactionQueryRepository _requireQueryRepository() {
    final query = _queryRepository;
    if (query == null) {
      throw StateError(
        'TransactionQueryRepository is required for this operation.',
      );
    }
    return query;
  }

  SystemAccountResolver _requireSystemAccountResolver() {
    final resolver = _systemAccounts;
    if (resolver == null) {
      throw StateError(
        'SystemAccountResolver is required for this operation.',
      );
    }
    return resolver;
  }

  Future<Failure?> _validateAccountRoles(
    Map<int, Set<AccountType>> expectedTypesByAccountId,
  ) async {
    final repository = _accountRepository;
    if (repository == null || expectedTypesByAccountId.isEmpty) {
      return null;
    }

    final accounts = await repository.findAccountsByIds(
      expectedTypesByAccountId.keys.toSet(),
    );
    final accountsById = {for (final account in accounts) account.id: account};

    for (final MapEntry(key: accountId, value: expectedTypes)
        in expectedTypesByAccountId.entries) {
      final account = accountsById[accountId];
      if (account == null) {
        return Failure(
          code: 'account_not_found',
          message: 'Account $accountId does not exist.',
        );
      }
      if (account.archivedAt != null) {
        return Failure(
          code: 'account_archived',
          message: 'Account $accountId is archived.',
        );
      }
      if (!expectedTypes.contains(account.type)) {
        return Failure(
          code: 'account_role_invalid',
          message: 'Account $accountId cannot be used for this transaction.',
        );
      }
    }

    return null;
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

class CreateRefundCommand {
  const CreateRefundCommand({
    required this.amount,
    required this.parentTransactionId,
    required this.refundToAccountId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int parentTransactionId;
  final int refundToAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateReimbursementAdvanceCommand {
  const CreateReimbursementAdvanceCommand({
    required this.amount,
    required this.receivableAccountId,
    required this.paidFromAccountId,
    required this.expenseCategoryId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int receivableAccountId;
  final int paidFromAccountId;
  final int expenseCategoryId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateReimbursementReceiptCommand {
  const CreateReimbursementReceiptCommand({
    required this.amount,
    required this.advanceTransactionId,
    required this.receivableAccountId,
    required this.receiveAccountId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int advanceTransactionId;
  final int receivableAccountId;
  final int receiveAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CloseReimbursementCommand {
  const CloseReimbursementCommand({
    required this.actualReceivedAmount,
    required this.advanceTransactionId,
    required this.receivableAccountId,
    required this.receiveAccountId,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money actualReceivedAmount;
  final int advanceTransactionId;
  final int receivableAccountId;
  final int receiveAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateRepaymentCommand {
  const CreateRepaymentCommand({
    required this.principal,
    required this.liabilityAccountId,
    required this.paidFromAccountId,
    required this.occurredAt,
    this.interest,
    this.fee,
    this.interestExpenseAccountId,
    this.feeExpenseAccountId,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money principal;
  final Money? interest;
  final Money? fee;
  final int liabilityAccountId;
  final int paidFromAccountId;
  final int? interestExpenseAccountId;
  final int? feeExpenseAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class CreateBorrowingCommand {
  const CreateBorrowingCommand({
    required this.amount,
    required this.liabilityAccountId,
    required this.occurredAt,
    this.receiveAccountId,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final Money amount;
  final int liabilityAccountId;
  final int? receiveAccountId;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class AdjustBalanceCommand {
  const AdjustBalanceCommand({
    required this.accountId,
    required this.targetBalance,
    required this.occurredAt,
    this.counterpartyName,
    this.note,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
  });

  final int accountId;
  final Money targetBalance;
  final DateTime occurredAt;
  final String? counterpartyName;
  final String? note;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
}

class UpdateTransactionMetadataCommand {
  const UpdateTransactionMetadataCommand({
    required this.transactionId,
    this.note,
    this.isExcludedFromStats,
    this.isExcludedFromBudget,
  });

  final int transactionId;
  final String? note;
  final bool? isExcludedFromStats;
  final bool? isExcludedFromBudget;
}
