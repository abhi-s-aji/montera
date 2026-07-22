# Database & Data Model Design Document (DDD)
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-DDD  
**Status:** Approved Technical Architecture  
**Author:** Lead Database Architect & Technical Steering Committee  

---

## 1. Database Philosophy

### 1.1 Why SQLite + Drift Was Chosen
Monetra selected **SQLite** paired with the **Drift** ORM abstraction framework as its primary persistence stack based on the following core architectural pillars:
- **Local Autonomy & Zero Cloud Egress**: SQLite operates directly on the user's host filesystem via embedded C binaries, guaranteeing complete data sovereignty without external server dependencies.
- **ACID Compliance**: Full support for Atomic, Consistent, Isolated, and Durable transactions ensures financial ledgers remain non-corruptible even during ungraceful app terminations or battery outages.
- **Type Safety via Drift**: Drift translates SQLite schemas into static, compile-time verified Dart objects, eliminating runtime SQL injection vectors and type casting runtime errors.
- **Reactive Stream Engine**: Native integration with SQLite update hooks enables live, push-based table observation. UI components automatically update upon database commits without polling.
- **Platform Portability**: Identical C engine behavior across Linux, macOS, Windows, Android, iOS, and Web (via WebAssembly + Origin Private File System).

---

## 2. Data Modeling Principles

### 2.1 Normalization vs. Tactical Denormalization
- **Third Normal Form (3NF)**: Enforced for financial transactions, accounts, categories, and tags to eliminate update anomalies and data duplication.
- **Tactical Denormalization**: `AccountsTable.balance` is updated via transactional triggers to avoid $O(N)$ table scans over millions of historical transactions during frequent dashboard balance reads.

### 2.2 Standard Column Attributes
Every entity table in Monetra MUST implement the mandatory **Core 5 Governance Attributes**:
1. `id` (TEXT UUID v4): Universal unique identifier.
2. `created_at` (INTEGER): UTC epoch timestamp in milliseconds.
3. `updated_at` (INTEGER): UTC epoch timestamp in milliseconds.
4. `version` (INTEGER): Incremental integer counter for optimistic concurrency and vector-clock sync.
5. `is_deleted` (INTEGER 0/1): Soft-delete flag preserving tombstone records for local and remote sync engines.

### 2.3 Foreign Keys & Referencing Behavior
- `ON DELETE RESTRICT`: Default constraint preventing deletion of parent categories or accounts referenced by active transactions.
- `ON DELETE CASCADE`: Applied strictly to weak dependent entities (e.g., `TransactionTagsTable` entries deleted when parent `Transaction` is deleted).

---

## 3. Entity Relationship Model

```text
+-------------------+       1:N        +-----------------------+        N:M        +-------------------+
|   AccountsTable   |------------------|   TransactionsTable   |-------------------|     TagsTable     |
+-------------------+                  +-----------------------+                   +-------------------+
| id (PK)           |                  | id (PK)               |                   | id (PK)           |
| name              |                  | account_id (FK)       |                   | name              |
| type              |                  | dest_account_id (FK)  |                   +-------------------+
| balance           |                  | category_id (FK)      |                             | (via TransactionTags)
+-------------------+                  | merchant_id (FK)      |                             v
                                       | amount                |                   +-------------------+
+-------------------+       1:N        | date                  |                   | TransactionTags   |
|  CategoriesTable  |------------------+-----------------------+                   +-------------------+
+-------------------+                              | 1:N                           | transaction_id(FK)|
| id (PK)           |                              v                               | tag_id (FK)       |
| name              |                  +-----------------------+                   +-------------------+
| parent_id (FK)    |                  |   AttachmentsTable    |
+-------------------+                  +-----------------------+
                                       | id (PK)               |
+-------------------+       1:N        | transaction_id (FK)   |
|  MerchantsTable   |------------------+ path                  |
+-------------------+                  +-----------------------+
| id (PK)           |
| name              |                  +-----------------------+       1:N         +-------------------+
| default_cat_id(FK)|                  |     BudgetsTable      |-------------------|   GoalsTable      |
+-------------------+                  +-----------------------+                   +-------------------+
                                       | id (PK)               |                   | id (PK)           |
                                       | category_id (FK)      |                   | target_amount     |
                                       +-----------------------+                   +-------------------+
```

---

