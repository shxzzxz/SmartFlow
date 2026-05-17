import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/entities/installment_contract.dart';
import '../../domain/entities/installment_repayment.dart';
import '../../domain/entities/installment_schedule.dart';
import '../../domain/enums/accounting_enums.dart';
import '../../domain/repositories/installment_repository.dart';
import '../../domain/services/installment_schedule_generator.dart';
import '../database/app_database.dart';

class DriftInstallmentRepository implements InstallmentRepository {
  DriftInstallmentRepository(this._database);

  final AppDatabase _database;

  @override
  Future<InstallmentContract?> findContract(int id) async {
    final row =
        await (_database.select(_database.installmentContracts)
              ..where((c) => c.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _mapContract(row);
  }

  @override
  Future<List<InstallmentContract>> listContractsByLiabilityAccount(
    int liabilityAccountId,
  ) async {
    final rows =
        await (_database.select(_database.installmentContracts)
              ..where((c) => c.liabilityAccountId.equals(liabilityAccountId))
              ..orderBy([(c) => OrderingTerm.desc(c.startDate)]))
            .get();
    return rows.map(_mapContract).toList();
  }

  @override
  Future<List<InstallmentSchedule>> listSchedules(int contractId) async {
    final rows =
        await (_database.select(_database.installmentSchedules)
              ..where((s) => s.contractId.equals(contractId))
              ..orderBy([(s) => OrderingTerm.asc(s.periodNo)]))
            .get();
    return rows.map(_mapSchedule).toList();
  }

  @override
  Future<InstallmentSchedule?> findSchedule(int scheduleId) async {
    final row =
        await (_database.select(_database.installmentSchedules)
              ..where((s) => s.id.equals(scheduleId)))
            .getSingleOrNull();
    return row == null ? null : _mapSchedule(row);
  }

  @override
  Future<List<InstallmentRepayment>> listRepayments(int contractId) async {
    final rows =
        await (_database.select(_database.installmentRepayments)
              ..where((r) => r.contractId.equals(contractId))
              ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
            .get();
    return rows.map(_mapRepayment).toList();
  }

  @override
  Future<InstallmentRepayment?> findRepaymentByTransaction(
    int transactionId,
  ) async {
    final row =
        await (_database.select(_database.installmentRepayments)
              ..where((r) => r.transactionId.equals(transactionId)))
            .getSingleOrNull();
    return row == null ? null : _mapRepayment(row);
  }

  @override
  Future<int> insertContract(InstallmentContractDraft draft) {
    final now = DateTime.now();
    return _database.into(_database.installmentContracts).insert(
          InstallmentContractsCompanion.insert(
            liabilityAccountId: draft.liabilityAccountId,
            sourceType: draft.sourceType,
            disbursementAccountId: Value(draft.disbursementAccountId),
            disbursementTransactionId: Value(draft.disbursementTransactionId),
            principalMinor: draft.principal.minorUnits,
            totalPeriods: draft.totalPeriods,
            startDate: draft.startDate,
            repaymentMethod: draft.repaymentMethod,
            interestRatePeriod: Value(draft.interestRatePeriod),
            interestRatePpm: Value(draft.interestRatePpm),
            currencyCode: draft.principal.currency,
            status: draft.status,
            note: Value(draft.note),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> replaceSchedules(
    int contractId,
    List<InstallmentScheduleDraft> drafts,
  ) async {
    await _database.transaction(() async {
      await (_database.delete(_database.installmentSchedules)
            ..where((s) => s.contractId.equals(contractId)))
          .go();
      final now = DateTime.now();
      await _database.batch((batch) {
        for (final draft in drafts) {
          batch.insert(
            _database.installmentSchedules,
            InstallmentSchedulesCompanion.insert(
              contractId: contractId,
              periodNo: draft.periodNo,
              expectedRepaymentDate: draft.expectedRepaymentDate,
              expectedPrincipalMinor: Value(draft.expectedPrincipal.minorUnits),
              expectedInterestMinor: Value(draft.expectedInterest.minorUnits),
              expectedFeeMinor: Value(draft.expectedFee.minorUnits),
              status: InstallmentScheduleStatus.pending,
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      });
    });
  }

  @override
  Future<void> updateSchedule(
    int scheduleId,
    InstallmentSchedulePatch patch,
  ) async {
    final companion = InstallmentSchedulesCompanion(
      expectedRepaymentDate: patch.expectedRepaymentDate == null
          ? const Value.absent()
          : Value(patch.expectedRepaymentDate!),
      expectedPrincipalMinor: patch.expectedPrincipal == null
          ? const Value.absent()
          : Value(patch.expectedPrincipal!.minorUnits),
      expectedInterestMinor: patch.expectedInterest == null
          ? const Value.absent()
          : Value(patch.expectedInterest!.minorUnits),
      expectedFeeMinor: patch.expectedFee == null
          ? const Value.absent()
          : Value(patch.expectedFee!.minorUnits),
      status: patch.status == null ? const Value.absent() : Value(patch.status!),
      note: patch.clearNote
          ? const Value(null)
          : (patch.note == null ? const Value.absent() : Value(patch.note)),
      updatedAt: Value(DateTime.now()),
    );
    await (_database.update(_database.installmentSchedules)
          ..where((s) => s.id.equals(scheduleId)))
        .write(companion);
  }

  @override
  Future<int> insertRepayment(InstallmentRepaymentDraft draft) {
    final now = DateTime.now();
    return _database.into(_database.installmentRepayments).insert(
          InstallmentRepaymentsCompanion.insert(
            contractId: draft.contractId,
            repaymentType: draft.repaymentType,
            scheduleId: Value(draft.scheduleId),
            transactionId: draft.transactionId,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> deleteRepayment(int repaymentId) async {
    await (_database.delete(_database.installmentRepayments)
          ..where((r) => r.id.equals(repaymentId)))
        .go();
  }

  @override
  Future<void> updateContractStatus(
    int contractId,
    InstallmentContractStatus status,
  ) async {
    await (_database.update(_database.installmentContracts)
          ..where((c) => c.id.equals(contractId)))
        .write(
      InstallmentContractsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  InstallmentContract _mapContract(InstallmentContractRow row) {
    return InstallmentContract(
      id: row.id,
      liabilityAccountId: row.liabilityAccountId,
      sourceType: row.sourceType,
      disbursementAccountId: row.disbursementAccountId,
      disbursementTransactionId: row.disbursementTransactionId,
      principal: Money(
        minorUnits: row.principalMinor,
        currency: row.currencyCode,
      ),
      totalPeriods: row.totalPeriods,
      startDate: row.startDate,
      repaymentMethod: row.repaymentMethod,
      interestRatePeriod: row.interestRatePeriod,
      interestRatePpm: row.interestRatePpm,
      status: row.status,
      note: row.note,
      createdAt: row.createdAt,
    );
  }

  InstallmentSchedule _mapSchedule(InstallmentScheduleRow row) {
    // Schedule 表不存 currency；从契约信息推断需要额外查询。这里使用默认 CNY，
    // 调用方需要精确币种时应携带 contract 一并加载并替换。
    const currency = Money.defaultCurrency;
    return InstallmentSchedule(
      id: row.id,
      contractId: row.contractId,
      periodNo: row.periodNo,
      expectedRepaymentDate: row.expectedRepaymentDate,
      expectedPrincipal: Money(
        minorUnits: row.expectedPrincipalMinor,
        currency: currency,
      ),
      expectedInterest: Money(
        minorUnits: row.expectedInterestMinor,
        currency: currency,
      ),
      expectedFee: Money(
        minorUnits: row.expectedFeeMinor,
        currency: currency,
      ),
      status: row.status,
      note: row.note,
      createdAt: row.createdAt,
    );
  }

  InstallmentRepayment _mapRepayment(InstallmentRepaymentRow row) {
    return InstallmentRepayment(
      id: row.id,
      contractId: row.contractId,
      repaymentType: row.repaymentType,
      scheduleId: row.scheduleId,
      transactionId: row.transactionId,
      createdAt: row.createdAt,
    );
  }
}
