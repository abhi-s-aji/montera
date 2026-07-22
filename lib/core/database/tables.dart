import 'package:drift/drift.dart';

// Base Mixin for Common Columns across all tables
mixin BaseTableMixin on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 1. Accounts Table
class Accounts extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type =>
      text()(); // checking, savings, credit_card, cash, investment
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  TextColumn get icon =>
      text().withDefault(const Constant('account_balance'))();
  TextColumn get colorHex => text()
      .withLength(min: 7, max: 9)
      .withDefault(const Constant('#6366F1'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  List<Index> get indexes => [
        Index('idx_accounts_type',
            'CREATE INDEX idx_accounts_type ON accounts (type)')
      ];
}

// 2. Categories Table
class Categories extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // income, expense, transfer
  TextColumn get parentCategoryId =>
      text().nullable().references(Categories, #id)();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get colorHex => text()
      .withLength(min: 7, max: 9)
      .withDefault(const Constant('#10B981'))();

  @override
  List<Index> get indexes => [
        Index('idx_categories_parent',
            'CREATE INDEX idx_categories_parent ON categories (parent_category_id)')
      ];
}

// 3. Merchants Table
class Merchants extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get defaultCategoryId =>
      text().nullable().references(Categories, #id)();
  TextColumn get icon => text().nullable()();

  @override
  List<Index> get indexes => [
        Index('idx_merchants_name',
            'CREATE INDEX idx_merchants_name ON merchants (name)')
      ];
}

// 4. Transactions Table
class Transactions extends Table with BaseTableMixin {
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get destinationAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get merchantId => text().nullable().references(Merchants, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(
      const Constant('completed'))(); // pending, completed, uncleared

  @override
  List<Index> get indexes => [
        Index('idx_transactions_date',
            'CREATE INDEX idx_transactions_date ON transactions (date)'),
        Index('idx_transactions_account',
            'CREATE INDEX idx_transactions_account ON transactions (account_id)'),
        Index('idx_transactions_category',
            'CREATE INDEX idx_transactions_category ON transactions (category_id)'),
        Index('idx_transactions_merchant',
            'CREATE INDEX idx_transactions_merchant ON transactions (merchant_id)'),
      ];
}

// 5. Tags Table
class Tags extends Table with BaseTableMixin {
  TextColumn get name => text().unique().withLength(min: 1, max: 50)();
  TextColumn get colorHex => text()
      .withLength(min: 7, max: 9)
      .withDefault(const Constant('#3B82F6'))();
}

// 6. TransactionTags Join Table
class TransactionTags extends Table {
  TextColumn get transactionId => text().references(Transactions, #id,
      onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text().references(Tags, #id,
      onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}

// 7. Budgets Table
class Budgets extends Table with BaseTableMixin {
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text()
      .withDefault(const Constant('monthly'))(); // monthly, yearly, custom
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();

  @override
  List<Index> get indexes => [
        Index('idx_budgets_category',
            'CREATE INDEX idx_budgets_category ON budgets (category_id)')
      ];
}

// 8. Goals Table
class Goals extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get linkedAccountId =>
      text().nullable().references(Accounts, #id)();
}

// 9. Attachments Table
class Attachments extends Table with BaseTableMixin {
  TextColumn get transactionId => text().references(Transactions, #id,
      onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  IntColumn get fileSize => integer()();
}

// 10. Currencies Table
class Currencies extends Table {
  TextColumn get code => text().withLength(min: 3, max: 3)(); // USD, EUR, GBP
  TextColumn get name => text()();
  TextColumn get symbol => text()();

  @override
  Set<Column> get primaryKey => {code};
}

// 11. ExchangeRates Table
class ExchangeRates extends Table with BaseTableMixin {
  TextColumn get baseCurrency => text().references(Currencies, #code)();
  TextColumn get targetCurrency => text().references(Currencies, #code)();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();
}

// 12. Settings Table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// 13. DashboardLayouts Table
class DashboardLayouts extends Table with BaseTableMixin {
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

// 14. DashboardWidgets Table
class DashboardWidgets extends Table with BaseTableMixin {
  TextColumn get layoutId => text().references(DashboardLayouts, #id,
      onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get widgetType => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get configurationJson => text().nullable()();
}

// 15. Notifications Table
class Notifications extends Table with BaseTableMixin {
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text()(); // budget_alert, goal_milestone, system
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

// 16. BackupMetadata Table
class BackupMetadata extends Table with BaseTableMixin {
  TextColumn get fileName => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get recordCount => integer()();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(true))();
}

// 17. PluginMetadata Table
class PluginMetadata extends Table with BaseTableMixin {
  TextColumn get pluginId => text().unique()();
  TextColumn get name => text()();
  TextColumn get pluginVersion => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
}

// 18. FutureSyncMetadata Table
class FutureSyncMetadata extends Table with BaseTableMixin {
  TextColumn get syncEntityName => text()();
  TextColumn get lastSyncedSequence => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();
}