## 4. Table Specifications

### 4.1 `AccountsTable`
- **Purpose**: Stores individual financial accounts (checking, savings, credit, cash, investments).
- **Columns**: `id` (TEXT PK), `name` (TEXT NOT NULL), `type` (TEXT NOT NULL), `currency` (TEXT NOT NULL), `balance` (REAL NOT NULL DEFAULT 0.0), `icon` (TEXT), `color_hex` (TEXT), `is_archived` (INTEGER DEFAULT 0), `created_at` (INTEGER), `updated_at` (INTEGER), `version` (INTEGER DEFAULT 1), `is_deleted` (INTEGER DEFAULT 0).
- **Constraints**: `CHECK(type IN ('checking','savings','credit','investment','cash','loan'))`.
- **Indexes**: `idx_accounts_type` ON `(type, is_archived)`.

### 4.2 `TransactionsTable`
- **Purpose**: Core financial ledger table storing income, expense, and account transfer records.
- **Columns**: `id` (TEXT PK), `account_id` (TEXT NOT NULL FK), `destination_account_id` (TEXT NULL FK), `category_id` (TEXT NULL FK), `merchant_id` (TEXT NULL FK), `amount` (REAL NOT NULL), `date` (INTEGER NOT NULL), `description` (TEXT NOT NULL), `notes` (TEXT), `status` (TEXT DEFAULT 'completed'), `is_recurring` (INTEGER DEFAULT 0), `created_at` (INTEGER), `updated_at` (INTEGER), `version` (INTEGER DEFAULT 1), `is_deleted` (INTEGER DEFAULT 0).
- **Constraints**: `FOREIGN KEY(account_id) REFERENCES AccountsTable(id) ON DELETE RESTRICT`.
- **Indexes**: `idx_tx_date` ON `(date DESC)`, `idx_tx_account` ON `(account_id)`, `idx_tx_category` ON `(category_id)`.

### 4.3 `CategoriesTable`
- **Purpose**: Stores category taxonomy and hierarchical parent-child mappings.
- **Columns**: `id` (TEXT PK), `name` (TEXT NOT NULL), `type` (TEXT NOT NULL), `parent_id` (TEXT NULL FK), `icon` (TEXT), `color_hex` (TEXT), `created_at` (INTEGER), `updated_at` (INTEGER), `version` (INTEGER DEFAULT 1), `is_deleted` (INTEGER DEFAULT 0).
- **Constraints**: `FOREIGN KEY(parent_id) REFERENCES CategoriesTable(id) ON DELETE RESTRICT`.

### 4.4 `MerchantsTable`
- **Purpose**: Normalizes payee/merchant strings for spending analytics and category auto-assignment.
- **Columns**: `id` (TEXT PK), `name` (TEXT UNIQUE NOT NULL), `default_category_id` (TEXT NULL FK), `logo_path` (TEXT), `created_at` (INTEGER), `updated_at` (INTEGER), `version` (INTEGER DEFAULT 1), `is_deleted` (INTEGER DEFAULT 0).

### 4.5 `BudgetsTable`
- **Purpose**: Defines spending caps and period limits per category or tag group.
- **Columns**: `id` (TEXT PK), `category_id` (TEXT NOT NULL FK), `amount` (REAL NOT NULL), `period` (TEXT NOT NULL), `start_date` (INTEGER), `end_date` (INTEGER), `created_at` (INTEGER), `updated_at` (INTEGER), `version` (INTEGER DEFAULT 1), `is_deleted` (INTEGER DEFAULT 0).

### 4.6 `TagsTable` & `TransactionTagsTable`
- **Purpose**: Implements N:M multi-tag classification per transaction.
- **Columns (`TagsTable`)**: `id` (TEXT PK), `name` (TEXT UNIQUE NOT NULL).
- **Columns (`TransactionTagsTable`)**: `transaction_id` (TEXT FK), `tag_id` (TEXT FK), PRIMARY KEY `(transaction_id, tag_id)`.

---

## 5. Primary Key & Identification Strategy

- **Format**: Standard 128-bit RFC 4122 **UUID v4** encoded as 36-character hyphenated strings (`TEXT`).
- **Collision Immunity**: Statistically zero probability ($1\text{ in }2^{122}$) of collision across independent offline devices.
- **Synchronization Compatibility**: Allows offline client instances to create accounts, categories, and transactions simultaneously without central authority sequence coordination.

