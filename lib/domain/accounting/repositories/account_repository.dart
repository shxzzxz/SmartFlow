import '../entities/account.dart';
import '../enums/accounting_enums.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';

abstract interface class AccountRepository {
  Future<Account?> findAccountById(int id);

  Future<List<Account>> findAccountsByIds(Set<int> ids);

  Stream<List<Account>> watchAccounts(Set<AccountType> types);

  Future<Account> createAccount(CreateAccountCommand command);

  Future<void> updateAccount(EditAccountCommand command);
}

abstract interface class CategoryRepository {
  Future<Account?> findCategoryById(int id);

  Stream<List<Account>> watchCategories(AccountType type);

  Future<Account> createCategory(CreateCategoryCommand command);
}
