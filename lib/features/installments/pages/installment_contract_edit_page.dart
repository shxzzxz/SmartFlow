import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_datetime_picker.dart';
import '../../../design_system/widgets/app_plain_form_row.dart';
import '../../../design_system/widgets/app_submit_button.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/installment_contract.dart';
import '../../../domain/entities/installment_schedule.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/installment_metrics.dart';
import '../../../domain/services/installment_schedule_generator.dart';
import '../../../domain/services/installment_service.dart';
import '../../../widgets/business/plain_transaction_fields.dart';

class InstallmentContractEditPage extends ConsumerStatefulWidget {
  const InstallmentContractEditPage({required this.contractId, super.key});

  final int contractId;

  @override
  ConsumerState<InstallmentContractEditPage> createState() =>
      _InstallmentContractEditPageState();
}

class _InstallmentContractEditPageState
    extends ConsumerState<InstallmentContractEditPage> {
  static const _generator = InstallmentScheduleGenerator();

  final _formKey = GlobalKey<FormState>();
  final _periodsController = TextEditingController();
  final _rateController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _firstRepaymentDate;
  late DateTime _lastRepaymentDate;
  late InstallmentRepaymentMethod _method;
  late InterestRatePeriod _ratePeriod;

  // 当前显示的还款计划（预览）。
  List<_DraftRow> _draft = const [];
  // 自上次"按配置重算"以来手工修改过的 periodNo。
  final Set<int> _manualPatched = {};

  InstallmentContract? _contract;
  int _paidCount = 0;
  String _currency = Money.defaultCurrency;
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _periodsController.dispose();
    _rateController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractAsync =
        ref.watch(installmentContractProvider(widget.contractId));
    final schedulesAsync =
        ref.watch(installmentSchedulesProvider(widget.contractId));
    final metricsAsync =
        ref.watch(installmentMetricsProvider(widget.contractId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('编辑合同')),
      body: switch ((contractAsync, schedulesAsync)) {
        (AsyncData(value: final contract), AsyncData(value: final schedules)) =>
          contract == null
              ? const Center(child: Text('合同不存在'))
              : _buildBody(contract, schedules, metricsAsync),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) =>
          Center(child: Text('加载失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildBody(
    InstallmentContract contract,
    List<InstallmentSchedule> schedules,
    AsyncValue<({ContractMetrics designed, ContractMetrics actual})>
        metricsAsync,
  ) {
    if (!_initialized) {
      _initialize(contract, schedules);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space12,
          AppSpacing.space12,
          AppSpacing.space12,
          AppSpacing.space24,
        ),
        children: [
          _MetricsSection(metricsAsync: metricsAsync),
          const SizedBox(height: AppSpacing.space12),
          _ConfigSection(
            contract: contract,
            paidCount: _paidCount,
            firstRepaymentDate: _firstRepaymentDate,
            lastRepaymentDate: _lastRepaymentDate,
            method: _method,
            ratePeriod: _ratePeriod,
            periodsController: _periodsController,
            rateController: _rateController,
            feeController: _feeController,
            noteController: _noteController,
            onPickFirstDate: _paidCount > 0 ? null : _pickFirstDate,
            onPickLastDate: _pickLastDate,
            onMethodChanged: (v) => setState(() => _method = v),
            onRatePeriodChanged: (v) => setState(() => _ratePeriod = v),
            onRecalculate: _recalculate,
          ),
          const SizedBox(height: AppSpacing.space12),
          _ScheduleSection(
            draft: _draft,
            currency: _currency,
            manualPatched: _manualPatched,
            onEditPrincipal: _editPrincipal,
            onEditInterest: _editInterest,
            onEditFee: _editFee,
            onEditDate: _editScheduleDate,
          ),
          const SizedBox(height: AppSpacing.space20),
          AppSubmitButton(
            label: '保存',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _initialize(
    InstallmentContract contract,
    List<InstallmentSchedule> schedules,
  ) {
    _initialized = true;
    _contract = contract;
    _currency = contract.principal.currency;
    _paidCount = schedules
        .where((s) => s.status == InstallmentScheduleStatus.paid)
        .length;
    _firstRepaymentDate = contract.firstRepaymentDate;
    _lastRepaymentDate = contract.lastRepaymentDate;
    _method = contract.repaymentMethod;
    _ratePeriod = contract.interestRatePeriod ?? InterestRatePeriod.monthly;

    _periodsController.text = contract.totalPeriods.toString();
    if (contract.interestRatePpm != null && contract.interestRatePpm! > 0) {
      final percent = contract.interestRatePpm! / 10000.0;
      _rateController.text = _trimTrailingZeros(percent.toStringAsFixed(4));
    }
    if (contract.totalFeeMinor > 0) {
      _feeController.text = Money(
        minorUnits: contract.totalFeeMinor,
        currency: _currency,
      ).major.toString();
    }
    if (contract.note != null && contract.note!.isNotEmpty) {
      _noteController.text = contract.note!;
    }

    _draft = [
      for (final s in schedules)
        _DraftRow(
          scheduleId: s.id,
          periodNo: s.periodNo,
          date: s.expectedRepaymentDate,
          principal: s.expectedPrincipal,
          interest: s.expectedInterest,
          fee: s.expectedFee,
          status: s.status,
        ),
    ];
  }

  Future<void> _pickFirstDate() async {
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: _firstRepaymentDate,
      title: '选择首期还款日',
    );
    if (picked == null || !mounted) return;
    setState(() => _firstRepaymentDate = picked);
  }

  Future<void> _pickLastDate() async {
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: _lastRepaymentDate,
      title: '选择末期还款日',
    );
    if (picked == null || !mounted) return;
    setState(() => _lastRepaymentDate = picked);
  }

  void _recalculate() {
    final contract = _contract;
    if (contract == null) return;
    final totalPeriods = int.tryParse(_periodsController.text.trim());
    if (totalPeriods == null || totalPeriods <= 0) {
      _showError('请输入有效期数');
      return;
    }
    if (totalPeriods < _paidCount + 1) {
      _showError('期数必须不小于已还期数 + 1');
      return;
    }
    if (totalPeriods > 1 &&
        !_lastRepaymentDate.isAfter(_firstRepaymentDate)) {
      _showError('末期还款日必须晚于首期还款日');
      return;
    }

    final ratePpm = _parseRatePpm(_rateController.text);
    final feeMinor = _parseOptionalMoney(_feeController.text).minorUnits;

    // 复用 service 端的算法：以同样的 generator 在本地生成预览。
    final allDates = _generator.generateDates(
      firstRepaymentDate: _firstRepaymentDate,
      lastRepaymentDate: _lastRepaymentDate,
      totalPeriods: totalPeriods,
    );
    final pendingDates = allDates.sublist(_paidCount);

    final paidRows = _draft
        .where((r) => r.status == InstallmentScheduleStatus.paid)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));

    final paidPrincipalMinor = paidRows.fold<int>(
      0,
      (acc, r) => acc + r.principal.minorUnits,
    );
    final paidFeeMinor =
        paidRows.fold<int>(0, (acc, r) => acc + r.fee.minorUnits);
    final remainingMinor =
        contract.principal.minorUnits - paidPrincipalMinor;
    if (remainingMinor < 0) {
      _showError('剩余本金为负，无法重算');
      return;
    }
    final anchorDate =
        paidRows.isEmpty ? contract.borrowingDate : paidRows.last.date;

    final remainingFeeMinor = feeMinor - paidFeeMinor;
    final allocations = _generator.allocate(
      remainingPrincipal: Money(
        minorUnits: remainingMinor,
        currency: _currency,
      ),
      anchorDate: anchorDate,
      pendingDates: pendingDates,
      method: _method,
      ratePeriod: ratePpm == null ? null : _ratePeriod,
      ratePpm: ratePpm,
      remainingFeeMinor: remainingFeeMinor < 0 ? 0 : remainingFeeMinor,
    );

    final newDraft = <_DraftRow>[];
    for (var i = 0; i < paidRows.length; i++) {
      newDraft.add(paidRows[i]);
    }
    for (var i = 0; i < pendingDates.length; i++) {
      final existing = _draft
          .where((r) =>
              r.status != InstallmentScheduleStatus.paid &&
              r.periodNo == paidRows.length + i + 1)
          .firstOrNull;
      newDraft.add(
        _DraftRow(
          scheduleId: existing?.scheduleId,
          periodNo: paidRows.length + i + 1,
          date: pendingDates[i],
          principal: allocations[i].principal,
          interest: allocations[i].interest,
          fee: allocations[i].fee,
          status: InstallmentScheduleStatus.pending,
        ),
      );
    }
    setState(() {
      _draft = newDraft;
      _manualPatched.clear();
    });
  }

  Future<void> _editPrincipal(_DraftRow row) => _editAmountField(
        row,
        title: '编辑第 ${row.periodNo} 期 · 本金',
        current: row.principal,
        allowZero: false,
        apply: (m) => row.copyWith(principal: m),
      );

  Future<void> _editInterest(_DraftRow row) => _editAmountField(
        row,
        title: '编辑第 ${row.periodNo} 期 · 利息',
        current: row.interest,
        allowZero: true,
        apply: (m) => row.copyWith(interest: m),
      );

  Future<void> _editFee(_DraftRow row) => _editAmountField(
        row,
        title: '编辑第 ${row.periodNo} 期 · 手续费',
        current: row.fee,
        allowZero: true,
        apply: (m) => row.copyWith(fee: m),
      );

  Future<void> _editAmountField(
    _DraftRow row, {
    required String title,
    required Money current,
    required bool allowZero,
    required _DraftRow Function(Money) apply,
  }) async {
    if (row.status != InstallmentScheduleStatus.pending) return;
    final edited = await _showMoneyEditDialog(
      context,
      title: title,
      initial: current,
      currency: _currency,
      allowZero: allowZero,
    );
    if (edited == null || !mounted) return;
    final newRow = apply(edited);
    setState(() {
      _draft = [
        for (final r in _draft) if (r.periodNo == row.periodNo) newRow else r,
      ];
      _manualPatched.add(row.periodNo);
    });
  }

  Future<void> _editScheduleDate(_DraftRow row) async {
    if (row.status != InstallmentScheduleStatus.pending) return;
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: row.date,
      title: '选择第 ${row.periodNo} 期还款日',
    );
    if (picked == null || !mounted) return;
    final newRow = row.copyWith(date: picked);
    setState(() {
      _draft = [
        for (final r in _draft) if (r.periodNo == row.periodNo) newRow else r,
      ];
      _manualPatched.add(row.periodNo);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final contract = _contract;
    if (contract == null) return;
    final totalPeriods = int.tryParse(_periodsController.text.trim());
    if (totalPeriods == null || totalPeriods <= 0) {
      _showError('请输入有效期数');
      return;
    }
    if (totalPeriods < _paidCount + 1) {
      _showError('期数必须不小于已还期数 + 1');
      return;
    }

    final ratePpm = _parseRatePpm(_rateController.text);
    final feeMinor = _parseOptionalMoney(_feeController.text).minorUnits;
    final note = _blankToNull(_noteController.text);

    // 手工修改过的 pending 行：构造 patch。
    final patches = <SchedulePendingPatch>[
      for (final periodNo in _manualPatched)
        if (_draft.any((r) => r.periodNo == periodNo))
          () {
            final row = _draft.firstWhere((r) => r.periodNo == periodNo);
            return SchedulePendingPatch(
              periodNo: periodNo,
              expectedPrincipal: row.principal,
              expectedInterest: row.interest,
              expectedFee: row.fee,
              expectedRepaymentDate: row.date,
            );
          }(),
    ];

    setState(() => _submitting = true);
    final service = ref.read(installmentServiceProvider);
    final result = await service.updateContract(
      UpdateContractCommand(
        contractId: widget.contractId,
        totalPeriods: totalPeriods,
        firstRepaymentDate: _firstRepaymentDate,
        lastRepaymentDate: _lastRepaymentDate,
        repaymentMethod: _method,
        interestRatePeriod: ratePpm == null ? null : _ratePeriod,
        interestRatePpm: ratePpm,
        totalFeeMinor: feeMinor,
        note: note,
        clearNote: note == null,
        schedulePatches: patches,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case Success():
        ref.invalidate(installmentContractProvider(widget.contractId));
        ref.invalidate(installmentSchedulesProvider(widget.contractId));
        ref.invalidate(installmentRepaymentsProvider(widget.contractId));
        ref.invalidate(installmentMetricsProvider(widget.contractId));
        ref.invalidate(installmentContractsByAccountProvider(
          contract.liabilityAccountId,
        ));
        context.pop();
      case FailureResult(:final failure):
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  int? _parseRatePpm(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final percent = double.tryParse(trimmed);
    if (percent == null || percent <= 0) return null;
    return (percent * 10000).round();
  }

  Money _parseOptionalMoney(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return Money.zero(currency: _currency);
    try {
      return Money.parse(trimmed);
    } on FormatException {
      return Money.zero(currency: _currency);
    }
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _trimTrailingZeros(String text) {
    if (!text.contains('.')) return text;
    var out = text;
    while (out.endsWith('0')) {
      out = out.substring(0, out.length - 1);
    }
    if (out.endsWith('.')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }
}

/// 表格预览用的临时 row 模型，区别于持久 InstallmentSchedule（可能尚无 id）。
class _DraftRow {
  _DraftRow({
    required this.periodNo,
    required this.date,
    required this.principal,
    required this.interest,
    required this.fee,
    required this.status,
    this.scheduleId,
  });

  final int? scheduleId;
  final int periodNo;
  final DateTime date;
  final Money principal;
  final Money interest;
  final Money fee;
  final InstallmentScheduleStatus status;

  Money get total => principal + interest + fee;

  _DraftRow copyWith({
    DateTime? date,
    Money? principal,
    Money? interest,
    Money? fee,
  }) {
    return _DraftRow(
      scheduleId: scheduleId,
      periodNo: periodNo,
      date: date ?? this.date,
      principal: principal ?? this.principal,
      interest: interest ?? this.interest,
      fee: fee ?? this.fee,
      status: status,
    );
  }
}

class _ConfigSection extends StatelessWidget {
  const _ConfigSection({
    required this.contract,
    required this.paidCount,
    required this.firstRepaymentDate,
    required this.lastRepaymentDate,
    required this.method,
    required this.ratePeriod,
    required this.periodsController,
    required this.rateController,
    required this.feeController,
    required this.noteController,
    required this.onPickFirstDate,
    required this.onPickLastDate,
    required this.onMethodChanged,
    required this.onRatePeriodChanged,
    required this.onRecalculate,
  });

  final InstallmentContract contract;
  final int paidCount;
  final DateTime firstRepaymentDate;
  final DateTime lastRepaymentDate;
  final InstallmentRepaymentMethod method;
  final InterestRatePeriod ratePeriod;
  final TextEditingController periodsController;
  final TextEditingController rateController;
  final TextEditingController feeController;
  final TextEditingController noteController;
  final VoidCallback? onPickFirstDate;
  final VoidCallback onPickLastDate;
  final ValueChanged<InstallmentRepaymentMethod> onMethodChanged;
  final ValueChanged<InterestRatePeriod> onRatePeriodChanged;
  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space4,
          ),
          child: Text('分期配置', style: styles.dateSectionTitle),
        ),
        AppSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space12,
              vertical: AppSpacing.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPlainFormSection(
                  children: [
                    AppPlainFormRow(
                      label: '借款日期',
                      child: _readOnly(
                        context,
                        _formatDate(contract.borrowingDate),
                      ),
                    ),
                    AppPlainFormRow(
                      label: '分期类型',
                      child: _readOnly(
                        context,
                        _sourceTypeLabel(contract.sourceType),
                      ),
                    ),
                    AppPlainFormRow(
                      label: '本金',
                      child: _readOnly(context, contract.principal.format()),
                    ),
                    _IntegerPlainFormRow(
                      label: '期数',
                      controller: periodsController,
                      hintText: '总期数',
                      validator: (value) {
                        final n = int.tryParse((value ?? '').trim());
                        if (n == null || n <= 0) return '期数必须为正整数';
                        if (n < paidCount + 1) {
                          return '期数必须不小于已还期数 + 1（当前 ${paidCount + 1}）';
                        }
                        return null;
                      },
                    ),
                    DateTimePlainFormRow(
                      label: '首期还款日',
                      value: _formatDate(firstRepaymentDate),
                      onTap: onPickFirstDate,
                    ),
                    DateTimePlainFormRow(
                      label: '末期还款日',
                      value: _formatDate(lastRepaymentDate),
                      onTap: onPickLastDate,
                    ),
                    _MethodRow(value: method, onChanged: onMethodChanged),
                    if (method != InstallmentRepaymentMethod.flatFee &&
                        method != InstallmentRepaymentMethod.custom)
                      _RateRow(
                        ratePeriod: ratePeriod,
                        rateController: rateController,
                        onPeriodChanged: onRatePeriodChanged,
                      ),
                    if (method == InstallmentRepaymentMethod.flatFee)
                      MoneyPlainFormRow(
                        label: '总手续费',
                        controller: feeController,
                        hintText: '各期合计（可选）',
                      ),
                    NotePlainFormRow(controller: noteController),
                  ],
                ),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRecalculate,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('按配置重算'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _readOnly(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: context.appTextStyles.formPlainValue
          .copyWith(color: colors.onSurface),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.draft,
    required this.currency,
    required this.manualPatched,
    required this.onEditPrincipal,
    required this.onEditInterest,
    required this.onEditFee,
    required this.onEditDate,
  });

  final List<_DraftRow> draft;
  final String currency;
  final Set<int> manualPatched;
  final ValueChanged<_DraftRow> onEditPrincipal;
  final ValueChanged<_DraftRow> onEditInterest;
  final ValueChanged<_DraftRow> onEditFee;
  final ValueChanged<_DraftRow> onEditDate;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space4,
          ),
          child: Text('还款计划', style: styles.dateSectionTitle),
        ),
        AppSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space6,
              vertical: AppSpacing.space4,
            ),
            child: Column(
              children: [
                _ScheduleHeader(),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),
                for (var i = 0; i < draft.length; i++) ...[
                  _ScheduleRow(
                    row: draft[i],
                    edited: manualPatched.contains(draft[i].periodNo),
                    onEditPrincipal: onEditPrincipal,
                    onEditInterest: onEditInterest,
                    onEditFee: onEditFee,
                    onEditDate: onEditDate,
                  ),
                  if (i < draft.length - 1)
                    Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    final labelStyle = styles.listSupporting.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _periodCellWidth,
            child: Text('期', style: labelStyle),
          ),
          SizedBox(
            width: _dateCellWidth,
            child: Text('时间', style: labelStyle),
          ),
          Expanded(
            child: Text('本', style: labelStyle, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('息', style: labelStyle, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('费', style: labelStyle, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('总额', style: labelStyle, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: _statusCellWidth,
            child: Text('状态', style: labelStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

const double _periodCellWidth = 28;
const double _dateCellWidth = 56;
const double _statusCellWidth = 36;

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.row,
    required this.edited,
    required this.onEditPrincipal,
    required this.onEditInterest,
    required this.onEditFee,
    required this.onEditDate,
  });

  final _DraftRow row;
  final bool edited;
  final ValueChanged<_DraftRow> onEditPrincipal;
  final ValueChanged<_DraftRow> onEditInterest;
  final ValueChanged<_DraftRow> onEditFee;
  final ValueChanged<_DraftRow> onEditDate;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    final pending = row.status == InstallmentScheduleStatus.pending;
    final statusColor = switch (row.status) {
      InstallmentScheduleStatus.pending => colors.primary,
      InstallmentScheduleStatus.paid => colors.tertiary,
      InstallmentScheduleStatus.skipped => colors.outline,
    };
    final cellStyle = styles.listSupporting.copyWith(
      color: pending ? colors.onSurface : colors.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _periodCellWidth,
            child: Row(
              children: [
                Text('${row.periodNo}', style: cellStyle),
                if (edited) ...[
                  const SizedBox(width: 2),
                  Icon(Icons.edit, size: 10, color: colors.secondary),
                ],
              ],
            ),
          ),
          SizedBox(
            width: _dateCellWidth,
            child: _Cell(
              text: _formatDateShort(row.date),
              style: cellStyle,
              align: TextAlign.left,
              onTap: pending ? () => onEditDate(row) : null,
            ),
          ),
          Expanded(
            child: _Cell(
              text: row.principal.format(),
              style: cellStyle,
              align: TextAlign.right,
              onTap: pending ? () => onEditPrincipal(row) : null,
            ),
          ),
          Expanded(
            child: _Cell(
              text: row.interest.format(),
              style: cellStyle,
              align: TextAlign.right,
              onTap: pending ? () => onEditInterest(row) : null,
            ),
          ),
          Expanded(
            child: _Cell(
              text: row.fee.format(),
              style: cellStyle,
              align: TextAlign.right,
              onTap: pending ? () => onEditFee(row) : null,
            ),
          ),
          Expanded(
            child: _Cell(
              text: row.total.format(),
              style: cellStyle.copyWith(fontWeight: FontWeight.w600),
              align: TextAlign.right,
              onTap: null,
            ),
          ),
          SizedBox(
            width: _statusCellWidth,
            child: Text(
              _statusLabel(row.status),
              style: styles.listSupporting.copyWith(color: statusColor),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.text,
    required this.style,
    required this.align,
    required this.onTap,
  });

  final String text;
  final TextStyle style;
  final TextAlign align;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space6,
      ),
      child: Text(
        text,
        style: style,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.metricsAsync});

  final AsyncValue<({ContractMetrics designed, ContractMetrics actual})>
      metricsAsync;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space4,
          ),
          child: Text('汇总信息', style: styles.dateSectionTitle),
        ),
        switch (metricsAsync) {
          AsyncData(value: final pair) => _MetricsPair(pair: pair),
          AsyncError(:final error) => AppSurface(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space12),
                child: Text('指标加载失败：$error'),
              ),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(AppSpacing.space12),
              child: Center(child: CircularProgressIndicator()),
            ),
        },
      ],
    );
  }
}