---

## 6. Indexing Strategy & Performance Tuning

### 6.1 Defined Indexes & Rationale

| Index Name | Target Table | Indexed Columns | Architectural Purpose |
| :--- | :--- | :--- | :--- |
| `idx_tx_date_desc` | `TransactionsTable` | `(date DESC, is_deleted)` | Fast ledger pagination & chronological sorting |
| `idx_tx_account_date` | `TransactionsTable` | `(account_id, date DESC)` | Instant single-account history filtering |
| `idx_tx_cat_date` | `TransactionsTable` | `(category_id, date DESC)` | Rapid budget burn rate calculation |
| `idx_categories_parent`| `CategoriesTable` | `(parent_id)` | Fast recursive tree traversal |

### 6.2 Partial Indexes
To minimize disk index footprint, soft-deleted tombstone records are excluded from active search indexes:
`CREATE INDEX idx_tx_active_search ON TransactionsTable(description) WHERE is_deleted = 0;`

---

## 7. Full-Text Search (SQLite FTS5 Architecture)

### 7.1 Virtual Table Definition
Monetra implements an external content FTS5 virtual table (`fts_transactions`):
- **Indexed Fields**: `description`, `notes`, `tags_flat_string`, `merchant_name`.
- **Tokenizer**: `unicode61 remove_diacritics 1 tokenchars '-_#'` (enables exact matching on transaction tags such as `#tax-2026`).

### 7.2 Trigger Synchronized Updates
SQLite `AFTER INSERT`, `AFTER UPDATE`, and `AFTER DELETE` triggers keep `fts_transactions` instantly aligned with mutations on `TransactionsTable`.

---

## 8. Transaction Lifecycle & Audit Trail

### 8.1 Mutation Protocol
1. **Creation**: Insert row into `TransactionsTable` with `version = 1`. Transactional trigger updates target `AccountsTable.balance`.
2. **Update**: Increment `version = version + 1`, update `updated_at = UTC_NOW()`. Balance diff applied to `AccountsTable`.
3. **Soft Delete**: Set `is_deleted = 1`, `updated_at = UTC_NOW()`. Revert transaction effect on `AccountsTable.balance`. Tombstone retained for sync propagation.

---

## 9. Category Taxonomy Model

- **Unlimited Nesting Support**: Supported via `parent_id` self-referencing foreign key.
- **Loop Prevention**: Application layer & database triggers prevent cyclic ancestor-descendant links (`parent_id != id`).
- **Inherited Metrics**: Rolling up child category expenditures into parent category totals executes via recursive CTE queries.

---

## 10. Merchant Normalization & Auto-Categorization

- **String Cleaning**: Merchant matching algorithm strips common suffixes (e.g., `INC`, `LLC`, `STORE #1024`).
- **Auto-Category Mapping**: When a new transaction matches an established `merchant_id`, `category_id` defaults automatically to `MerchantsTable.default_category_id`.

---

## 11. Account & Balance Architecture

### 11.1 Balance Consistency Rule
Account balances are derived deterministically:
$$\text{Current Balance} = \text{Initial Balance} + \sum \text{Active Incomes} - \sum \text{Active Expenses} \pm \text{Transfers}$$

### 11.2 Multi-Currency Architecture
Every account stores native currency (`USD`, `EUR`, `INR`). Multi-currency net worth calculations multiply native balances by cached rates in `ExchangeRatesTable`.

---

## 12. Budget Data Architecture

- **Period Types**: `monthly`, `weekly`, `yearly`, `custom`.
- **Rollover Budgets**: Evaluated dynamically by comparing previous period surplus/deficit against current allocation.

---

## 13. Goals Architecture

- `GoalsTable` links to target amounts, deadline dates, and linked `account_id` or `tag_id`.
- Savings milestone progress derived reactively from real-time sum of linked account balances.

---

## 14. Attachment Storage Architecture

- **Physical Files**: Stored locally in app sandboxed directory (`/app_data/attachments/{UUID}.jpg`).
- **Database Metadata (`AttachmentsTable`)**: Stores `id`, `transaction_id`, `file_path`, `mime_type`, `file_size`, `hash_sha256`.

---

## 15. Analytics Data Strategy & Caching

