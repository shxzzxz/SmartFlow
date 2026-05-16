import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/theme/app_text_styles.dart';
import '../../design_system/tokens/spacing.dart';
import '../../design_system/widgets/app_form_field.dart';
import '../../design_system/widgets/app_plain_form_row.dart';
import '../../domain/entities/account.dart';
import 'business_icon.dart';

final moneyInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d{0,2}'),
);

class MoneyPlainFormRow extends StatelessWidget {
  const MoneyPlainFormRow({
    required this.label,
    required this.controller,
    super.key,
    this.hintText,
    this.validator,
    this.onChanged,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: label,
      child: AppPlainTextFormField(
        controller: controller,
        hintText: hintText,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [moneyInputFormatter],
        validator: validator,
        onChanged: onChanged,
        textAlign: textAlign,
      ),
    );
  }
}

class NotePlainFormRow extends StatelessWidget {
  const NotePlainFormRow({
    required this.controller,
    super.key,
    this.label = '备注',
    this.hintText = '请输入备注（可选）',
    this.textAlign = TextAlign.left,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: label,
      child: AppPlainTextFormField(
        controller: controller,
        hintText: hintText,
        maxLines: 1,
        textAlign: textAlign,
      ),
    );
  }
}

class DateTimePlainFormRow extends StatelessWidget {
  const DateTimePlainFormRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
    this.valueAlignment = AppPlainRowValueAlignment.start,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final AppPlainRowValueAlignment valueAlignment;

  @override
  Widget build(BuildContext context) {
    return AppPlainValueRow(
      label: label,
      value: value,
      onTap: onTap,
      valueAlignment: valueAlignment,
    );
  }
}

class AccountPlainFormRow extends StatelessWidget {
  const AccountPlainFormRow({
    required this.label,
    required this.account,
    required this.placeholder,
    super.key,
    this.selectedId,
    this.onTap,
    this.validator,
    this.valueAlignment = AppPlainRowValueAlignment.start,
  });

  final String label;
  final Account? account;
  final String placeholder;
  final int? selectedId;
  final VoidCallback? onTap;
  final FormFieldValidator<int>? validator;
  final AppPlainRowValueAlignment valueAlignment;

  @override
  Widget build(BuildContext context) {
    return FormField<int>(
      key: ValueKey(selectedId),
      initialValue: selectedId,
      validator: validator,
      builder: (field) {
        return AppPlainFormRow(
          label: label,
          onTap: onTap,
          errorText: field.errorText,
          child: Align(
            alignment:
                valueAlignment == AppPlainRowValueAlignment.end
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: AccountPlainValue(
              account: account,
              placeholder: placeholder,
              valueAlignment: valueAlignment,
            ),
          ),
        );
      },
    );
  }
}

class AccountPlainValue extends StatelessWidget {
  const AccountPlainValue({
    required this.account,
    required this.placeholder,
    super.key,
    this.valueAlignment = AppPlainRowValueAlignment.start,
  });

  final Account? account;
  final String placeholder;
  final AppPlainRowValueAlignment valueAlignment;

  @override
  Widget build(BuildContext context) {
    final account = this.account;
    final colors = Theme.of(context).colorScheme;
    final textAlign =
        valueAlignment == AppPlainRowValueAlignment.end
            ? TextAlign.right
            : TextAlign.left;
    if (account == null) {
      return AppPlainValueText(
        text: placeholder,
        textAlign: textAlign,
        color: colors.onSurfaceVariant,
      );
    }

    return Row(
      mainAxisSize:
          valueAlignment == AppPlainRowValueAlignment.end
              ? MainAxisSize.min
              : MainAxisSize.max,
      mainAxisAlignment:
          valueAlignment == AppPlainRowValueAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: AppSpacing.space20,
          child: Center(
            child: BusinessIcon(
              iconKey: account.iconKey,
              size: AppSpacing.space20,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Flexible(
          child: Text(
            account.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: context.appTextStyles.formPlainValue,
          ),
        ),
      ],
    );
  }
}

Future<int?> showAccountPickerSheet({
  required BuildContext context,
  required String title,
  required List<Account> accounts,
  required int? selectedId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return _AccountPickerSheet(
        title: title,
        accounts: accounts,
        selectedId: selectedId,
        onAccountTap: (account) => Navigator.of(context).pop(account.id),
      );
    },
  );
}

class AccountPickerSheetSelection {
  const AccountPickerSheetSelection(this.accountId);

  final int? accountId;
}

Future<AccountPickerSheetSelection?> showOptionalAccountPickerSheet({
  required BuildContext context,
  required String title,
  required List<Account> accounts,
  required int? selectedId,
  required String noneLabel,
}) {
  return showModalBottomSheet<AccountPickerSheetSelection>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return _AccountPickerSheet(
        title: title,
        accounts: accounts,
        selectedId: selectedId,
        noneLabel: noneLabel,
        onNoneTap:
            () => Navigator.of(
              context,
            ).pop(const AccountPickerSheetSelection(null)),
        onAccountTap:
            (account) => Navigator.of(
              context,
            ).pop(AccountPickerSheetSelection(account.id)),
      );
    },
  );
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.title,
    required this.accounts,
    required this.selectedId,
    required this.onAccountTap,
    this.noneLabel,
    this.onNoneTap,
  });

  final String title;
  final List<Account> accounts;
  final int? selectedId;
  final String? noneLabel;
  final VoidCallback? onNoneTap;
  final ValueChanged<Account> onAccountTap;

  @override
  Widget build(BuildContext context) {
    final noneLabel = this.noneLabel;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              0,
              AppSpacing.space16,
              AppSpacing.space8,
            ),
            child: Text(title, style: context.appTextStyles.subsectionTitle),
          ),
          if (noneLabel != null)
            _AccountPickerRow(
              label: noneLabel,
              selected: selectedId == null,
              onTap: onNoneTap,
            ),
          for (final account in accounts)
            _AccountPickerRow(
              label: account.name,
              iconKey: account.iconKey,
              selected: account.id == selectedId,
              onTap: () => onAccountTap(account),
            ),
          if (accounts.isEmpty && noneLabel == null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Text('暂无可选账户', style: context.appTextStyles.inputText),
            ),
        ],
      ),
    );
  }
}

class _AccountPickerRow extends StatelessWidget {
  const _AccountPickerRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconKey,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? iconKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: AppSpacing.space24,
              child: Center(
                child:
                    iconKey == null
                        ? null
                        : BusinessIcon(
                          iconKey: iconKey,
                          size: AppSpacing.space20,
                        ),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.formPlainValue,
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