class _MetricsPair extends StatelessWidget {
  const _MetricsPair({required this.pair});

  final ({ContractMetrics designed, ContractMetrics actual}) pair;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '合同 / 履约',
              style: styles.listSupporting.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            _MetricGrid(designed: pair.designed, actual: pair.actual),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.designed, required this.actual});

  final ContractMetrics designed;
  final ContractMetrics actual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCell(
                label: '月 IRR',
                designed: _formatPercent(designed.monthlyIrr),
                actual: _formatPercent(actual.monthlyIrr),
              ),
            ),
            Expanded(
              child: _MetricCell(
                label: '名义年化 APR',
                designed: _formatPercent(designed.nominalApr),
                actual: _formatPercent(actual.nominalApr),
              ),
            ),
            Expanded(
              child: _MetricCell(
                label: '有效年化 EAR',
                designed: _formatPercent(designed.effectiveApr),
                actual: _formatPercent(actual.effectiveApr),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space10),
        Row(
          children: [
            Expanded(
              child: _MetricCell(
                label: '总还款额',
                designed: designed.totalRepayment.format(),
                actual: actual.totalRepayment.format(),
              ),
            ),
            Expanded(
              child: _MetricCell(
                label: '总利息',
                designed: designed.totalInterest.format(),
                actual: actual.totalInterest.format(),
              ),
            ),
            Expanded(
              child: _MetricCell(
                label: '总费用',
                designed: designed.totalFee.format(),
                actual: actual.totalFee.format(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.designed,
    required this.actual,
  });

  final String label;
  final String designed;
  final String actual;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = context.appTextStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: styles.listSupporting.copyWith(color: colors.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.space2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: designed, style: styles.formLabel),
              TextSpan(
                text: ' / ',
                style: styles.listSupporting.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: actual,
                style: styles.formLabel.copyWith(color: colors.primary),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.value, required this.onChanged});

  final InstallmentRepaymentMethod value;
  final ValueChanged<InstallmentRepaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: '分期方式',
      child: DropdownButton<InstallmentRepaymentMethod>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.equalInstallment,
            child: Text('等额本息'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.equalPrincipal,
            child: Text('等额本金'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.interestFirst,
            child: Text('先息后本'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.flatFee,
            child: Text('一次性手续费'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.custom,
            child: Text('自定义'),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.ratePeriod,
    required this.rateController,
    required this.onPeriodChanged,
  });

  final InterestRatePeriod ratePeriod;
  final TextEditingController rateController;
  final ValueChanged<InterestRatePeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: '利率(%)',
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '例：7.2',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          DropdownButton<InterestRatePeriod>(
            value: ratePeriod,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                  value: InterestRatePeriod.annual, child: Text('年')),
              DropdownMenuItem(
                  value: InterestRatePeriod.monthly, child: Text('月')),
              DropdownMenuItem(
                  value: InterestRatePeriod.daily, child: Text('日')),
            ],
            onChanged: (v) {
              if (v != null) onPeriodChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _IntegerPlainFormRow extends StatelessWidget {
  const _IntegerPlainFormRow({
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatDateShort(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _statusLabel(InstallmentScheduleStatus status) {
  return switch (status) {
    InstallmentScheduleStatus.pending => '待还',
    InstallmentScheduleStatus.paid => '已还',
    InstallmentScheduleStatus.skipped => '已跳过',
  };
}

String _sourceTypeLabel(InstallmentSourceType type) {
  return switch (type) {
    InstallmentSourceType.disbursement => '放款分期',
    InstallmentSourceType.billConversion => '账单分期',
  };
}

String _formatPercent(double v) {
  if (v.isNaN || v.isInfinite) return '—';
  return '${(v * 100).toStringAsFixed(2)}%';
}

Future<Money?> _showMoneyEditDialog(
  BuildContext context, {
  required String title,
  required Money initial,
  required String currency,
  required bool allowZero,
}) {
  final controller = TextEditingController(
    text: initial.minorUnits == 0 ? '' : initial.major.toString(),
  );
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );

  return showDialog<Money>(
    context: context,
    builder: (dialogContext) {
      String? errorText;
      return StatefulBuilder(
        builder: (context, setState) {
          void onSave() {
            final text = controller.text.trim();
            if (text.isEmpty) {
              if (allowZero) {
                Navigator.of(dialogContext).pop(Money.zero(currency: currency));
                return;
              }
              setState(() => errorText = '请输入金额');
              return;
            }
            try {
              final m = Money.parse(text, currency: currency);
              if (m.minorUnits < 0) {
                setState(() => errorText = '金额必须 ≥ 0');
                return;
              }
              if (!allowZero && m.minorUnits == 0) {
                setState(() => errorText = '金额必须 > 0');
                return;
              }
              Navigator.of(dialogContext).pop(m);
            } on FormatException {
              setState(() => errorText = '请输入有效金额');
            }
          }

          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '请输入金额',
                errorText: errorText,
                prefixText: currency == Money.defaultCurrency ? null : currency,
              ),
              onSubmitted: (_) => onSave(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('取消'),
              ),
              TextButton(onPressed: onSave, child: const Text('保存')),
            ],
          );
        },
      );
    },
  );
}
