// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'd18c6b65455a5da1e8787472648c66c231ce9741';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'237ab55433bc628170e8a7fddf828014bc7141b5';

@ProviderFor(postingRepository)
final postingRepositoryProvider = PostingRepositoryProvider._();

final class PostingRepositoryProvider
    extends
        $FunctionalProvider<
          PostingRepository,
          PostingRepository,
          PostingRepository
        >
    with $Provider<PostingRepository> {
  PostingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postingRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PostingRepository create(Ref ref) {
    return postingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostingRepository>(value),
    );
  }
}

String _$postingRepositoryHash() => r'3f65f8d3cd45f7b9f70f5cb598b6d6e847518ad1';

@ProviderFor(transactionQueryRepository)
final transactionQueryRepositoryProvider =
    TransactionQueryRepositoryProvider._();

final class TransactionQueryRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionQueryRepository,
          TransactionQueryRepository,
          TransactionQueryRepository
        >
    with $Provider<TransactionQueryRepository> {
  TransactionQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionQueryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionQueryRepository create(Ref ref) {
    return transactionQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionQueryRepository>(value),
    );
  }
}

String _$transactionQueryRepositoryHash() =>
    r'7d7f7862b1445138292134dec6a709e558fbc82f';

@ProviderFor(accountService)
final accountServiceProvider = AccountServiceProvider._();

final class AccountServiceProvider
    extends $FunctionalProvider<AccountService, AccountService, AccountService>
    with $Provider<AccountService> {
  AccountServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountServiceHash();

  @$internal
  @override
  $ProviderElement<AccountService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountService create(Ref ref) {
    return accountService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountService>(value),
    );
  }
}

String _$accountServiceHash() => r'8b3fee17b78242fe97ff2f648e3564c7cebf8c5f';

@ProviderFor(categoryService)
final categoryServiceProvider = CategoryServiceProvider._();

final class CategoryServiceProvider
    extends
        $FunctionalProvider<CategoryService, CategoryService, CategoryService>
    with $Provider<CategoryService> {
  CategoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryServiceHash();

  @$internal
  @override
  $ProviderElement<CategoryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryService create(Ref ref) {
    return categoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryService>(value),
    );
  }
}

String _$categoryServiceHash() => r'c576c3f8ce0d2d70485652aedfa43551f60ebdba';

@ProviderFor(postingService)
final postingServiceProvider = PostingServiceProvider._();

final class PostingServiceProvider
    extends $FunctionalProvider<PostingService, PostingService, PostingService>
    with $Provider<PostingService> {
  PostingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postingServiceHash();

  @$internal
  @override
  $ProviderElement<PostingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostingService create(Ref ref) {
    return postingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostingService>(value),
    );
  }
}

String _$postingServiceHash() => r'd6ade9ef20c33eafa484de7e74493e540b28cc92';

@ProviderFor(transactionService)
final transactionServiceProvider = TransactionServiceProvider._();

final class TransactionServiceProvider
    extends
        $FunctionalProvider<
          TransactionService,
          TransactionService,
          TransactionService
        >
    with $Provider<TransactionService> {
  TransactionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionServiceHash();

  @$internal
  @override
  $ProviderElement<TransactionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionService create(Ref ref) {
    return transactionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionService>(value),
    );
  }
}

String _$transactionServiceHash() =>
    r'1da3af54aaf4720a6a43c2ee926a447c559405df';

@ProviderFor(transactionQueryService)
final transactionQueryServiceProvider = TransactionQueryServiceProvider._();

final class TransactionQueryServiceProvider
    extends
        $FunctionalProvider<
          TransactionQueryService,
          TransactionQueryService,
          TransactionQueryService
        >
    with $Provider<TransactionQueryService> {
  TransactionQueryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionQueryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionQueryServiceHash();

  @$internal
  @override
  $ProviderElement<TransactionQueryService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionQueryService create(Ref ref) {
    return transactionQueryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionQueryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionQueryService>(value),
    );
  }
}

String _$transactionQueryServiceHash() =>
    r'6e6488ddf0a18422e56a6510c1ca3503aae56ed9';

@ProviderFor(accountList)
final accountListProvider = AccountListProvider._();

final class AccountListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Account>>,
          List<Account>,
          Stream<List<Account>>
        >
    with $FutureModifier<List<Account>>, $StreamProvider<List<Account>> {
  AccountListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @$internal
  @override
  $StreamProviderElement<List<Account>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Account>> create(Ref ref) {
    return accountList(ref);
  }
}

String _$accountListHash() => r'604f0ccedf8e249a36081a3c95152268e618d6a8';

@ProviderFor(categoryTree)
final categoryTreeProvider = CategoryTreeFamily._();

final class CategoryTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryNode>>,
          List<CategoryNode>,
          Stream<List<CategoryNode>>
        >
    with
        $FutureModifier<List<CategoryNode>>,
        $StreamProvider<List<CategoryNode>> {
  CategoryTreeProvider._({
    required CategoryTreeFamily super.from,
    required AccountType super.argument,
  }) : super(
         retry: null,
         name: r'categoryTreeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryTreeHash();

  @override
  String toString() {
    return r'categoryTreeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CategoryNode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryNode>> create(Ref ref) {
    final argument = this.argument as AccountType;
    return categoryTree(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTreeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryTreeHash() => r'b36933c3f92afd9f64032f635700417c63b68347';

final class CategoryTreeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CategoryNode>>, AccountType> {
  CategoryTreeFamily._()
    : super(
        retry: null,
        name: r'categoryTreeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryTreeProvider call(AccountType type) =>
      CategoryTreeProvider._(argument: type, from: this);

  @override
  String toString() => r'categoryTreeProvider';
}

@ProviderFor(transactionList)
final transactionListProvider = TransactionListFamily._();

final class TransactionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionListItem>>,
          List<TransactionListItem>,
          Stream<List<TransactionListItem>>
        >
    with
        $FutureModifier<List<TransactionListItem>>,
        $StreamProvider<List<TransactionListItem>> {
  TransactionListProvider._({
    required TransactionListFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'transactionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @override
  String toString() {
    return r'transactionListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionListItem>> create(Ref ref) {
    final argument = this.argument as int?;
    return transactionList(ref, accountId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionListHash() => r'21ebaa59974d55766854975f6fa0174fcb14f16f';

final class TransactionListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionListItem>>, int?> {
  TransactionListFamily._()
    : super(
        retry: null,
        name: r'transactionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionListProvider call({int? accountId}) =>
      TransactionListProvider._(argument: accountId, from: this);

  @override
  String toString() => r'transactionListProvider';
}

@ProviderFor(transactionDetail)
final transactionDetailProvider = TransactionDetailFamily._();

final class TransactionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransactionDetailView?>,
          TransactionDetailView?,
          Stream<TransactionDetailView?>
        >
    with
        $FutureModifier<TransactionDetailView?>,
        $StreamProvider<TransactionDetailView?> {
  TransactionDetailProvider._({
    required TransactionDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'transactionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionDetailHash();

  @override
  String toString() {
    return r'transactionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TransactionDetailView?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TransactionDetailView?> create(Ref ref) {
    final argument = this.argument as int;
    return transactionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionDetailHash() => r'3efe1433f9d21e4259ec053c1ca1542720b5a575';

final class TransactionDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TransactionDetailView?>, int> {
  TransactionDetailFamily._()
    : super(
        retry: null,
        name: r'transactionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionDetailProvider call(int transactionId) =>
      TransactionDetailProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionDetailProvider';
}