- **Raw Ledger Storage**: Source of truth stored un-aggregated.
- **Materialized Views**: Daily spending summary cached in SQLite temporary tables (`temp_daily_cashflow`) to provide instant $0\text{ms}$ visual chart renders for >100,000 records.

---

## 16. Dashboard & Customization Persistence

- `UserSettingsTable`: Key-value persistence (`key` TEXT PK, `value` TEXT JSON).
- Stores active theme mode, accent color hex, layout density, and drag-and-drop dashboard widget array ordering.

---

## 17. Backup Schema Specification

Backup files export as single self-contained encrypted or raw JSON objects (`monetra_backup_v1.json`):

```json
{
  "manifest": {
    "app": "Monetra",
    "schema_version": 1,
    "exported_at": 1784747040000,
    "device_id": "uuid-v4"
  },
  "tables": {
    "accounts": [],
    "categories": [],
    "merchants": [],
    "transactions": [],
    "budgets": [],
    "tags": [],
    "transaction_tags": []
  }
}
```

---

## 18. Synchronization Readiness Protocol

The database design guarantees seamless future P2P / WebDAV / Nextcloud synchronization:
- **Tombstones**: Soft-deletes preserve deleted UUIDs for 90 days.
- **Vector Clock Invariant**: `version` increments on every mutation.
- **Conflict Resolution Matrix**: High `version` wins; ties resolved by latest `updated_at` UTC timestamp.

---

## 19. Database Migration Strategy

- **Engine**: Drift `MigrationStrategy` schema versioning.
- **Safety Testing**: Pre-built migration integration test suite verifies data preservation from Schema $V_n \rightarrow V_{n+1}$.
- **WAL Checkpoints**: Automatic `PRAGMA wal_checkpoint(TRUNCATE);` executed prior to schema alterations.

---

## 20. Database Security & Encryption Roadmap

- **Storage Level**: SQLCipher AES-256 transparent database file encryption.
- **Key Derivation**: Master passphrase derived via PBKDF2 (100,000 iterations + 16-byte salt).
- **Key Management**: Hardware keychain storage (`flutter_secure_storage`).

---

## 21. Data Validation & Integrity Rules

- `amount != 0.0`: Zero-value transactions rejected by database CHECK constraint.
- `created_at <= updated_at`: Timestamp chronological invariant.
- `date > 0`: Epoch timestamp sanity validation.

---

## 22. Error Recovery & Repair Protocol

- **Corruption Detection**: Diagnostic `PRAGMA quick_check;` executed on cold startup.
- **Auto-Recovery Routine**: If corruption detected, database executes `VACUUM INTO` recovery copy or restores from local automated daily JSON snapshot.

---

## 23. Future Database Expansion Readiness

- **Plugin Namespace**: Community plugins create isolated tables using namespace prefix `plugin_{plugin_id}_{table_name}` to prevent system table pollution.
- **Extensible JSON Metadata**: Core tables include `metadata_json` (TEXT NULL) field for non-breaking schema additions.

---

## 24. Textual Entity Relationship Diagram Description

1. **`AccountsTable` (1) to `TransactionsTable` (N)**: One account owns multiple transactions. Deletion restricted (`ON DELETE RESTRICT`).
2. **`CategoriesTable` (1) to `TransactionsTable` (N)**: One category classifies multiple transactions.
3. **`MerchantsTable` (1) to `TransactionsTable` (N)**: One merchant associated with multiple transactions.
4. **`TransactionsTable` (N) to `TagsTable` (M)**: Resolved via `TransactionTagsTable` junction table (`ON DELETE CASCADE`).
5. **`TransactionsTable` (1) to `AttachmentsTable` (N)**: One transaction links to multiple receipt attachments.
6. **`CategoriesTable` (1) to `CategoriesTable` (N)**: Recursive parent-child category self-reference.

---

## 25. Database Design Review & Architectural Trade-offs

- **Trade-off: UUID Strings vs. Auto-Increment Integers**: UUID strings take 36 bytes vs. 8 bytes for integers, but guarantee zero primary key collisions during multi-device offline sync.
- **Trade-off: Denormalized Account Balances**: Requires transactional trigger updates on write, but optimizes read queries for immediate 60 FPS dashboard rendering.
- **Conclusion**: Scheme provides optimal balance of performance, privacy, fault tolerance, and long-term open-source extensibility.
