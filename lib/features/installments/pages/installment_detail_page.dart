import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/installment_contract.dart';
import '../../../domain/entities/installment_repayment.dart';
import '../../../domain/entities/installment_schedule.dart';
import '../../../domain/enums/accounting_enums.dart';

class InstallmentDetailPage extends ConsumerWidget {
  const InstallmentDetailPage({required this.contractId, super.key});

  final int contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(installmentContractProvider(contractId));
    final schedulesAsync = ref.watch(installmentSchedulesProvider(contractId));
    final repaymentsAsync = ref.watch(installmentRepaymentsProvider(contractId));

    return Scaffold(
      appBar: AppBar(title: const Text('分期合同')),
      body: switch ((contractAsync, schedulesAsync, repaymentsAsync)) {
        (
          AsyncData(value: final contract),
          AsyncData(value: final schedules),
          AsyncData(value: final repayments),
        ) =>
          contract == null
              ? const Center(child: Text('合同不存在'))
              : _Body(
                  contract: contract,
                  schedules: schedules,
                  repayments: repayments,
                ),
        (AsyncError(:final error), _, _) ||
        (_, AsyncError(:final error), _) ||
        (_, _, AsyncError(:final error)) =>
          Center(child: Text('加载失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.contract,
    required this.schedules,
    required this.repayments,
  });

  final InstallmentContract contract;
  final List<InstallmentSchedule> schedules;
  final List<InstallmentRepayment> repayments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 剩余本金 = pending 期次应还本金合计。
    // 提前还本时 service 已将 pending 行重算为剩余本金，故此处直接累加 pending。
    final remainingPrincipal = schedules
        .where((s) => s.status == InstallmentScheduleStatus.pending)
        .fold<int>(0, (acc, s) => acc + s.expectedPrincipal.minorUnits);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space10,
        AppSpacing.space6,
        AppSpacing.space10,
        AppSpacing.space16,
      ),
      children: [
        _Header(
          contract: contract,
          remainingPrincipalMinor:
              remainingPrincipal < 0 ? 0 : remainingPrincipal,
        ),
        const SizedBox(height: AppSpacing.space8),
        _ActionBar(contract: contract),
        const SizedBox(height: AppSpacing.space12),
        Text('还款计划', style: context.appTextStyles.dateSectionTitle),
        const SizedBox(height: AppSpacing.space6),
        AppSurface(
          child: Column(
            children: [
              for (var i = 0; i < schedules.length; i++) ...[
                _ScheduleRow(
                  contract: contract,
                  schedule: schedules[i],
                ),
                if (i < schedules.length - 1)
                  const Divider(height: 1, indent: AppSpacing.space12),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        Text('实际还款记录', style: context.appTextStyles.dateSectionTitle),
        const SizedBox(height: AppSpacing.space6),
        if (repayments.isEmpty)
          AppSurface(
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.space20),
              child: Text('暂无还款记录'),
            ),
          )
        else
          AppSurface(
            child: Column(
              children: [
                for (var i = 0; i < repayments.length; i++) ...[
                  _RepaymentRow(repayment: repayments[i]),
                  if (i < repayments.length - 1)
                    const Divider(height: 1, indent: AppSpacing.space12),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.contract,
    required this.remainingPrincipalMinor,
  });

  final InstallmentContract contract;
  final int remainingPrincipalMinor;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(status: contract.status),
                const SizedBox(width: AppSpacing.space8),
                Text(
                  _methodLabel(contract.repaymentMethod),
                  style: styles.formLabel.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space10),
            Text('本金', style: styles.detailLabel),
            Text(
              contract.principal.format(),
              style: styles.amountPrimary,
            ),
            const SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Expanded(
                  child: _LabelValue(
                    label: '剩余本金',
                    value: Money(
                      minorUnits: remainingPrincipalMinor,
                      currency: contract.principal.currency,
                    ).format(),
                  ),
                ),
                Expanded(
                  child: _LabelValue(
                    label: '期数',
                    value: '${contract.totalPeriods} 期',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            Row(
              children: [
                Expanded(
                  child: _LabelValue(
                    label: '起始日',
                    value: _formatDate(contract.borrowingDate),
                  ),
                ),
                Expanded(
                  child: _LabelValue(
                    label: '利率',
                    value: _formatRate(
                      contract.interestRatePeriod,
                      contract.interestRatePpm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '$label：',
          style: styles.formLabel.copyWith(color: colors.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            style: styles.formLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final InstallmentContractStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      InstallmentContractStatus.active =>
        ('进行中', Theme.of(context).colorScheme.primary),
      InstallmentContractStatus.settled =>
        ('已结清', Theme.of(context).colorScheme.tertiary),
      InstallmentContractStatus.closed =>
        ('已关闭', Theme.of(context).colorScheme.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.appTextStyles.formLabel.copyWith(color: color),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.contract});

  final InstallmentContract contract;

  @override
  Widget build(BuildContext context) {
    if (contract.status != InstallmentContractStatus.active) {
      return const SizedBox.shrink();
    }
    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space6,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.push(
                  '/installments/${contract.id}/repay?mode=extra',
                ),
                child: const Text('提前还本'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => context.push(
                  '/installments/${contract.id}/repay?mode=settle',
                ),
                child: const Text('提前结清'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () =>
                    context.push('/installments/${contract.id}/edit'),
                child: const Text('编辑合同'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.contract, required this.schedule});

  final InstallmentContract contract;
  final InstallmentSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final colors = Theme.of(context).colorScheme;
    final total = schedule.expectedPrincipal +
        schedule.expectedInterest +
        schedule.expectedFee;
    final canRepay = schedule.status == InstallmentScheduleStatus.pending &&
        contract.status == InstallmentContractStatus.active;

    return InkWell(
      onTap: canRepay
          ? () => context.push(
                '/installments/${contract.id}/repay?mode=regular&scheduleId=${schedule.id}',
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space10,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '第${schedule.periodNo}期',
                style: styles.formLabel,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(schedule.expectedRepaymentDate),
                    style: styles.formLabel,
                  ),
                  Text(
                    '本金 ${schedule.expectedPrincipal.format()}'
                    '${schedule.expectedInterest.minorUnits > 0 ? '  利息 ${schedule.expectedInterest.format()}' : ''}'
                    '${schedule.expectedFee.minorUnits > 0 ? '  手续费 ${schedule.expectedFee.format()}' : ''}',
                    style: styles.listSupporting.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total.format(), style: styles.formLabel),
                Text(
                  _scheduleStatusLabel(schedule.status),
                  style: styles.listSupporting.copyWith(
                    color: _scheduleStatusColor(schedule.status, colors),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RepaymentRow extends StatelessWidget {
  const _RepaymentRow({required this.repayment});

  final InstallmentRepayment repayment;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    return InkWell(
      onTap: () => context.push('/transactions/${repayment.transactionId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _repaymentTypeLabel(repayment.repaymentType),
                style: styles.formLabel,
              ),
            ),
            Text(
              _formatDate(repayment.createdAt),
              style: styles.listSupporting,
            ),
          ],
        ),
      ),
    );
  }
}

String _methodLabel(InstallmentRepaymentMethod method) {
  return switch (method) {
    InstallmentRepaymentMethod.equalInstallment => '等额本息',
    InstallmentRepaymentMethod.equalPrincipal => '等额本金',
    InstallmentRepaymentMethod.interestFirst => '先息后本',
    InstallmentRepaymentMethod.flatFee => '一次性手续费',
    InstallmentRepaymentMethod.custom => '自定义',
  };
}

String _scheduleStatusLabel(InstallmentScheduleStatus status) {
  return switch (status) {
    InstallmentScheduleStatus.pending => '待还',
    InstallmentScheduleStatus.paid => '已还',
    InstallmentScheduleStatus.skipped => '已跳过',
  };
}

Color _scheduleStatusColor(
  InstallmentScheduleStatus status,
  ColorScheme colors,
) {
  return switch (status) {
    InstallmentScheduleStatus.pending => colors.primary,
    InstallmentScheduleStatus.paid => colors.tertiary,
    InstallmentScheduleStatus.skipped => colors.outline,
  };
}

String _repaymentTypeLabel(InstallmentRepaymentType type) {
  return switch (type) {
    InstallmentRepaymentType.regular => '正常还款',
    InstallmentRepaymentType.extraPrincipal => '提前还本',
    InstallmentRepaymentType.earlySettlement => '提前结清',
  };
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatRate(InterestRatePeriod? period, int? ppm) {
  if (period == null || ppm == null) return '—';
  final percent = (ppm / 10000).toStringAsFixed(4);
  final periodLabel = switch (period) {
    InterestRatePeriod.annual => '年',
    InterestRatePeriod.monthly => '月',
    InterestRatePeriod.daily => '日',
  };
  return '$percent% / $periodLabel';
}
