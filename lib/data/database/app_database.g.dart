// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> accountType =
      GeneratedColumn<String>(
        'account_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$converteraccountType);
  @override
  late final GeneratedColumnWithTypeConverter<AccountSubtype?, String>
  accountSubtype = GeneratedColumn<String>(
    'account_subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<AccountSubtype?>($AccountsTable.$converteraccountSubtypen);
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitMinorMeta = const VerificationMeta(
    'creditLimitMinor',
  );
  @override
  late final GeneratedColumn<int> creditLimitMinor = GeneratedColumn<int>(
    'credit_limit_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingDayMeta = const VerificationMeta(
    'billingDay',
  );
  @override
  late final GeneratedColumn<int> billingDay = GeneratedColumn<int>(
    'billing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repaymentDayMeta = const VerificationMeta(
    'repaymentDay',
  );
  @override
  late final GeneratedColumn<int> repaymentDay = GeneratedColumn<int>(
    'repayment_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SystemKey?, String> systemKey =
      GeneratedColumn<String>(
        'system_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SystemKey?>($AccountsTable.$convertersystemKeyn);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    accountType,
    accountSubtype,
    parentId,
    currencyCode,
    balanceMinor,
    iconKey,
    note,
    creditLimitMinor,
    billingDay,
    repaymentDay,
    sortOrder,
    isHidden,
    archivedAt,
    systemKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('credit_limit_minor')) {
      context.handle(
        _creditLimitMinorMeta,
        creditLimitMinor.isAcceptableOrUnknown(
          data['credit_limit_minor']!,
          _creditLimitMinorMeta,
        ),
      );
    }
    if (data.containsKey('billing_day')) {
      context.handle(
        _billingDayMeta,
        billingDay.isAcceptableOrUnknown(data['billing_day']!, _billingDayMeta),
      );
    }
    if (data.containsKey('repayment_day')) {
      context.handle(
        _repaymentDayMeta,
        repaymentDay.isAcceptableOrUnknown(
          data['repayment_day']!,
          _repaymentDayMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      accountType: $AccountsTable.$converteraccountType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_type'],
        )!,
      ),
      accountSubtype: $AccountsTable.$converteraccountSubtypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_subtype'],
        ),
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      balanceMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}balance_minor'],
          )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      creditLimitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_minor'],
      ),
      billingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_day'],
      ),
      repaymentDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repayment_day'],
      ),
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      isHidden:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_hidden'],
          )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      systemKey: $AccountsTable.$convertersystemKeyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}system_key'],
        ),
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, String, String> $converteraccountType =
      const EnumNameConverter<AccountType>(AccountType.values);
  static JsonTypeConverter2<AccountSubtype, String, String>
  $converteraccountSubtype = const EnumNameConverter<AccountSubtype>(
    AccountSubtype.values,
  );
  static JsonTypeConverter2<AccountSubtype?, String?, String?>
  $converteraccountSubtypen = JsonTypeConverter2.asNullable(
    $converteraccountSubtype,
  );
  static JsonTypeConverter2<SystemKey, String, String> $convertersystemKey =
      const EnumNameConverter<SystemKey>(SystemKey.values);
  static JsonTypeConverter2<SystemKey?, String?, String?> $convertersystemKeyn =
      JsonTypeConverter2.asNullable($convertersystemKey);
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final int id;
  final String name;
  final AccountType accountType;
  final AccountSubtype? accountSubtype;
  final int? parentId;
  final String currencyCode;
  final int balanceMinor;
  final String? iconKey;
  final String? note;
  final int? creditLimitMinor;
  final int? billingDay;
  final int? repaymentDay;
  final int sortOrder;
  final bool isHidden;
  final DateTime? archivedAt;
  final SystemKey? systemKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AccountRow({
    required this.id,
    required this.name,
    required this.accountType,
    this.accountSubtype,
    this.parentId,
    required this.currencyCode,
    required this.balanceMinor,
    this.iconKey,
    this.note,
    this.creditLimitMinor,
    this.billingDay,
    this.repaymentDay,
    required this.sortOrder,
    required this.isHidden,
    this.archivedAt,
    this.systemKey,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['account_type'] = Variable<String>(
        $AccountsTable.$converteraccountType.toSql(accountType),
      );
    }
    if (!nullToAbsent || accountSubtype != null) {
      map['account_subtype'] = Variable<String>(
        $AccountsTable.$converteraccountSubtypen.toSql(accountSubtype),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['balance_minor'] = Variable<int>(balanceMinor);
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || creditLimitMinor != null) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor);
    }
    if (!nullToAbsent || billingDay != null) {
      map['billing_day'] = Variable<int>(billingDay);
    }
    if (!nullToAbsent || repaymentDay != null) {
      map['repayment_day'] = Variable<int>(repaymentDay);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || systemKey != null) {
      map['system_key'] = Variable<String>(
        $AccountsTable.$convertersystemKeyn.toSql(systemKey),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      accountType: Value(accountType),
      accountSubtype:
          accountSubtype == null && nullToAbsent
              ? const Value.absent()
              : Value(accountSubtype),
      parentId:
          parentId == null && nullToAbsent
              ? const Value.absent()
              : Value(parentId),
      currencyCode: Value(currencyCode),
      balanceMinor: Value(balanceMinor),
      iconKey:
          iconKey == null && nullToAbsent
              ? const Value.absent()
              : Value(iconKey),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      creditLimitMinor:
          creditLimitMinor == null && nullToAbsent
              ? const Value.absent()
              : Value(creditLimitMinor),
      billingDay:
          billingDay == null && nullToAbsent
              ? const Value.absent()
              : Value(billingDay),
      repaymentDay:
          repaymentDay == null && nullToAbsent
              ? const Value.absent()
              : Value(repaymentDay),
      sortOrder: Value(sortOrder),
      isHidden: Value(isHidden),
      archivedAt:
          archivedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(archivedAt),
      systemKey:
          systemKey == null && nullToAbsent
              ? const Value.absent()
              : Value(systemKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountType: $AccountsTable.$converteraccountType.fromJson(
        serializer.fromJson<String>(json['accountType']),
      ),
      accountSubtype: $AccountsTable.$converteraccountSubtypen.fromJson(
        serializer.fromJson<String?>(json['accountSubtype']),
      ),
      parentId: serializer.fromJson<int?>(json['parentId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      balanceMinor: serializer.fromJson<int>(json['balanceMinor']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      note: serializer.fromJson<String?>(json['note']),
      creditLimitMinor: serializer.fromJson<int?>(json['creditLimitMinor']),
      billingDay: serializer.fromJson<int?>(json['billingDay']),
      repaymentDay: serializer.fromJson<int?>(json['repaymentDay']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      systemKey: $AccountsTable.$convertersystemKeyn.fromJson(
        serializer.fromJson<String?>(json['systemKey']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'accountType': serializer.toJson<String>(
        $AccountsTable.$converteraccountType.toJson(accountType),
      ),
      'accountSubtype': serializer.toJson<String?>(
        $AccountsTable.$converteraccountSubtypen.toJson(accountSubtype),
      ),
      'parentId': serializer.toJson<int?>(parentId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'balanceMinor': serializer.toJson<int>(balanceMinor),
      'iconKey': serializer.toJson<String?>(iconKey),
      'note': serializer.toJson<String?>(note),
      'creditLimitMinor': serializer.toJson<int?>(creditLimitMinor),
      'billingDay': serializer.toJson<int?>(billingDay),
      'repaymentDay': serializer.toJson<int?>(repaymentDay),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isHidden': serializer.toJson<bool>(isHidden),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'systemKey': serializer.toJson<String?>(
        $AccountsTable.$convertersystemKeyn.toJson(systemKey),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountRow copyWith({
    int? id,
    String? name,
    AccountType? accountType,
    Value<AccountSubtype?> accountSubtype = const Value.absent(),
    Value<int?> parentId = const Value.absent(),
    String? currencyCode,
    int? balanceMinor,
    Value<String?> iconKey = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> creditLimitMinor = const Value.absent(),
    Value<int?> billingDay = const Value.absent(),
    Value<int?> repaymentDay = const Value.absent(),
    int? sortOrder,
    bool? isHidden,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<SystemKey?> systemKey = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    accountSubtype:
        accountSubtype.present ? accountSubtype.value : this.accountSubtype,
    parentId: parentId.present ? parentId.value : this.parentId,
    currencyCode: currencyCode ?? this.currencyCode,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
    note: note.present ? note.value : this.note,
    creditLimitMinor:
        creditLimitMinor.present
            ? creditLimitMinor.value
            : this.creditLimitMinor,
    billingDay: billingDay.present ? billingDay.value : this.billingDay,
    repaymentDay: repaymentDay.present ? repaymentDay.value : this.repaymentDay,
    sortOrder: sortOrder ?? this.sortOrder,
    isHidden: isHidden ?? this.isHidden,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    systemKey: systemKey.present ? systemKey.value : this.systemKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountType:
          data.accountType.present ? data.accountType.value : this.accountType,
      accountSubtype:
          data.accountSubtype.present
              ? data.accountSubtype.value
              : this.accountSubtype,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      balanceMinor:
          data.balanceMinor.present
              ? data.balanceMinor.value
              : this.balanceMinor,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      note: data.note.present ? data.note.value : this.note,
      creditLimitMinor:
          data.creditLimitMinor.present
              ? data.creditLimitMinor.value
              : this.creditLimitMinor,
      billingDay:
          data.billingDay.present ? data.billingDay.value : this.billingDay,
      repaymentDay:
          data.repaymentDay.present
              ? data.repaymentDay.value
              : this.repaymentDay,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      systemKey: data.systemKey.present ? data.systemKey.value : this.systemKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('accountSubtype: $accountSubtype, ')
          ..write('parentId: $parentId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('iconKey: $iconKey, ')
          ..write('note: $note, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('billingDay: $billingDay, ')
          ..write('repaymentDay: $repaymentDay, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isHidden: $isHidden, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('systemKey: $systemKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    accountType,
    accountSubtype,
    parentId,
    currencyCode,
    balanceMinor,
    iconKey,
    note,
    creditLimitMinor,
    billingDay,
    repaymentDay,
    sortOrder,
    isHidden,
    archivedAt,
    systemKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.accountSubtype == this.accountSubtype &&
          other.parentId == this.parentId &&
          other.currencyCode == this.currencyCode &&
          other.balanceMinor == this.balanceMinor &&
          other.iconKey == this.iconKey &&
          other.note == this.note &&
          other.creditLimitMinor == this.creditLimitMinor &&
          other.billingDay == this.billingDay &&
          other.repaymentDay == this.repaymentDay &&
          other.sortOrder == this.sortOrder &&
          other.isHidden == this.isHidden &&
          other.archivedAt == this.archivedAt &&
          other.systemKey == this.systemKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountType> accountType;
  final Value<AccountSubtype?> accountSubtype;
  final Value<int?> parentId;
  final Value<String> currencyCode;
  final Value<int> balanceMinor;
  final Value<String?> iconKey;
  final Value<String?> note;
  final Value<int?> creditLimitMinor;
  final Value<int?> billingDay;
  final Value<int?> repaymentDay;
  final Value<int> sortOrder;
  final Value<bool> isHidden;
  final Value<DateTime?> archivedAt;
  final Value<SystemKey?> systemKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.accountSubtype = const Value.absent(),
    this.parentId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.note = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.repaymentDay = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.systemKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType accountType,
    this.accountSubtype = const Value.absent(),
    this.parentId = const Value.absent(),
    required String currencyCode,
    this.balanceMinor = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.note = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.repaymentDay = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.systemKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       accountType = Value(accountType),
       currencyCode = Value(currencyCode);
  static Insertable<AccountRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? accountType,
    Expression<String>? accountSubtype,
    Expression<int>? parentId,
    Expression<String>? currencyCode,
    Expression<int>? balanceMinor,
    Expression<String>? iconKey,
    Expression<String>? note,
    Expression<int>? creditLimitMinor,
    Expression<int>? billingDay,
    Expression<int>? repaymentDay,
    Expression<int>? sortOrder,
    Expression<bool>? isHidden,
    Expression<DateTime>? archivedAt,
    Expression<String>? systemKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (accountSubtype != null) 'account_subtype': accountSubtype,
      if (parentId != null) 'parent_id': parentId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (iconKey != null) 'icon_key': iconKey,
      if (note != null) 'note': note,
      if (creditLimitMinor != null) 'credit_limit_minor': creditLimitMinor,
      if (billingDay != null) 'billing_day': billingDay,
      if (repaymentDay != null) 'repayment_day': repaymentDay,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isHidden != null) 'is_hidden': isHidden,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (systemKey != null) 'system_key': systemKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AccountType>? accountType,
    Value<AccountSubtype?>? accountSubtype,
    Value<int?>? parentId,
    Value<String>? currencyCode,
    Value<int>? balanceMinor,
    Value<String?>? iconKey,
    Value<String?>? note,
    Value<int?>? creditLimitMinor,
    Value<int?>? billingDay,
    Value<int?>? repaymentDay,
    Value<int>? sortOrder,
    Value<bool>? isHidden,
    Value<DateTime?>? archivedAt,
    Value<SystemKey?>? systemKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      accountSubtype: accountSubtype ?? this.accountSubtype,
      parentId: parentId ?? this.parentId,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      iconKey: iconKey ?? this.iconKey,
      note: note ?? this.note,
      creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
      billingDay: billingDay ?? this.billingDay,
      repaymentDay: repaymentDay ?? this.repaymentDay,
      sortOrder: sortOrder ?? this.sortOrder,
      isHidden: isHidden ?? this.isHidden,
      archivedAt: archivedAt ?? this.archivedAt,
      systemKey: systemKey ?? this.systemKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(
        $AccountsTable.$converteraccountType.toSql(accountType.value),
      );
    }
    if (accountSubtype.present) {
      map['account_subtype'] = Variable<String>(
        $AccountsTable.$converteraccountSubtypen.toSql(accountSubtype.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (creditLimitMinor.present) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor.value);
    }
    if (billingDay.present) {
      map['billing_day'] = Variable<int>(billingDay.value);
    }
    if (repaymentDay.present) {
      map['repayment_day'] = Variable<int>(repaymentDay.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (systemKey.present) {
      map['system_key'] = Variable<String>(
        $AccountsTable.$convertersystemKeyn.toSql(systemKey.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('accountSubtype: $accountSubtype, ')
          ..write('parentId: $parentId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('iconKey: $iconKey, ')
          ..write('note: $note, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('billingDay: $billingDay, ')
          ..write('repaymentDay: $repaymentDay, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isHidden: $isHidden, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('systemKey: $systemKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rootTransactionIdMeta = const VerificationMeta(
    'rootTransactionId',
  );
  @override
  late final GeneratedColumn<int> rootTransactionId = GeneratedColumn<int>(
    'root_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BusinessPurpose, String>
  businessPurpose = GeneratedColumn<String>(
    'business_purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BusinessPurpose>(
    $TransactionsTable.$converterbusinessPurpose,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryAmountMinorMeta =
      const VerificationMeta('primaryAmountMinor');
  @override
  late final GeneratedColumn<int> primaryAmountMinor = GeneratedColumn<int>(
    'primary_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartyNameMeta = const VerificationMeta(
    'counterpartyName',
  );
  @override
  late final GeneratedColumn<String> counterpartyName = GeneratedColumn<String>(
    'counterparty_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentTransactionIdMeta =
      const VerificationMeta('parentTransactionId');
  @override
  late final GeneratedColumn<int> parentTransactionId = GeneratedColumn<int>(
    'parent_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _reimbursementExpenseAccountIdMeta =
      const VerificationMeta('reimbursementExpenseAccountId');
  @override
  late final GeneratedColumn<int> reimbursementExpenseAccountId =
      GeneratedColumn<int>(
        'reimbursement_expense_account_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MutationKind, String>
  mutationKind = GeneratedColumn<String>(
    'mutation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MutationKind>($TransactionsTable.$convertermutationKind);
  static const VerificationMeta _mutationPreviousTransactionIdMeta =
      const VerificationMeta('mutationPreviousTransactionId');
  @override
  late final GeneratedColumn<int> mutationPreviousTransactionId =
      GeneratedColumn<int>(
        'mutation_previous_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id)',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<MutationReason?, String>
  mutationReason = GeneratedColumn<String>(
    'mutation_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<MutationReason?>(
    $TransactionsTable.$convertermutationReasonn,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BusinessState, String>
  businessState = GeneratedColumn<String>(
    'business_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BusinessState>($TransactionsTable.$converterbusinessState);
  static const VerificationMeta _isExcludedFromStatsMeta =
      const VerificationMeta('isExcludedFromStats');
  @override
  late final GeneratedColumn<bool> isExcludedFromStats = GeneratedColumn<bool>(
    'is_excluded_from_stats',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_excluded_from_stats" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isExcludedFromBudgetMeta =
      const VerificationMeta('isExcludedFromBudget');
  @override
  late final GeneratedColumn<bool> isExcludedFromBudget = GeneratedColumn<bool>(
    'is_excluded_from_budget',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_excluded_from_budget" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SourceKind, String> sourceKind =
      GeneratedColumn<String>(
        'source_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SourceKind>($TransactionsTable.$convertersourceKind);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootTransactionId,
    businessPurpose,
    occurredAt,
    currencyCode,
    primaryAmountMinor,
    counterpartyName,
    note,
    parentTransactionId,
    reimbursementExpenseAccountId,
    mutationKind,
    mutationPreviousTransactionId,
    mutationReason,
    businessState,
    isExcludedFromStats,
    isExcludedFromBudget,
    sourceKind,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('root_transaction_id')) {
      context.handle(
        _rootTransactionIdMeta,
        rootTransactionId.isAcceptableOrUnknown(
          data['root_transaction_id']!,
          _rootTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('primary_amount_minor')) {
      context.handle(
        _primaryAmountMinorMeta,
        primaryAmountMinor.isAcceptableOrUnknown(
          data['primary_amount_minor']!,
          _primaryAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryAmountMinorMeta);
    }
    if (data.containsKey('counterparty_name')) {
      context.handle(
        _counterpartyNameMeta,
        counterpartyName.isAcceptableOrUnknown(
          data['counterparty_name']!,
          _counterpartyNameMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('parent_transaction_id')) {
      context.handle(
        _parentTransactionIdMeta,
        parentTransactionId.isAcceptableOrUnknown(
          data['parent_transaction_id']!,
          _parentTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('reimbursement_expense_account_id')) {
      context.handle(
        _reimbursementExpenseAccountIdMeta,
        reimbursementExpenseAccountId.isAcceptableOrUnknown(
          data['reimbursement_expense_account_id']!,
          _reimbursementExpenseAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('mutation_previous_transaction_id')) {
      context.handle(
        _mutationPreviousTransactionIdMeta,
        mutationPreviousTransactionId.isAcceptableOrUnknown(
          data['mutation_previous_transaction_id']!,
          _mutationPreviousTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('is_excluded_from_stats')) {
      context.handle(
        _isExcludedFromStatsMeta,
        isExcludedFromStats.isAcceptableOrUnknown(
          data['is_excluded_from_stats']!,
          _isExcludedFromStatsMeta,
        ),
      );
    }
    if (data.containsKey('is_excluded_from_budget')) {
      context.handle(
        _isExcludedFromBudgetMeta,
        isExcludedFromBudget.isAcceptableOrUnknown(
          data['is_excluded_from_budget']!,
          _isExcludedFromBudgetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      rootTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_transaction_id'],
      ),
      businessPurpose: $TransactionsTable.$converterbusinessPurpose.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}business_purpose'],
        )!,
      ),
      occurredAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}occurred_at'],
          )!,
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      primaryAmountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}primary_amount_minor'],
          )!,
      counterpartyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_name'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      parentTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_transaction_id'],
      ),
      reimbursementExpenseAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reimbursement_expense_account_id'],
      ),
      mutationKind: $TransactionsTable.$convertermutationKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mutation_kind'],
        )!,
      ),
      mutationPreviousTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mutation_previous_transaction_id'],
      ),
      mutationReason: $TransactionsTable.$convertermutationReasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mutation_reason'],
        ),
      ),
      businessState: $TransactionsTable.$converterbusinessState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}business_state'],
        )!,
      ),
      isExcludedFromStats:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_excluded_from_stats'],
          )!,
      isExcludedFromBudget:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_excluded_from_budget'],
          )!,
      sourceKind: $TransactionsTable.$convertersourceKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source_kind'],
        )!,
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BusinessPurpose, String, String>
  $converterbusinessPurpose = const EnumNameConverter<BusinessPurpose>(
    BusinessPurpose.values,
  );
  static JsonTypeConverter2<MutationKind, String, String>
  $convertermutationKind = const EnumNameConverter<MutationKind>(
    MutationKind.values,
  );
  static JsonTypeConverter2<MutationReason, String, String>
  $convertermutationReason = const EnumNameConverter<MutationReason>(
    MutationReason.values,
  );
  static JsonTypeConverter2<MutationReason?, String?, String?>
  $convertermutationReasonn = JsonTypeConverter2.asNullable(
    $convertermutationReason,
  );
  static JsonTypeConverter2<BusinessState, String, String>
  $converterbusinessState = const EnumNameConverter<BusinessState>(
    BusinessState.values,
  );
  static JsonTypeConverter2<SourceKind, String, String> $convertersourceKind =
      const EnumNameConverter<SourceKind>(SourceKind.values);
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final int id;
  final int? rootTransactionId;
  final BusinessPurpose businessPurpose;
  final DateTime occurredAt;
  final String currencyCode;
  final int primaryAmountMinor;
  final String? counterpartyName;
  final String? note;
  final int? parentTransactionId;
  final int? reimbursementExpenseAccountId;
  final MutationKind mutationKind;
  final int? mutationPreviousTransactionId;
  final MutationReason? mutationReason;
  final BusinessState businessState;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
  final SourceKind sourceKind;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TransactionRow({
    required this.id,
    this.rootTransactionId,
    required this.businessPurpose,
    required this.occurredAt,
    required this.currencyCode,
    required this.primaryAmountMinor,
    this.counterpartyName,
    this.note,
    this.parentTransactionId,
    this.reimbursementExpenseAccountId,
    required this.mutationKind,
    this.mutationPreviousTransactionId,
    this.mutationReason,
    required this.businessState,
    required this.isExcludedFromStats,
    required this.isExcludedFromBudget,
    required this.sourceKind,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || rootTransactionId != null) {
      map['root_transaction_id'] = Variable<int>(rootTransactionId);
    }
    {
      map['business_purpose'] = Variable<String>(
        $TransactionsTable.$converterbusinessPurpose.toSql(businessPurpose),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['currency_code'] = Variable<String>(currencyCode);
    map['primary_amount_minor'] = Variable<int>(primaryAmountMinor);
    if (!nullToAbsent || counterpartyName != null) {
      map['counterparty_name'] = Variable<String>(counterpartyName);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || parentTransactionId != null) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId);
    }
    if (!nullToAbsent || reimbursementExpenseAccountId != null) {
      map['reimbursement_expense_account_id'] = Variable<int>(
        reimbursementExpenseAccountId,
      );
    }
    {
      map['mutation_kind'] = Variable<String>(
        $TransactionsTable.$convertermutationKind.toSql(mutationKind),
      );
    }
    if (!nullToAbsent || mutationPreviousTransactionId != null) {
      map['mutation_previous_transaction_id'] = Variable<int>(
        mutationPreviousTransactionId,
      );
    }
    if (!nullToAbsent || mutationReason != null) {
      map['mutation_reason'] = Variable<String>(
        $TransactionsTable.$convertermutationReasonn.toSql(mutationReason),
      );
    }
    {
      map['business_state'] = Variable<String>(
        $TransactionsTable.$converterbusinessState.toSql(businessState),
      );
    }
    map['is_excluded_from_stats'] = Variable<bool>(isExcludedFromStats);
    map['is_excluded_from_budget'] = Variable<bool>(isExcludedFromBudget);
    {
      map['source_kind'] = Variable<String>(
        $TransactionsTable.$convertersourceKind.toSql(sourceKind),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      rootTransactionId:
          rootTransactionId == null && nullToAbsent
              ? const Value.absent()
              : Value(rootTransactionId),
      businessPurpose: Value(businessPurpose),
      occurredAt: Value(occurredAt),
      currencyCode: Value(currencyCode),
      primaryAmountMinor: Value(primaryAmountMinor),
      counterpartyName:
          counterpartyName == null && nullToAbsent
              ? const Value.absent()
              : Value(counterpartyName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      parentTransactionId:
          parentTransactionId == null && nullToAbsent
              ? const Value.absent()
              : Value(parentTransactionId),
      reimbursementExpenseAccountId:
          reimbursementExpenseAccountId == null && nullToAbsent
              ? const Value.absent()
              : Value(reimbursementExpenseAccountId),
      mutationKind: Value(mutationKind),
      mutationPreviousTransactionId:
          mutationPreviousTransactionId == null && nullToAbsent
              ? const Value.absent()
              : Value(mutationPreviousTransactionId),
      mutationReason:
          mutationReason == null && nullToAbsent
              ? const Value.absent()
              : Value(mutationReason),
      businessState: Value(businessState),
      isExcludedFromStats: Value(isExcludedFromStats),
      isExcludedFromBudget: Value(isExcludedFromBudget),
      sourceKind: Value(sourceKind),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<int>(json['id']),
      rootTransactionId: serializer.fromJson<int?>(json['rootTransactionId']),
      businessPurpose: $TransactionsTable.$converterbusinessPurpose.fromJson(
        serializer.fromJson<String>(json['businessPurpose']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      primaryAmountMinor: serializer.fromJson<int>(json['primaryAmountMinor']),
      counterpartyName: serializer.fromJson<String?>(json['counterpartyName']),
      note: serializer.fromJson<String?>(json['note']),
      parentTransactionId: serializer.fromJson<int?>(
        json['parentTransactionId'],
      ),
      reimbursementExpenseAccountId: serializer.fromJson<int?>(
        json['reimbursementExpenseAccountId'],
      ),
      mutationKind: $TransactionsTable.$convertermutationKind.fromJson(
        serializer.fromJson<String>(json['mutationKind']),
      ),
      mutationPreviousTransactionId: serializer.fromJson<int?>(
        json['mutationPreviousTransactionId'],
      ),
      mutationReason: $TransactionsTable.$convertermutationReasonn.fromJson(
        serializer.fromJson<String?>(json['mutationReason']),
      ),
      businessState: $TransactionsTable.$converterbusinessState.fromJson(
        serializer.fromJson<String>(json['businessState']),
      ),
      isExcludedFromStats: serializer.fromJson<bool>(
        json['isExcludedFromStats'],
      ),
      isExcludedFromBudget: serializer.fromJson<bool>(
        json['isExcludedFromBudget'],
      ),
      sourceKind: $TransactionsTable.$convertersourceKind.fromJson(
        serializer.fromJson<String>(json['sourceKind']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rootTransactionId': serializer.toJson<int?>(rootTransactionId),
      'businessPurpose': serializer.toJson<String>(
        $TransactionsTable.$converterbusinessPurpose.toJson(businessPurpose),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'primaryAmountMinor': serializer.toJson<int>(primaryAmountMinor),
      'counterpartyName': serializer.toJson<String?>(counterpartyName),
      'note': serializer.toJson<String?>(note),
      'parentTransactionId': serializer.toJson<int?>(parentTransactionId),
      'reimbursementExpenseAccountId': serializer.toJson<int?>(
        reimbursementExpenseAccountId,
      ),
      'mutationKind': serializer.toJson<String>(
        $TransactionsTable.$convertermutationKind.toJson(mutationKind),
      ),
      'mutationPreviousTransactionId': serializer.toJson<int?>(
        mutationPreviousTransactionId,
      ),
      'mutationReason': serializer.toJson<String?>(
        $TransactionsTable.$convertermutationReasonn.toJson(mutationReason),
      ),
      'businessState': serializer.toJson<String>(
        $TransactionsTable.$converterbusinessState.toJson(businessState),
      ),
      'isExcludedFromStats': serializer.toJson<bool>(isExcludedFromStats),
      'isExcludedFromBudget': serializer.toJson<bool>(isExcludedFromBudget),
      'sourceKind': serializer.toJson<String>(
        $TransactionsTable.$convertersourceKind.toJson(sourceKind),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TransactionRow copyWith({
    int? id,
    Value<int?> rootTransactionId = const Value.absent(),
    BusinessPurpose? businessPurpose,
    DateTime? occurredAt,
    String? currencyCode,
    int? primaryAmountMinor,
    Value<String?> counterpartyName = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> parentTransactionId = const Value.absent(),
    Value<int?> reimbursementExpenseAccountId = const Value.absent(),
    MutationKind? mutationKind,
    Value<int?> mutationPreviousTransactionId = const Value.absent(),
    Value<MutationReason?> mutationReason = const Value.absent(),
    BusinessState? businessState,
    bool? isExcludedFromStats,
    bool? isExcludedFromBudget,
    SourceKind? sourceKind,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransactionRow(
    id: id ?? this.id,
    rootTransactionId:
        rootTransactionId.present
            ? rootTransactionId.value
            : this.rootTransactionId,
    businessPurpose: businessPurpose ?? this.businessPurpose,
    occurredAt: occurredAt ?? this.occurredAt,
    currencyCode: currencyCode ?? this.currencyCode,
    primaryAmountMinor: primaryAmountMinor ?? this.primaryAmountMinor,
    counterpartyName:
        counterpartyName.present
            ? counterpartyName.value
            : this.counterpartyName,
    note: note.present ? note.value : this.note,
    parentTransactionId:
        parentTransactionId.present
            ? parentTransactionId.value
            : this.parentTransactionId,
    reimbursementExpenseAccountId:
        reimbursementExpenseAccountId.present
            ? reimbursementExpenseAccountId.value
            : this.reimbursementExpenseAccountId,
    mutationKind: mutationKind ?? this.mutationKind,
    mutationPreviousTransactionId:
        mutationPreviousTransactionId.present
            ? mutationPreviousTransactionId.value
            : this.mutationPreviousTransactionId,
    mutationReason:
        mutationReason.present ? mutationReason.value : this.mutationReason,
    businessState: businessState ?? this.businessState,
    isExcludedFromStats: isExcludedFromStats ?? this.isExcludedFromStats,
    isExcludedFromBudget: isExcludedFromBudget ?? this.isExcludedFromBudget,
    sourceKind: sourceKind ?? this.sourceKind,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      rootTransactionId:
          data.rootTransactionId.present
              ? data.rootTransactionId.value
              : this.rootTransactionId,
      businessPurpose:
          data.businessPurpose.present
              ? data.businessPurpose.value
              : this.businessPurpose,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      primaryAmountMinor:
          data.primaryAmountMinor.present
              ? data.primaryAmountMinor.value
              : this.primaryAmountMinor,
      counterpartyName:
          data.counterpartyName.present
              ? data.counterpartyName.value
              : this.counterpartyName,
      note: data.note.present ? data.note.value : this.note,
      parentTransactionId:
          data.parentTransactionId.present
              ? data.parentTransactionId.value
              : this.parentTransactionId,
      reimbursementExpenseAccountId:
          data.reimbursementExpenseAccountId.present
              ? data.reimbursementExpenseAccountId.value
              : this.reimbursementExpenseAccountId,
      mutationKind:
          data.mutationKind.present
              ? data.mutationKind.value
              : this.mutationKind,
      mutationPreviousTransactionId:
          data.mutationPreviousTransactionId.present
              ? data.mutationPreviousTransactionId.value
              : this.mutationPreviousTransactionId,
      mutationReason:
          data.mutationReason.present
              ? data.mutationReason.value
              : this.mutationReason,
      businessState:
          data.businessState.present
              ? data.businessState.value
              : this.businessState,
      isExcludedFromStats:
          data.isExcludedFromStats.present
              ? data.isExcludedFromStats.value
              : this.isExcludedFromStats,
      isExcludedFromBudget:
          data.isExcludedFromBudget.present
              ? data.isExcludedFromBudget.value
              : this.isExcludedFromBudget,
      sourceKind:
          data.sourceKind.present ? data.sourceKind.value : this.sourceKind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('rootTransactionId: $rootTransactionId, ')
          ..write('businessPurpose: $businessPurpose, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('primaryAmountMinor: $primaryAmountMinor, ')
          ..write('counterpartyName: $counterpartyName, ')
          ..write('note: $note, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write(
            'reimbursementExpenseAccountId: $reimbursementExpenseAccountId, ',
          )
          ..write('mutationKind: $mutationKind, ')
          ..write(
            'mutationPreviousTransactionId: $mutationPreviousTransactionId, ',
          )
          ..write('mutationReason: $mutationReason, ')
          ..write('businessState: $businessState, ')
          ..write('isExcludedFromStats: $isExcludedFromStats, ')
          ..write('isExcludedFromBudget: $isExcludedFromBudget, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rootTransactionId,
    businessPurpose,
    occurredAt,
    currencyCode,
    primaryAmountMinor,
    counterpartyName,
    note,
    parentTransactionId,
    reimbursementExpenseAccountId,
    mutationKind,
    mutationPreviousTransactionId,
    mutationReason,
    businessState,
    isExcludedFromStats,
    isExcludedFromBudget,
    sourceKind,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.rootTransactionId == this.rootTransactionId &&
          other.businessPurpose == this.businessPurpose &&
          other.occurredAt == this.occurredAt &&
          other.currencyCode == this.currencyCode &&
          other.primaryAmountMinor == this.primaryAmountMinor &&
          other.counterpartyName == this.counterpartyName &&
          other.note == this.note &&
          other.parentTransactionId == this.parentTransactionId &&
          other.reimbursementExpenseAccountId ==
              this.reimbursementExpenseAccountId &&
          other.mutationKind == this.mutationKind &&
          other.mutationPreviousTransactionId ==
              this.mutationPreviousTransactionId &&
          other.mutationReason == this.mutationReason &&
          other.businessState == this.businessState &&
          other.isExcludedFromStats == this.isExcludedFromStats &&
          other.isExcludedFromBudget == this.isExcludedFromBudget &&
          other.sourceKind == this.sourceKind &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<int> id;
  final Value<int?> rootTransactionId;
  final Value<BusinessPurpose> businessPurpose;
  final Value<DateTime> occurredAt;
  final Value<String> currencyCode;
  final Value<int> primaryAmountMinor;
  final Value<String?> counterpartyName;
  final Value<String?> note;
  final Value<int?> parentTransactionId;
  final Value<int?> reimbursementExpenseAccountId;
  final Value<MutationKind> mutationKind;
  final Value<int?> mutationPreviousTransactionId;
  final Value<MutationReason?> mutationReason;
  final Value<BusinessState> businessState;
  final Value<bool> isExcludedFromStats;
  final Value<bool> isExcludedFromBudget;
  final Value<SourceKind> sourceKind;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.rootTransactionId = const Value.absent(),
    this.businessPurpose = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.primaryAmountMinor = const Value.absent(),
    this.counterpartyName = const Value.absent(),
    this.note = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.reimbursementExpenseAccountId = const Value.absent(),
    this.mutationKind = const Value.absent(),
    this.mutationPreviousTransactionId = const Value.absent(),
    this.mutationReason = const Value.absent(),
    this.businessState = const Value.absent(),
    this.isExcludedFromStats = const Value.absent(),
    this.isExcludedFromBudget = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.rootTransactionId = const Value.absent(),
    required BusinessPurpose businessPurpose,
    required DateTime occurredAt,
    required String currencyCode,
    required int primaryAmountMinor,
    this.counterpartyName = const Value.absent(),
    this.note = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.reimbursementExpenseAccountId = const Value.absent(),
    required MutationKind mutationKind,
    this.mutationPreviousTransactionId = const Value.absent(),
    this.mutationReason = const Value.absent(),
    required BusinessState businessState,
    this.isExcludedFromStats = const Value.absent(),
    this.isExcludedFromBudget = const Value.absent(),
    required SourceKind sourceKind,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : businessPurpose = Value(businessPurpose),
       occurredAt = Value(occurredAt),
       currencyCode = Value(currencyCode),
       primaryAmountMinor = Value(primaryAmountMinor),
       mutationKind = Value(mutationKind),
       businessState = Value(businessState),
       sourceKind = Value(sourceKind);
  static Insertable<TransactionRow> custom({
    Expression<int>? id,
    Expression<int>? rootTransactionId,
    Expression<String>? businessPurpose,
    Expression<DateTime>? occurredAt,
    Expression<String>? currencyCode,
    Expression<int>? primaryAmountMinor,
    Expression<String>? counterpartyName,
    Expression<String>? note,
    Expression<int>? parentTransactionId,
    Expression<int>? reimbursementExpenseAccountId,
    Expression<String>? mutationKind,
    Expression<int>? mutationPreviousTransactionId,
    Expression<String>? mutationReason,
    Expression<String>? businessState,
    Expression<bool>? isExcludedFromStats,
    Expression<bool>? isExcludedFromBudget,
    Expression<String>? sourceKind,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootTransactionId != null) 'root_transaction_id': rootTransactionId,
      if (businessPurpose != null) 'business_purpose': businessPurpose,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (primaryAmountMinor != null)
        'primary_amount_minor': primaryAmountMinor,
      if (counterpartyName != null) 'counterparty_name': counterpartyName,
      if (note != null) 'note': note,
      if (parentTransactionId != null)
        'parent_transaction_id': parentTransactionId,
      if (reimbursementExpenseAccountId != null)
        'reimbursement_expense_account_id': reimbursementExpenseAccountId,
      if (mutationKind != null) 'mutation_kind': mutationKind,
      if (mutationPreviousTransactionId != null)
        'mutation_previous_transaction_id': mutationPreviousTransactionId,
      if (mutationReason != null) 'mutation_reason': mutationReason,
      if (businessState != null) 'business_state': businessState,
      if (isExcludedFromStats != null)
        'is_excluded_from_stats': isExcludedFromStats,
      if (isExcludedFromBudget != null)
        'is_excluded_from_budget': isExcludedFromBudget,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? rootTransactionId,
    Value<BusinessPurpose>? businessPurpose,
    Value<DateTime>? occurredAt,
    Value<String>? currencyCode,
    Value<int>? primaryAmountMinor,
    Value<String?>? counterpartyName,
    Value<String?>? note,
    Value<int?>? parentTransactionId,
    Value<int?>? reimbursementExpenseAccountId,
    Value<MutationKind>? mutationKind,
    Value<int?>? mutationPreviousTransactionId,
    Value<MutationReason?>? mutationReason,
    Value<BusinessState>? businessState,
    Value<bool>? isExcludedFromStats,
    Value<bool>? isExcludedFromBudget,
    Value<SourceKind>? sourceKind,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      rootTransactionId: rootTransactionId ?? this.rootTransactionId,
      businessPurpose: businessPurpose ?? this.businessPurpose,
      occurredAt: occurredAt ?? this.occurredAt,
      currencyCode: currencyCode ?? this.currencyCode,
      primaryAmountMinor: primaryAmountMinor ?? this.primaryAmountMinor,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      note: note ?? this.note,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      reimbursementExpenseAccountId:
          reimbursementExpenseAccountId ?? this.reimbursementExpenseAccountId,
      mutationKind: mutationKind ?? this.mutationKind,
      mutationPreviousTransactionId:
          mutationPreviousTransactionId ?? this.mutationPreviousTransactionId,
      mutationReason: mutationReason ?? this.mutationReason,
      businessState: businessState ?? this.businessState,
      isExcludedFromStats: isExcludedFromStats ?? this.isExcludedFromStats,
      isExcludedFromBudget: isExcludedFromBudget ?? this.isExcludedFromBudget,
      sourceKind: sourceKind ?? this.sourceKind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rootTransactionId.present) {
      map['root_transaction_id'] = Variable<int>(rootTransactionId.value);
    }
    if (businessPurpose.present) {
      map['business_purpose'] = Variable<String>(
        $TransactionsTable.$converterbusinessPurpose.toSql(
          businessPurpose.value,
        ),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (primaryAmountMinor.present) {
      map['primary_amount_minor'] = Variable<int>(primaryAmountMinor.value);
    }
    if (counterpartyName.present) {
      map['counterparty_name'] = Variable<String>(counterpartyName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (parentTransactionId.present) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId.value);
    }
    if (reimbursementExpenseAccountId.present) {
      map['reimbursement_expense_account_id'] = Variable<int>(
        reimbursementExpenseAccountId.value,
      );
    }
    if (mutationKind.present) {
      map['mutation_kind'] = Variable<String>(
        $TransactionsTable.$convertermutationKind.toSql(mutationKind.value),
      );
    }
    if (mutationPreviousTransactionId.present) {
      map['mutation_previous_transaction_id'] = Variable<int>(
        mutationPreviousTransactionId.value,
      );
    }
    if (mutationReason.present) {
      map['mutation_reason'] = Variable<String>(
        $TransactionsTable.$convertermutationReasonn.toSql(
          mutationReason.value,
        ),
      );
    }
    if (businessState.present) {
      map['business_state'] = Variable<String>(
        $TransactionsTable.$converterbusinessState.toSql(businessState.value),
      );
    }
    if (isExcludedFromStats.present) {
      map['is_excluded_from_stats'] = Variable<bool>(isExcludedFromStats.value);
    }
    if (isExcludedFromBudget.present) {
      map['is_excluded_from_budget'] = Variable<bool>(
        isExcludedFromBudget.value,
      );
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(
        $TransactionsTable.$convertersourceKind.toSql(sourceKind.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('rootTransactionId: $rootTransactionId, ')
          ..write('businessPurpose: $businessPurpose, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('primaryAmountMinor: $primaryAmountMinor, ')
          ..write('counterpartyName: $counterpartyName, ')
          ..write('note: $note, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write(
            'reimbursementExpenseAccountId: $reimbursementExpenseAccountId, ',
          )
          ..write('mutationKind: $mutationKind, ')
          ..write(
            'mutationPreviousTransactionId: $mutationPreviousTransactionId, ',
          )
          ..write('mutationReason: $mutationReason, ')
          ..write('businessState: $businessState, ')
          ..write('isExcludedFromStats: $isExcludedFromStats, ')
          ..write('isExcludedFromBudget: $isExcludedFromBudget, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionDetailsTable extends TransactionDetails
    with TableInfo<$TransactionDetailsTable, TransactionDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionDetailType, String>
  detailType = GeneratedColumn<String>(
    'detail_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TransactionDetailType>(
    $TransactionDetailsTable.$converterdetailType,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    lineNo,
    detailType,
    amountMinor,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionDetailRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      transactionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}transaction_id'],
          )!,
      lineNo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}line_no'],
          )!,
      detailType: $TransactionDetailsTable.$converterdetailType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}detail_type'],
        )!,
      ),
      amountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_minor'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TransactionDetailsTable createAlias(String alias) {
    return $TransactionDetailsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionDetailType, String, String>
  $converterdetailType = const EnumNameConverter<TransactionDetailType>(
    TransactionDetailType.values,
  );
}

class TransactionDetailRow extends DataClass
    implements Insertable<TransactionDetailRow> {
  final int id;
  final int transactionId;
  final int lineNo;
  final TransactionDetailType detailType;
  final int amountMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TransactionDetailRow({
    required this.id,
    required this.transactionId,
    required this.lineNo,
    required this.detailType,
    required this.amountMinor,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['line_no'] = Variable<int>(lineNo);
    {
      map['detail_type'] = Variable<String>(
        $TransactionDetailsTable.$converterdetailType.toSql(detailType),
      );
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionDetailsCompanion toCompanion(bool nullToAbsent) {
    return TransactionDetailsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      lineNo: Value(lineNo),
      detailType: Value(detailType),
      amountMinor: Value(amountMinor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TransactionDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionDetailRow(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      detailType: $TransactionDetailsTable.$converterdetailType.fromJson(
        serializer.fromJson<String>(json['detailType']),
      ),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'lineNo': serializer.toJson<int>(lineNo),
      'detailType': serializer.toJson<String>(
        $TransactionDetailsTable.$converterdetailType.toJson(detailType),
      ),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TransactionDetailRow copyWith({
    int? id,
    int? transactionId,
    int? lineNo,
    TransactionDetailType? detailType,
    int? amountMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransactionDetailRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    lineNo: lineNo ?? this.lineNo,
    detailType: detailType ?? this.detailType,
    amountMinor: amountMinor ?? this.amountMinor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TransactionDetailRow copyWithCompanion(TransactionDetailsCompanion data) {
    return TransactionDetailRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId:
          data.transactionId.present
              ? data.transactionId.value
              : this.transactionId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      detailType:
          data.detailType.present ? data.detailType.value : this.detailType,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionDetailRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('lineNo: $lineNo, ')
          ..write('detailType: $detailType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    lineNo,
    detailType,
    amountMinor,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionDetailRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.lineNo == this.lineNo &&
          other.detailType == this.detailType &&
          other.amountMinor == this.amountMinor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionDetailsCompanion
    extends UpdateCompanion<TransactionDetailRow> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> lineNo;
  final Value<TransactionDetailType> detailType;
  final Value<int> amountMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionDetailsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.detailType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionDetailsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int lineNo,
    required TransactionDetailType detailType,
    required int amountMinor,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : transactionId = Value(transactionId),
       lineNo = Value(lineNo),
       detailType = Value(detailType),
       amountMinor = Value(amountMinor);
  static Insertable<TransactionDetailRow> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? lineNo,
    Expression<String>? detailType,
    Expression<int>? amountMinor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (lineNo != null) 'line_no': lineNo,
      if (detailType != null) 'detail_type': detailType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionDetailsCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<int>? lineNo,
    Value<TransactionDetailType>? detailType,
    Value<int>? amountMinor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionDetailsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      lineNo: lineNo ?? this.lineNo,
      detailType: detailType ?? this.detailType,
      amountMinor: amountMinor ?? this.amountMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (detailType.present) {
      map['detail_type'] = Variable<String>(
        $TransactionDetailsTable.$converterdetailType.toSql(detailType.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionDetailsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('lineNo: $lineNo, ')
          ..write('detailType: $detailType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntryDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<EntryDirection>($EntriesTable.$converterdirection);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    accountId,
    direction,
    amountMinor,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      transactionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}transaction_id'],
          )!,
      accountId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}account_id'],
          )!,
      direction: $EntriesTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      amountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_minor'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EntryDirection, String, String>
  $converterdirection = const EnumNameConverter<EntryDirection>(
    EntryDirection.values,
  );
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final int id;
  final int transactionId;
  final int accountId;
  final EntryDirection direction;
  final int amountMinor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryRow({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.direction,
    required this.amountMinor,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['account_id'] = Variable<int>(accountId);
    {
      map['direction'] = Variable<String>(
        $EntriesTable.$converterdirection.toSql(direction),
      );
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      accountId: Value(accountId),
      direction: Value(direction),
      amountMinor: Value(amountMinor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      direction: $EntriesTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'accountId': serializer.toJson<int>(accountId),
      'direction': serializer.toJson<String>(
        $EntriesTable.$converterdirection.toJson(direction),
      ),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryRow copyWith({
    int? id,
    int? transactionId,
    int? accountId,
    EntryDirection? direction,
    int? amountMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntryRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    accountId: accountId ?? this.accountId,
    direction: direction ?? this.direction,
    amountMinor: amountMinor ?? this.amountMinor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId:
          data.transactionId.present
              ? data.transactionId.value
              : this.transactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('direction: $direction, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    accountId,
    direction,
    amountMinor,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.accountId == this.accountId &&
          other.direction == this.direction &&
          other.amountMinor == this.amountMinor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> accountId;
  final Value<EntryDirection> direction;
  final Value<int> amountMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int accountId,
    required EntryDirection direction,
    required int amountMinor,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : transactionId = Value(transactionId),
       accountId = Value(accountId),
       direction = Value(direction),
       amountMinor = Value(amountMinor);
  static Insertable<EntryRow> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? accountId,
    Expression<String>? direction,
    Expression<int>? amountMinor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (accountId != null) 'account_id': accountId,
      if (direction != null) 'direction': direction,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<int>? accountId,
    Value<EntryDirection>? direction,
    Value<int>? amountMinor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      direction: direction ?? this.direction,
      amountMinor: amountMinor ?? this.amountMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $EntriesTable.$converterdirection.toSql(direction.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('direction: $direction, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<int> monthKey = GeneratedColumn<int>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthKey,
    accountId,
    amountMinor,
    currencyCode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      monthKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}month_key'],
          )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      amountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_minor'],
          )!,
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final int id;
  final int monthKey;
  final int? accountId;
  final int amountMinor;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BudgetRow({
    required this.id,
    required this.monthKey,
    this.accountId,
    required this.amountMinor,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['month_key'] = Variable<int>(monthKey);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      monthKey: Value(monthKey),
      accountId:
          accountId == null && nullToAbsent
              ? const Value.absent()
              : Value(accountId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<int>(json['id']),
      monthKey: serializer.fromJson<int>(json['monthKey']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthKey': serializer.toJson<int>(monthKey),
      'accountId': serializer.toJson<int?>(accountId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BudgetRow copyWith({
    int? id,
    int? monthKey,
    Value<int?> accountId = const Value.absent(),
    int? amountMinor,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BudgetRow(
    id: id ?? this.id,
    monthKey: monthKey ?? this.monthKey,
    accountId: accountId.present ? accountId.value : this.accountId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('monthKey: $monthKey, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthKey,
    accountId,
    amountMinor,
    currencyCode,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.monthKey == this.monthKey &&
          other.accountId == this.accountId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<int> id;
  final Value<int> monthKey;
  final Value<int?> accountId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int monthKey,
    this.accountId = const Value.absent(),
    required int amountMinor,
    required String currencyCode,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : monthKey = Value(monthKey),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode);
  static Insertable<BudgetRow> custom({
    Expression<int>? id,
    Expression<int>? monthKey,
    Expression<int>? accountId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthKey != null) 'month_key': monthKey,
      if (accountId != null) 'account_id': accountId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<int>? monthKey,
    Value<int?>? accountId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      monthKey: monthKey ?? this.monthKey,
      accountId: accountId ?? this.accountId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<int>(monthKey.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('monthKey: $monthKey, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionDetailsTable transactionDetails =
      $TransactionDetailsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    transactions,
    transactionDetails,
    entries,
    budgets,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String name,
      required AccountType accountType,
      Value<AccountSubtype?> accountSubtype,
      Value<int?> parentId,
      required String currencyCode,
      Value<int> balanceMinor,
      Value<String?> iconKey,
      Value<String?> note,
      Value<int?> creditLimitMinor,
      Value<int?> billingDay,
      Value<int?> repaymentDay,
      Value<int> sortOrder,
      Value<bool> isHidden,
      Value<DateTime?> archivedAt,
      Value<SystemKey?> systemKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<AccountType> accountType,
      Value<AccountSubtype?> accountSubtype,
      Value<int?> parentId,
      Value<String> currencyCode,
      Value<int> balanceMinor,
      Value<String?> iconKey,
      Value<String?> note,
      Value<int?> creditLimitMinor,
      Value<int?> billingDay,
      Value<int?> repaymentDay,
      Value<int> sortOrder,
      Value<bool> isHidden,
      Value<DateTime?> archivedAt,
      Value<SystemKey?> systemKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _parentIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.accounts.parentId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.entries.accountId),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<BudgetRow>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.budgets.accountId),
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, String>
  get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountSubtype?, AccountSubtype, String>
  get accountSubtype => $composableBuilder(
    column: $table.accountSubtype,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repaymentDay => $composableBuilder(
    column: $table.repaymentDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SystemKey?, SystemKey, String> get systemKey =>
      $composableBuilder(
        column: $table.systemKey,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get parentId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountSubtype => $composableBuilder(
    column: $table.accountSubtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repaymentDay => $composableBuilder(
    column: $table.repaymentDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemKey => $composableBuilder(
    column: $table.systemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get parentId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, String> get accountType =>
      $composableBuilder(
        column: $table.accountType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<AccountSubtype?, String>
  get accountSubtype => $composableBuilder(
    column: $table.accountSubtype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repaymentDay => $composableBuilder(
    column: $table.repaymentDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SystemKey?, String> get systemKey =>
      $composableBuilder(column: $table.systemKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get parentId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool parentId,
            bool entriesRefs,
            bool budgetsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountType> accountType = const Value.absent(),
                Value<AccountSubtype?> accountSubtype = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int?> repaymentDay = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<SystemKey?> systemKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                accountType: accountType,
                accountSubtype: accountSubtype,
                parentId: parentId,
                currencyCode: currencyCode,
                balanceMinor: balanceMinor,
                iconKey: iconKey,
                note: note,
                creditLimitMinor: creditLimitMinor,
                billingDay: billingDay,
                repaymentDay: repaymentDay,
                sortOrder: sortOrder,
                isHidden: isHidden,
                archivedAt: archivedAt,
                systemKey: systemKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required AccountType accountType,
                Value<AccountSubtype?> accountSubtype = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                required String currencyCode,
                Value<int> balanceMinor = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int?> repaymentDay = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<SystemKey?> systemKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                accountType: accountType,
                accountSubtype: accountSubtype,
                parentId: parentId,
                currencyCode: currencyCode,
                balanceMinor: balanceMinor,
                iconKey: iconKey,
                note: note,
                creditLimitMinor: creditLimitMinor,
                billingDay: billingDay,
                repaymentDay: repaymentDay,
                sortOrder: sortOrder,
                isHidden: isHidden,
                archivedAt: archivedAt,
                systemKey: systemKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AccountsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            parentId = false,
            entriesRefs = false,
            budgetsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entriesRefs) db.entries,
                if (budgetsRefs) db.budgets,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (parentId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $$AccountsTableReferences
                                ._parentIdTable(db),
                            referencedColumn:
                                $$AccountsTableReferences._parentIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      AccountRow,
                      $AccountsTable,
                      EntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.accountId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (budgetsRefs)
                    await $_getPrefetchedData<
                      AccountRow,
                      $AccountsTable,
                      BudgetRow
                    >(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._budgetsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.accountId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool parentId,
        bool entriesRefs,
        bool budgetsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> rootTransactionId,
      required BusinessPurpose businessPurpose,
      required DateTime occurredAt,
      required String currencyCode,
      required int primaryAmountMinor,
      Value<String?> counterpartyName,
      Value<String?> note,
      Value<int?> parentTransactionId,
      Value<int?> reimbursementExpenseAccountId,
      required MutationKind mutationKind,
      Value<int?> mutationPreviousTransactionId,
      Value<MutationReason?> mutationReason,
      required BusinessState businessState,
      Value<bool> isExcludedFromStats,
      Value<bool> isExcludedFromBudget,
      required SourceKind sourceKind,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int?> rootTransactionId,
      Value<BusinessPurpose> businessPurpose,
      Value<DateTime> occurredAt,
      Value<String> currencyCode,
      Value<int> primaryAmountMinor,
      Value<String?> counterpartyName,
      Value<String?> note,
      Value<int?> parentTransactionId,
      Value<int?> reimbursementExpenseAccountId,
      Value<MutationKind> mutationKind,
      Value<int?> mutationPreviousTransactionId,
      Value<MutationReason?> mutationReason,
      Value<BusinessState> businessState,
      Value<bool> isExcludedFromStats,
      Value<bool> isExcludedFromBudget,
      Value<SourceKind> sourceKind,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _rootTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactions.rootTransactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager? get rootTransactionId {
    final $_column = $_itemColumn<int>('root_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rootTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _parentTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactions.parentTransactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager? get parentTransactionId {
    final $_column = $_itemColumn<int>('parent_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _mutationPreviousTransactionIdTable(
    _$AppDatabase db,
  ) => db.transactions.createAlias(
    $_aliasNameGenerator(
      db.transactions.mutationPreviousTransactionId,
      db.transactions.id,
    ),
  );

  $$TransactionsTableProcessedTableManager? get mutationPreviousTransactionId {
    final $_column = $_itemColumn<int>('mutation_previous_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _mutationPreviousTransactionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TransactionDetailsTable,
    List<TransactionDetailRow>
  >
  _transactionDetailsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionDetails,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.transactionDetails.transactionId,
        ),
      );

  $$TransactionDetailsTableProcessedTableManager get transactionDetailsRefs {
    final manager = $$TransactionDetailsTableTableManager(
      $_db,
      $_db.transactionDetails,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(
      db.transactions.id,
      db.entries.transactionId,
    ),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BusinessPurpose, BusinessPurpose, String>
  get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primaryAmountMinor => $composableBuilder(
    column: $table.primaryAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reimbursementExpenseAccountId => $composableBuilder(
    column: $table.reimbursementExpenseAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MutationKind, MutationKind, String>
  get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MutationReason?, MutationReason, String>
  get mutationReason => $composableBuilder(
    column: $table.mutationReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<BusinessState, BusinessState, String>
  get businessState => $composableBuilder(
    column: $table.businessState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isExcludedFromStats => $composableBuilder(
    column: $table.isExcludedFromStats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExcludedFromBudget => $composableBuilder(
    column: $table.isExcludedFromBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SourceKind, SourceKind, String>
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get rootTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get parentTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get mutationPreviousTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mutationPreviousTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionDetailsRefs(
    Expression<bool> Function($$TransactionDetailsTableFilterComposer f) f,
  ) {
    final $$TransactionDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionDetails,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionDetailsTableFilterComposer(
            $db: $db,
            $table: $db.transactionDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primaryAmountMinor => $composableBuilder(
    column: $table.primaryAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reimbursementExpenseAccountId => $composableBuilder(
    column: $table.reimbursementExpenseAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationReason => $composableBuilder(
    column: $table.mutationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessState => $composableBuilder(
    column: $table.businessState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExcludedFromStats => $composableBuilder(
    column: $table.isExcludedFromStats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExcludedFromBudget => $composableBuilder(
    column: $table.isExcludedFromBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get rootTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get parentTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get mutationPreviousTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mutationPreviousTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BusinessPurpose, String>
  get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primaryAmountMinor => $composableBuilder(
    column: $table.primaryAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyName => $composableBuilder(
    column: $table.counterpartyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get reimbursementExpenseAccountId => $composableBuilder(
    column: $table.reimbursementExpenseAccountId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MutationKind, String> get mutationKind =>
      $composableBuilder(
        column: $table.mutationKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MutationReason?, String>
  get mutationReason => $composableBuilder(
    column: $table.mutationReason,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BusinessState, String> get businessState =>
      $composableBuilder(
        column: $table.businessState,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isExcludedFromStats => $composableBuilder(
    column: $table.isExcludedFromStats,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExcludedFromBudget => $composableBuilder(
    column: $table.isExcludedFromBudget,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SourceKind, String> get sourceKind =>
      $composableBuilder(
        column: $table.sourceKind,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get rootTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get parentTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get mutationPreviousTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mutationPreviousTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionDetailsRefs<T extends Object>(
    Expression<T> Function($$TransactionDetailsTableAnnotationComposer a) f,
  ) {
    final $$TransactionDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionDetails,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({
            bool rootTransactionId,
            bool parentTransactionId,
            bool mutationPreviousTransactionId,
            bool transactionDetailsRefs,
            bool entriesRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rootTransactionId = const Value.absent(),
                Value<BusinessPurpose> businessPurpose = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> primaryAmountMinor = const Value.absent(),
                Value<String?> counterpartyName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> parentTransactionId = const Value.absent(),
                Value<int?> reimbursementExpenseAccountId =
                    const Value.absent(),
                Value<MutationKind> mutationKind = const Value.absent(),
                Value<int?> mutationPreviousTransactionId =
                    const Value.absent(),
                Value<MutationReason?> mutationReason = const Value.absent(),
                Value<BusinessState> businessState = const Value.absent(),
                Value<bool> isExcludedFromStats = const Value.absent(),
                Value<bool> isExcludedFromBudget = const Value.absent(),
                Value<SourceKind> sourceKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                rootTransactionId: rootTransactionId,
                businessPurpose: businessPurpose,
                occurredAt: occurredAt,
                currencyCode: currencyCode,
                primaryAmountMinor: primaryAmountMinor,
                counterpartyName: counterpartyName,
                note: note,
                parentTransactionId: parentTransactionId,
                reimbursementExpenseAccountId: reimbursementExpenseAccountId,
                mutationKind: mutationKind,
                mutationPreviousTransactionId: mutationPreviousTransactionId,
                mutationReason: mutationReason,
                businessState: businessState,
                isExcludedFromStats: isExcludedFromStats,
                isExcludedFromBudget: isExcludedFromBudget,
                sourceKind: sourceKind,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rootTransactionId = const Value.absent(),
                required BusinessPurpose businessPurpose,
                required DateTime occurredAt,
                required String currencyCode,
                required int primaryAmountMinor,
                Value<String?> counterpartyName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> parentTransactionId = const Value.absent(),
                Value<int?> reimbursementExpenseAccountId =
                    const Value.absent(),
                required MutationKind mutationKind,
                Value<int?> mutationPreviousTransactionId =
                    const Value.absent(),
                Value<MutationReason?> mutationReason = const Value.absent(),
                required BusinessState businessState,
                Value<bool> isExcludedFromStats = const Value.absent(),
                Value<bool> isExcludedFromBudget = const Value.absent(),
                required SourceKind sourceKind,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                rootTransactionId: rootTransactionId,
                businessPurpose: businessPurpose,
                occurredAt: occurredAt,
                currencyCode: currencyCode,
                primaryAmountMinor: primaryAmountMinor,
                counterpartyName: counterpartyName,
                note: note,
                parentTransactionId: parentTransactionId,
                reimbursementExpenseAccountId: reimbursementExpenseAccountId,
                mutationKind: mutationKind,
                mutationPreviousTransactionId: mutationPreviousTransactionId,
                mutationReason: mutationReason,
                businessState: businessState,
                isExcludedFromStats: isExcludedFromStats,
                isExcludedFromBudget: isExcludedFromBudget,
                sourceKind: sourceKind,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TransactionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            rootTransactionId = false,
            parentTransactionId = false,
            mutationPreviousTransactionId = false,
            transactionDetailsRefs = false,
            entriesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionDetailsRefs) db.transactionDetails,
                if (entriesRefs) db.entries,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (rootTransactionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.rootTransactionId,
                            referencedTable: $$TransactionsTableReferences
                                ._rootTransactionIdTable(db),
                            referencedColumn:
                                $$TransactionsTableReferences
                                    ._rootTransactionIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (parentTransactionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentTransactionId,
                            referencedTable: $$TransactionsTableReferences
                                ._parentTransactionIdTable(db),
                            referencedColumn:
                                $$TransactionsTableReferences
                                    ._parentTransactionIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (mutationPreviousTransactionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.mutationPreviousTransactionId,
                            referencedTable: $$TransactionsTableReferences
                                ._mutationPreviousTransactionIdTable(db),
                            referencedColumn:
                                $$TransactionsTableReferences
                                    ._mutationPreviousTransactionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionDetailsRefs)
                    await $_getPrefetchedData<
                      TransactionRow,
                      $TransactionsTable,
                      TransactionDetailRow
                    >(
                      currentTable: table,
                      referencedTable: $$TransactionsTableReferences
                          ._transactionDetailsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionDetailsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      TransactionRow,
                      $TransactionsTable,
                      EntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$TransactionsTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({
        bool rootTransactionId,
        bool parentTransactionId,
        bool mutationPreviousTransactionId,
        bool transactionDetailsRefs,
        bool entriesRefs,
      })
    >;
typedef $$TransactionDetailsTableCreateCompanionBuilder =
    TransactionDetailsCompanion Function({
      Value<int> id,
      required int transactionId,
      required int lineNo,
      required TransactionDetailType detailType,
      required int amountMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionDetailsTableUpdateCompanionBuilder =
    TransactionDetailsCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<int> lineNo,
      Value<TransactionDetailType> detailType,
      Value<int> amountMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionDetailsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionDetailsTable,
          TransactionDetailRow
        > {
  $$TransactionDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactionDetails.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionDetailsTable> {
  $$TransactionDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransactionDetailType,
    TransactionDetailType,
    String
  >
  get detailType => $composableBuilder(
    column: $table.detailType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionDetailsTable> {
  $$TransactionDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailType => $composableBuilder(
    column: $table.detailType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionDetailsTable> {
  $$TransactionDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionDetailType, String>
  get detailType => $composableBuilder(
    column: $table.detailType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionDetailsTable,
          TransactionDetailRow,
          $$TransactionDetailsTableFilterComposer,
          $$TransactionDetailsTableOrderingComposer,
          $$TransactionDetailsTableAnnotationComposer,
          $$TransactionDetailsTableCreateCompanionBuilder,
          $$TransactionDetailsTableUpdateCompanionBuilder,
          (TransactionDetailRow, $$TransactionDetailsTableReferences),
          TransactionDetailRow,
          PrefetchHooks Function({bool transactionId})
        > {
  $$TransactionDetailsTableTableManager(
    _$AppDatabase db,
    $TransactionDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransactionDetailsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$TransactionDetailsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TransactionDetailsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<TransactionDetailType> detailType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionDetailsCompanion(
                id: id,
                transactionId: transactionId,
                lineNo: lineNo,
                detailType: detailType,
                amountMinor: amountMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required int lineNo,
                required TransactionDetailType detailType,
                required int amountMinor,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionDetailsCompanion.insert(
                id: id,
                transactionId: transactionId,
                lineNo: lineNo,
                detailType: detailType,
                amountMinor: amountMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TransactionDetailsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (transactionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.transactionId,
                            referencedTable: $$TransactionDetailsTableReferences
                                ._transactionIdTable(db),
                            referencedColumn:
                                $$TransactionDetailsTableReferences
                                    ._transactionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionDetailsTable,
      TransactionDetailRow,
      $$TransactionDetailsTableFilterComposer,
      $$TransactionDetailsTableOrderingComposer,
      $$TransactionDetailsTableAnnotationComposer,
      $$TransactionDetailsTableCreateCompanionBuilder,
      $$TransactionDetailsTableUpdateCompanionBuilder,
      (TransactionDetailRow, $$TransactionDetailsTableReferences),
      TransactionDetailRow,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required int transactionId,
      required int accountId,
      required EntryDirection direction,
      required int amountMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<int> accountId,
      Value<EntryDirection> direction,
      Value<int> amountMinor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, EntryRow> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(db.entries.transactionId, db.transactions.id),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.entries.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntryDirection, EntryDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, $$EntriesTableReferences),
          EntryRow,
          PrefetchHooks Function({bool transactionId, bool accountId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<EntryDirection> direction = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                transactionId: transactionId,
                accountId: accountId,
                direction: direction,
                amountMinor: amountMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required int accountId,
                required EntryDirection direction,
                required int amountMinor,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                transactionId: transactionId,
                accountId: accountId,
                direction: direction,
                amountMinor: amountMinor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$EntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({transactionId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (transactionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.transactionId,
                            referencedTable: $$EntriesTableReferences
                                ._transactionIdTable(db),
                            referencedColumn:
                                $$EntriesTableReferences
                                    ._transactionIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (accountId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$EntriesTableReferences
                                ._accountIdTable(db),
                            referencedColumn:
                                $$EntriesTableReferences._accountIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, $$EntriesTableReferences),
      EntryRow,
      PrefetchHooks Function({bool transactionId, bool accountId})
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required int monthKey,
      Value<int?> accountId,
      required int amountMinor,
      required String currencyCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<int> monthKey,
      Value<int?> accountId,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.budgets.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetRow,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetRow, $$BudgetsTableReferences),
          BudgetRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> monthKey = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                monthKey: monthKey,
                accountId: accountId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int monthKey,
                Value<int?> accountId = const Value.absent(),
                required int amountMinor,
                required String currencyCode,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                monthKey: monthKey,
                accountId: accountId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$BudgetsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (accountId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$BudgetsTableReferences
                                ._accountIdTable(db),
                            referencedColumn:
                                $$BudgetsTableReferences._accountIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      BudgetRow,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetRow, $$BudgetsTableReferences),
      BudgetRow,
      PrefetchHooks Function({bool accountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionDetailsTableTableManager get transactionDetails =>
      $$TransactionDetailsTableTableManager(_db, _db.transactionDetails);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
}
