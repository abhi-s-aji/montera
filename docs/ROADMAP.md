# Development Roadmap & Implementation Plan
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.
**Version:** 1.0.0-ROADMAP
**Status:** Approved Execution Plan
**Author:** Principal Software Architect & Technical Steering Committee

---

## 1. Development Philosophy

### 1.1 Incremental Development

Monetra is developed using an **incremental delivery model**. Every milestone produces a runnable, testable, and demonstrable build. No milestone is considered complete unless the application compiles cleanly, all existing tests pass, and the build is operable by a developer unfamiliar with the feature just added.

Development proceeds in concentric rings — foundation outward:

```
[Repository] → [Toolchain] → [Design System] → [Database] → [Core Features] → [Advanced Features] → [Polish] → [Release]
```

This guarantees that foundational layers (clean architecture skeleton, database schema, design tokens) are stable and peer-reviewed before any feature code is written on top of them. Refactoring a foundation after features are built on it is the primary source of technical debt in long-lived projects. Monetra avoids this by treating each layer as a quality gate that must pass independently.

### 1.2 Feature-Driven Milestones

Each milestone has a single, clearly stated objective. Milestones are not calendar-driven — they are **outcome-driven**. A milestone advances when its Definition of Done is satisfied, not when a deadline passes. This prevents the accumulation of partially implemented features carried forward into subsequent milestones.

Features are prioritized using a four-level hierarchy:
- **Critical**: Application cannot ship without it. Blocking.
- **High**: Core user value. Required for Beta.
- **Medium**: Quality-of-life improvement. Required for v1.0.
- **Low**: Enhancement. Post-v1.0 backlog candidate.

### 1.3 Definition of Done

A task is **Done** when all of the following are true:

1. All acceptance criteria defined in the SSFS for that screen/feature are satisfied.
2. Unit tests are written and pass with ≥85% statement coverage for the affected domain/data layers.
3. Widget tests cover the primary happy path and one error state for any new UI component.
4. `flutter analyze` reports zero warnings and zero errors.
5. `dart format .` has been applied and committed.
6. All public Dart symbols (classes, methods, enums) are annotated with `///` dartdoc comments.
7. A PR description explains the architectural rationale for any non-trivial design decision.
8. At least one maintainer has reviewed and approved the PR.
9. The relevant screen in the SSFS has been cross-referenced and any deviation is documented.

### 1.4 Code Review Expectations

Every merged change must pass through at least **one peer review** by a maintainer who did not write the change. For changes affecting `lib/core/`, `lib/l10n/`, or any document in `docs/`, **two maintainer approvals** are required.

Reviewers are responsible for verifying:
- Adherence to the Clean Architecture dependency rule (inner layers never import outer layers).
- Absence of hardcoded colors, magic numbers, or raw pixel values.
- Correct use of Riverpod providers (appropriate family, autoDispose, select scoping).
- Presence of tests covering the stated acceptance criteria.
- Absence of `print()` statements, commented-out blocks, and TODO items without a linked GitHub issue.

### 1.5 Quality Gates

A **Quality Gate** is a mandatory checkpoint between milestones. The project does not advance to the next milestone until all gate conditions are satisfied. Quality gates prevent milestone-skipping and the accumulation of deferred quality issues.

Gate conditions are formally recorded in the repository as a GitHub Milestone. Milestone closure requires that all associated issues are resolved and that CI is green on the `develop` branch at the point of closure.

---

## 2. Milestones

### Milestone 1 — Project Bootstrap
**Objective:** Establish the repository, toolchain, CI/CD pipeline, and folder architecture such that any contributor can clone, build, and run the empty application in under five minutes.

**Deliverables:**
- Flutter project initialized on `stable` channel.
- Complete folder structure as defined in `BOOTSTRAP_SPEC.md` created and committed.
- `pubspec.yaml` with all approved dependencies pinned.
- `analysis_options.yaml` with strict linter rules active.
- GitHub Actions CI workflow running `flutter analyze` and `flutter test` on every PR.
- Issue templates and PR template committed to `.github/`.
- `CODEOWNERS` file assigning core maintainers to `lib/core/` and `docs/`.
- `README.md` with project description, setup instructions, and contribution pointer.
- All platform runners (`android`, `ios`, `linux`, `macos`, `windows`, `web`) verified to compile.

---

### Milestone 2 — Core Infrastructure
**Objective:** Implement the foundational clean architecture skeleton — routing, dependency injection, error types, result types, logging, and security gateway — without any feature-specific logic.

**Deliverables:**
- `AppRouter` (go_router) with all named route stubs defined.
- `MonetraLogger` abstraction (debug-only, privacy-masked output).
- `Result<S, F>` sealed class hierarchy for domain-layer error handling.
- `AppFailure` base class and all concrete failure subtypes (`DatabaseFailure`, `ValidationFailure`, `SecurityFailure`, `BackupFailure`).
- `SecurityGateway` interface and stub implementation for PIN/biometric authentication.
- Riverpod `ProviderScope` configured at application root.
- `AppLifecycleObserver` wired to lock state changes.
- Global `FlutterError.onError` handler routing to `MonetraLogger`.

---

### Milestone 3 — Design System
**Objective:** Implement every visual token, component primitive, and layout scaffold defined in the DSUX so that feature teams never make ad-hoc styling decisions.

**Deliverables:**
- `MonetraTheme` class generating `ThemeData` for Light, Dark, and OLED modes.
- `MonetraColors` token map for all semantic color roles.
- `MonetraTypography` styles for all text roles (Display, Headline, Title, Body, Label, Mono).
- `MonetraSpacing` constants for all grid scale values (4, 8, 12, 16, 20, 24, 32, 48 px).
- `MonetraRadius` constants (sm: 8px, md: 12px, lg: 16px, xl: 24px; dynamic via settings).
- `MonetraDurations` constants for all animation timing (fast: 150ms, standard: 300ms, slow: 500ms).
- Primitive component library: `MonetraButton`, `MonetraCard`, `MonetraTextField`, `MonetraChip`, `MonetraBadge`, `MonetraStatCard`, `MonetraProgressBar`, `MonetraAvatar`, `MonetraToast`, `MonetraDialog`.
- `AppScaffold` layout wrapper with responsive NavigationRail (desktop) and BottomNavigationBar (mobile).
- Golden tests for all primitive components in both Light and Dark themes.
- Storybook-style `DesignSystemPreviewScreen` (debug-only) rendering all components.

---

### Milestone 4 — Database Layer
**Objective:** Implement the complete Drift database schema, all DAO classes, all repository interfaces and implementations, and seed data — with full test coverage — before any UI feature work begins.

**Deliverables:**
- All Drift table definitions: `AccountsTable`, `TransactionsTable`, `CategoriesTable`, `TagsTable`, `TransactionTagsTable`, `BudgetsTable`, `GoalsTable`, `AppSettingsTable`, `NotificationsTable`, `AttachmentsTable`.
- All DAO classes with typed query methods matching the SRS data access requirements.
- SQLite FTS5 virtual table for transaction full-text search.
- Migration framework with version tracking and rollback safety.
- All repository interfaces in the Domain layer.
- All repository implementations in the Data layer.
- Database initialization, WAL-mode configuration, and integrity check on startup.
- Seed data provider for default categories and currency list.
- DAO unit tests achieving 100% method coverage.
- Repository integration tests verifying each CRUD operation against an in-memory test database.

---

### Milestone 5 — Core Features
**Objective:** Implement the complete transaction lifecycle, account management, category management, and security vault — the features without which Monetra has zero usable value.

**Deliverables:**
- Splash Screen with DB integrity check.
- Onboarding Carousel (3 slides: Privacy, Currency, First Account).
- Biometric/PIN Authentication Gateway Screen.
- Workspace Dashboard with Net Worth StatCard, MTD cards, Net Worth sparkline, Budget velocity strip, and Recent Ledger list.
- Quick Add Transaction Modal (full validation, haptic feedback).
- Full Transaction Editor Screen (all fields, attachment picker).
- Transaction History Ledger (virtualized, grouped by date, swipe gestures).
- Transaction Details View (read-only inspector).
- Accounts Overview Screen (card grid).
- Account Details Screen (balance history + filtered ledger).
- Transfer Between Accounts Modal.
- Categories Taxonomy Screen (nested tree view).
- Category Editor Dialog (all fields, icon picker, color picker).
- Budgets Workspace (progress bars, velocity badges).
- Budget Details Screen (burn rate graph, transaction list).
- Empty States for all above screens.

---

### Milestone 6 — Analytics & Reports
**Objective:** Implement all analytics, reporting, search, calendar, and data export/import screens.

**Deliverables:**
- Global Search Screen (FTS5-backed, ≤30ms query target).
- Advanced Filters Screen (multi-criteria query builder).
- Calendar View Screen (monthly grid, daily heat dots).
- Analytics Dashboard (bar graph, pie chart, area chart).
- Cash Flow Analysis Screen (dual line chart).
- Income vs. Expense Screen (side-by-side bar chart).
- Category Breakdown Screen (donut chart with drill-down).
- Savings Goals Screen (circular progress rings).
- Goal Details Screen (linked accounts, contribution logger).
- Reports Generator Screen (PDF and CSV generation).
- Export Wizard Screen (JSON/CSV, encrypted backup toggle).
- Import Wizard Screen (schema validation, merge/overwrite reconciliation).
- Backup & Restore Center Screen.

---

### Milestone 7 — Settings & Customization
**Objective:** Implement the complete settings hub, all customization options, and the plugin manager foundation.

**Deliverables:**
- Settings Overview Screen (navigation list).
- Appearance Settings Screen (theme mode radio cards, live preview).
- Customization Center Screen (radius slider, density radio, font dropdown).
- Theme Editor Screen (palette swatches, custom hex input).
- Dashboard Layout Editor (drag-and-drop widget reordering).
- Chart Customization Screen (curve toggle, gradient slider, height selector).
- Currency Settings Screen (base currency, manual exchange rate table).
- Security & Vault Screen (encryption toggle, PIN trigger, biometrics toggle, auto-lock duration).
- PIN Setup Screen (4-digit or 6-digit, confirmation step).
- About Monetra Screen (version, values, GitHub link).
- Open Source Licenses Screen (`LicensePage` integration).
- Plugin Manager Screen (enable/disable toggle, permissions inspector, sandboxed manifest loader).
- Notification Center Screen (alert log list, clear all).
- Help & Documentation Screen (offline searchable manual).

---

### Milestone 8 — Testing & Optimization
**Objective:** Achieve all performance benchmarks, complete the test pyramid, validate accessibility, and eliminate all known technical debt items before beta.

**Deliverables:**
- Full unit test suite: ≥85% statement coverage across Domain and Data layers.
- Widget test suite: all primary screens tested for happy path and one error state.
- Integration test suite: all critical user journeys automated (add transaction, budget exceeded alert, export/import cycle, PIN lock/unlock).
- Golden test suite: all primitive components across Light, Dark, and OLED themes.
- Performance profiling report: cold boot ≤1.2s, frame budget ≤8.3ms, query latency ≤30ms.
- Accessibility audit: all interactive elements have semantic labels; minimum contrast ratios met.
- Technical debt register cleared of all Critical and High items.
- Zero analyzer warnings on `develop` branch.

---

### Milestone 9 — Beta Release
**Objective:** Distribute a functionally complete, stable build to a closed beta group and integrate structured feedback.

**Deliverables:**
- Signed Android APK + AAB via GitHub Actions.
- Signed iOS IPA (TestFlight).
- Linux AppImage build.
- macOS `.dmg` build.
- Windows `.exe` NSIS installer.
- In-app feedback mechanism (plain text, no analytics).
- Beta Changelog documented in `CHANGELOG.md`.
- All open Critical and High severity issues resolved before distribution.
- Beta issue triage process established.

---

### Milestone 10 — Stable v1.0
**Objective:** Address all beta feedback, achieve store submission readiness, and publish the stable open-source release.

**Deliverables:**
- All beta-reported Critical/High bugs resolved.
- Play Store listing assets (screenshots, feature graphic, description).
- App Store listing assets.
- GitHub Release with signed binaries and SHA-256 checksums.
- v1.0 `CHANGELOG.md` entry.
- Full `README.md` update with feature list, screenshots, and architecture diagram.
- `CONTRIBUTING.md` finalized.
- `SECURITY.md` finalized with responsible disclosure policy.
- All open-source license attributions verified.
- API documentation generated via `dart doc` and hosted on GitHub Pages.

---

## 3. Feature Breakdown

### F-01: Splash Screen & Application Bootstrapper
- **Description**: Display Monetra logo and tagline during cold start. Run SQLite `quick_check`, initialize WAL mode, load encryption keys from secure storage, and route to Authentication or Onboarding.
- **Dependencies**: Milestone 2 (SecurityGateway), Milestone 4 (Database Layer).
- **Complexity**: Medium
- **Priority**: Critical
- **Expected Outputs**: Working cold-start flow with DB integrity gating.
- **Testing**: Unit test for routing logic. Integration test for boot → authentication → dashboard flow.

### F-02: Onboarding Carousel
- **Description**: Three-slide guided setup: Privacy Guarantee slide, Currency Selection slide (base currency dropdown), First Account Creation slide (name, type, initial balance).
- **Dependencies**: F-01, Milestone 4 (AccountsTable DAO).
- **Complexity**: Medium
- **Priority**: Critical
- **Expected Outputs**: First-run experience creating seed account and setting base currency in `AppSettingsTable`.
- **Testing**: Widget test for slide navigation. Unit test for onboarding state provider.

### F-03: Security Authentication Gateway
- **Description**: Lock screen displayed on cold start (if PIN/biometric enabled) and on app resume after auto-lock timeout. Supports Fingerprint, FaceID, and PIN fallback.
- **Dependencies**: Milestone 2 (SecurityGateway), F-01.
- **Complexity**: Large
- **Priority**: Critical
- **Expected Outputs**: Gated entry to all application screens. Auto-lock after configurable timeout.
- **Testing**: Unit tests for lock/unlock state machine. Integration test for lock → biometric → unlock flow.

### F-04: Quick Add Transaction Modal
- **Description**: Compact modal accessible via FAB or `Ctrl+N`. Toggle for Expense/Income/Transfer. Amount, Description, Account, Category, Tags, Date. Full validation.
- **Dependencies**: F-06 (Transaction domain entities), Milestone 4 (TransactionRepository).
- **Complexity**: Medium
- **Priority**: Critical
- **Expected Outputs**: Transaction persisted in ≤5 taps. Account balance updated reactively.
- **Testing**: Unit test for validation rules. Widget test for modal open/close, error state.

### F-05: Full Transaction Editor Screen
- **Description**: Expanded transaction form with all metadata fields including recurring schedule, notes (rich text), file attachments, geo-tagging toggle, and transfer pairing.
- **Dependencies**: F-04, Milestone 4 (AttachmentsTable DAO).
- **Complexity**: Large
- **Priority**: High
- **Expected Outputs**: Full transaction record with all optional metadata persisted.
- **Testing**: Widget test for all field validations. Integration test for attachment upload and retrieval.

### F-06: Transaction History Ledger
- **Description**: Virtualized infinite scroll list grouped by date. Header with search, category filter, and tag chips. Swipe-to-delete with undo toast. Pull-to-refresh.
- **Dependencies**: Milestone 4 (TransactionsTable reactive stream).
- **Complexity**: Large
- **Priority**: Critical
- **Expected Outputs**: Smooth 60fps scroll over 100,000 records. Sub-100ms filter response.
- **Testing**: Widget test for grouping correctness. Performance test for 100k record scroll.

### F-07: Global Search (FTS5)
- **Description**: Full-text search across description, notes, merchant, and tags using SQLite FTS5. Recent search chips. Highlighted match snippets.
- **Dependencies**: Milestone 4 (FTS5 virtual table), F-06.
- **Complexity**: Large
- **Priority**: High
- **Expected Outputs**: ≤30ms query latency on 100,000-record dataset.
- **Testing**: DAO unit test with synthetic 100k dataset. Widget test for result rendering.

### F-08: Accounts Overview & Account Details
- **Description**: Card grid of all accounts with type icon, color, currency, and live balance. Account Details shows balance trend line and account-filtered ledger.
- **Dependencies**: Milestone 4 (AccountsTable reactive streams).
- **Complexity**: Medium
- **Priority**: Critical
- **Expected Outputs**: Real-time balance reflection after each transaction.
- **Testing**: Unit test for net worth calculation. Widget test for card rendering.

### F-09: Category Taxonomy & Category Editor
- **Description**: Hierarchical category tree (parent/child). Color and icon assignment. Income/Expense/Transfer type segregation. Drag-and-drop reordering.
- **Dependencies**: Milestone 4 (CategoriesTable DAO).
- **Complexity**: Medium
- **Priority**: High
- **Expected Outputs**: Persistent category hierarchy with color/icon metadata.
- **Testing**: Unit test for parent-child integrity constraints. Widget test for tree expansion.

### F-10: Budgets Workspace & Budget Details
- **Description**: Monthly/yearly budget caps per category. Progress bars with velocity badges (on-track / warning / exceeded). Budget Details: daily burn rate graph and category transaction list.
- **Dependencies**: F-09, Milestone 4 (BudgetsTable DAO).
- **Complexity**: Large
- **Priority**: High
- **Expected Outputs**: Real-time budget utilization. Notification trigger on 100% exceeded.
- **Testing**: Unit test for velocity calculation. Widget test for progress bar states.

### F-11: Savings Goals
- **Description**: Target savings milestones linked to accounts. Circular progress rings. Target date projection. Manual contribution entry.
- **Dependencies**: F-08, Milestone 4 (GoalsTable DAO).
- **Complexity**: Medium
- **Priority**: High
- **Expected Outputs**: Goal completion notification on 100% target reached.
- **Testing**: Unit test for projection math. Widget test for completion animation.

### F-12: Analytics Dashboard & All Chart Screens
- **Description**: Net worth area chart, Income vs. Expense bar chart, Category donut chart, Cash Flow dual-line chart, all with period selectors (MTD, YTD, custom range).
- **Dependencies**: Milestone 4 (aggregate DAO queries).
- **Complexity**: Large
- **Priority**: High
- **Expected Outputs**: All charts render in ≤200ms on datasets up to 5 years of daily transactions.
- **Testing**: Unit test for aggregate calculation correctness. Widget test for empty state rendering.

### F-13: Export & Import Wizards
- **Description**: Export to JSON/CSV with optional AES-256 password encryption. Import from Monetra JSON backup or generic CSV with field mapping UI. Schema validation step. Merge vs. Overwrite mode.
- **Dependencies**: Milestone 4 (all DAOs), Milestone 2 (SecurityGateway for encryption).
- **Complexity**: Large
- **Priority**: High
- **Expected Outputs**: Lossless round-trip: Export → re-import produces identical records.
- **Testing**: Integration test for export → wipe → import cycle. Unit test for schema validator.

### F-14: Reports Generator (PDF & CSV)
- **Description**: Configurable financial report generation (Date range, Account filter, Category filter). Output to PDF (formatted) and CSV (raw data).
- **Dependencies**: F-12, F-13.
- **Complexity**: Medium
- **Priority**: Medium
- **Expected Outputs**: Report file written to platform downloads folder.
- **Testing**: Integration test verifying PDF is non-empty and CSV row count matches source records.

### F-15: Settings, Appearance & Customization
- **Description**: Theme mode (Light/Dark/OLED), accent color picker, corner radius slider, font selector, UI density radio, dashboard widget reorder, chart style options.
- **Dependencies**: Milestone 3 (MonetraTheme), Milestone 4 (AppSettingsTable DAO).
- **Complexity**: Medium
- **Priority**: High
- **Expected Outputs**: All settings persisted and applied without app restart.
- **Testing**: Widget test verifying theme token swap on mode change.

### F-16: Security Vault & PIN/Biometric Configuration
- **Description**: Toggle database encryption, configure PIN (4/6 digit), enable biometrics, set auto-lock timeout. PIN Setup screen with confirmation step.
- **Dependencies**: Milestone 2 (SecurityGateway), F-03.
- **Complexity**: Large
- **Priority**: Critical
- **Expected Outputs**: Master key stored in hardware keychain. Database re-keyed on encryption toggle.
- **Testing**: Integration test for enable encryption → verify DB inaccessible without key. Unit test for PIN state machine.

### F-17: Plugin Manager
- **Description**: Sandboxed plugin host with JSON manifest declaration. Enable/disable per-plugin. Permissions inspector showing declared capabilities. Community import parsers and report generators.
- **Dependencies**: Milestone 7 (Settings complete).
- **Complexity**: Large
- **Priority**: Low (v1.1 backlog candidate if scope-constrained)
- **Expected Outputs**: Plugin registry with sandboxed execution preventing raw DB access.
- **Testing**: Unit test for manifest parser. Integration test for plugin enable/disable lifecycle.

### F-18: Localization (English Baseline + RTL Readiness)
- **Description**: Extract all user-facing strings to `app_en.arb`. Configure `flutter_localizations`. Implement RTL layout mirror for all screens. Prepare ARB structure for community translation contributions.
- **Dependencies**: Milestone 3 (all UI components), Milestone 5.
- **Complexity**: Medium
- **Priority**: High
- **Expected Outputs**: Zero hardcoded user-visible strings. Layout mirrors correctly in RTL pseudolocale.
- **Testing**: Widget test with RTL locale override verifying no layout overflow.

---

## 4. Task Dependencies

### 4.1 Blocking Dependency Chain

```
Milestone 1 (Bootstrap)
    └── Milestone 2 (Core Infrastructure)
            ├── Milestone 3 (Design System) ─────────────────────────────┐
            └── Milestone 4 (Database Layer) ────────────────────────────┤
                        └── Milestone 5 (Core Features) ◄────────────────┘
                                    └── Milestone 6 (Analytics & Reports)
                                                └── Milestone 7 (Settings)
                                                            └── Milestone 8 (Testing & Optimization)
                                                                        └── Milestone 9 (Beta)
                                                                                    └── Milestone 10 (Stable v1.0)
```

### 4.2 Hard Blockers

| Blocked Task | Blocked By | Reason |
| :--- | :--- | :--- |
| Any feature screen | Milestone 3 (Design System) | No hardcoded styles allowed |
| Any feature screen | Milestone 4 (Database Layer) | Repository interfaces must exist before use |
| F-04 (Quick Add) | F-06 (Ledger reactive stream) | FAB updates ledger in real time |
| F-07 (FTS5 Search) | Milestone 4 FTS5 table | Query cannot exist without virtual table |
| F-10 (Budgets) | F-09 (Categories) | Budget is assigned per category |
| F-13 (Export/Import) | All Milestone 4 DAOs | Export must address all tables |
| F-16 (Security Vault) | Milestone 2 SecurityGateway | Encryption depends on gateway abstraction |

### 4.3 Opportunities for Parallel Work

The following workstreams can proceed in parallel after Milestones 1–2 are complete:

| Parallel Track A | Parallel Track B |
| :--- | :--- |
| Milestone 3 (Design System tokens, primitives) | Milestone 4 (Drift schema, DAO, repositories) |
| F-08 (Accounts) + F-09 (Categories) | F-12 (Analytics query layer) |
| F-13 (Export/Import logic) | F-14 (Report generation) |
| F-15 (Settings UI) | F-18 (Localization ARB extraction) |

---

## 5. Sprint Planning

### Sprint 1 — Repository Foundation
**Goal**: Any developer can clone, build, and run a blank but fully configured Monetra application.
**Tasks**: Initialize Flutter project, commit folder structure, add all approved dependencies, configure `analysis_options.yaml`, set up GitHub Actions CI, write README and contribution guide, verify all six platform runners compile.
**Deliverables**: Green CI build on all platforms.
**Risks**: Platform-specific toolchain setup failures (especially macOS/iOS on Linux CI runners).
**Exit Criteria**: `flutter analyze` passes. `flutter build apk` passes. CI workflow runs successfully.

---

### Sprint 2 — Clean Architecture Skeleton
**Goal**: The routing, error typing, logging, and security gateway layers exist and are tested in isolation.
**Tasks**: Implement `AppRouter` with all route stubs, `Result<S,F>` sealed types, `AppFailure` hierarchy, `MonetraLogger`, `AppLifecycleObserver`, global error handler.
**Deliverables**: Navigable skeleton app with all routes accessible and logging operational.
**Risks**: go_router v7+ API breaking changes vs. earlier community documentation.
**Exit Criteria**: All routes navigate without crash. Logger outputs masked values only. Unit tests pass for error types.

---

### Sprint 3 — Design System Tokens & Primitive Components
**Goal**: Design system is complete and visually verified via the preview screen.
**Tasks**: `MonetraTheme`, `MonetraColors`, `MonetraTypography`, `MonetraSpacing`, all primitive widgets, `AppScaffold`, golden tests.
**Deliverables**: `DesignSystemPreviewScreen` renders all primitives in Light/Dark/OLED modes.
**Risks**: Golden test file differences across rendering platforms (Linux vs. macOS pixel subpixel rendering).
**Exit Criteria**: All golden tests pass on CI. Zero hardcoded styles found in code review.

---

### Sprint 4 — Database Schema & DAO Layer
**Goal**: All Drift tables, DAOs, repositories, and FTS5 search index exist with full test coverage.
**Tasks**: All table definitions, all DAOs, migration framework, FTS5 virtual table, seed data provider, all repository interfaces and implementations.
**Deliverables**: Functional database with CRUD verified in isolation. Test suite achieves 100% DAO method coverage.
**Risks**: Drift code generation cache invalidation causing build failures. SQLite WAL mode configuration differences between platforms.
**Exit Criteria**: All DAO unit tests pass. All repository integration tests pass against in-memory database. Migration from v1→v2 schema test passes.

---

### Sprint 5 — Authentication & Core Navigation
**Goal**: The application is secured and core navigation is operational end-to-end.
**Tasks**: Splash Screen, Biometric/PIN Authentication Screen, Onboarding Carousel, `AppScaffold` navigation wired to all placeholder destinations.
**Deliverables**: Full boot → authenticate → navigate flow demonstrable on physical device.
**Risks**: `local_auth` platform differences (Android Keystore vs. iOS Secure Enclave API).
**Exit Criteria**: Lock/unlock integration test passes on Android and iOS. Onboarding creates account in DB correctly.

---

### Sprint 6 — Transaction Lifecycle
**Goal**: A user can add, view, edit, delete, and filter transactions end-to-end.
**Tasks**: Quick Add Modal, Full Transaction Editor, Transaction History Ledger (virtualized), Transaction Details View, swipe gestures with undo.
**Deliverables**: Full transaction CRUD cycle with reactive account balance updates.
**Risks**: Virtualized list performance regression on low-end Android devices.
**Exit Criteria**: Ledger scrolls at 60fps with 10,000 records on a mid-range test device. All transaction CRUD integration tests pass.

---

### Sprint 7 — Account & Category Management
**Goal**: Users can manage all accounts and the complete category taxonomy.
**Tasks**: Accounts Overview, Account Details, Transfer Modal, Categories Taxonomy, Category Editor.
**Deliverables**: Multi-account workspace with category tree fully functional.
**Risks**: Circular parent-child category assignment must be prevented at the repository layer.
**Exit Criteria**: Parent-child integrity constraint test passes. Transfer creates debit + credit pair correctly verified by integration test.

---

### Sprint 8 — Budgets & Savings Goals
**Goal**: Users can set spending budgets per category and track savings goals.
**Tasks**: Budgets Workspace, Budget Details, Savings Goals Screen, Goal Details Screen, budget exceeded notification trigger.
**Deliverables**: Real-time budget utilization with notification on 100% exceeded.
**Risks**: Budget velocity calculation performance on MTD aggregate queries across large datasets.
**Exit Criteria**: Budget notification fires correctly in integration test. Velocity calculation unit test matches expected burn rate.

---

### Sprint 9 — Search, Filters & Calendar View
**Goal**: Users can find any transaction quickly using search, filters, or calendar drill-down.
**Tasks**: Global Search (FTS5), Advanced Filters Screen, Calendar View Screen.
**Deliverables**: Sub-30ms full-text search on 100,000-record test dataset.
**Risks**: FTS5 tokenizer configuration producing unexpected results for non-ASCII characters.
**Exit Criteria**: Search query latency benchmarks pass. Filter combination integration test verifies all criteria types.

---

### Sprint 10 — Analytics & Charting
**Goal**: All analytics screens render correct data from the local database.
**Tasks**: Analytics Dashboard, Cash Flow Screen, Income vs. Expense Screen, Category Breakdown Screen, period selectors.
**Deliverables**: All five chart types rendering live data with period controls.
**Risks**: Chart library performance with large date range datasets causing frame drops.
**Exit Criteria**: All chart screens render in ≤200ms measured by Flutter DevTools timeline. Chart data unit tests verify aggregate correctness.

---

### Sprint 11 — Export, Import & Backup
**Goal**: Users can export a complete encrypted backup and restore it faithfully.
**Tasks**: Export Wizard, Import Wizard, Backup & Restore Center, PDF/CSV Reports Generator.
**Deliverables**: Lossless export → re-import round-trip verified by integration test.
**Risks**: JSON schema versioning for future backward compatibility. Platform file picker permission differences.
**Exit Criteria**: Round-trip integration test produces zero data delta. Import schema validation rejects malformed files correctly.

---

### Sprint 12 — Settings & Customization
**Goal**: All user preferences are persisted, applied live, and respected across restarts.
**Tasks**: All Settings screens, Appearance, Customization, Theme Editor, Dashboard Layout Editor, Chart Customization, Currency Settings, Security Vault, PIN Setup, About, Licenses, Plugin Manager scaffold.
**Deliverables**: All settings persisted to `AppSettingsTable` and applied without restart.
**Risks**: Accent color dynamic theme generation causing contrast ratio violations at edge hues.
**Exit Criteria**: Widget test verifies theme token swap on mode change. Contrast ratio audit passes for all six accent presets.

---

### Sprint 13 — Localization & Accessibility
**Goal**: All strings are externalized to ARB, and all screens are accessible.
**Tasks**: Extract all hardcoded strings, configure `flutter_localizations`, RTL layout verification, semantic label audit, minimum contrast ratio audit.
**Deliverables**: Zero hardcoded strings. RTL pseudolocale shows no layout overflow. Screen reader labels present on all interactive widgets.
**Risks**: ARB extraction missing rare edge-case strings in dynamic content builders.
**Exit Criteria**: RTL widget test passes across all primary screens. Accessibility audit produces zero critical findings.

---

### Sprint 14 — Test Completion & Performance Optimization
**Goal**: Achieve all coverage targets, performance benchmarks, and eliminate all remaining technical debt items.
**Tasks**: Remaining unit tests, remaining widget tests, all integration tests, all golden tests, cold boot profiling, memory profiling, DB query benchmarking, technical debt register triage.
**Deliverables**: Full test pyramid complete. All performance targets verified. Zero Critical/High debt items open.
**Risks**: Performance bottlenecks on lower-spec Android devices that were not caught in earlier sprints.
**Exit Criteria**: Coverage report ≥85%. Cold boot ≤1.2s on a mid-range device. Frame budget ≤8.3ms measured in profile mode. Query latency ≤30ms on 100k-record test fixture.

---

### Sprint 15 — Beta Distribution
**Goal**: Distribute a signed, functionally complete build to the closed beta group.
**Tasks**: Build signing configuration for all platforms, GitHub Actions release workflow, beta changelog, in-app feedback mechanism, TestFlight / Play Store internal track upload.
**Deliverables**: Signed multi-platform builds distributed to beta testers.
**Risks**: Play Store review delays. iOS provisioning profile issues on CI.
**Exit Criteria**: Beta builds successfully installed and launched by at least five independent testers on distinct devices.

---

### Sprint 16 — v1.0 Hardening & Release
**Goal**: Address all critical beta feedback and publish the stable v1.0 release.
**Tasks**: Beta bug fixes, final accessibility verification, store listing asset creation, `dart doc` generation, GitHub Release publishing, open-source readiness audit.
**Deliverables**: v1.0 binaries published. Store listings live. Documentation hosted.
**Exit Criteria**: Final Readiness Checklist (Section 13) fully satisfied.

---

## 6. Risk Assessment

### R-01: Database Schema Migration Failures
**Probability**: Medium. **Impact**: Critical.
**Description**: An incorrect Drift migration can corrupt or wipe user data on upgrade.
**Mitigation**:
1. Every schema change requires a corresponding migration test that verifies data preservation.
2. Automatic daily JSON backups are written before any migration runs.
3. A database version integrity check runs before every migration sequence.
4. Migrations are tested against the real device SQLite binary, not just the in-memory test database.

### R-02: FTS5 Full-Text Search Performance Regression
**Probability**: Low. **Impact**: High.
**Description**: FTS5 index fragmentation on large datasets could cause query latency to exceed 30ms SLA.
**Mitigation**:
1. FTS5 `OPTIMIZE` command scheduled during idle periods via `WorkManager`.
2. Performance regression test runs against a 100,000-record fixture in CI.
3. Index rebuild available as a developer diagnostic option in the Help screen.

### R-03: Riverpod State Management Complexity
**Probability**: Medium. **Impact**: Medium.
**Description**: Incorrect provider scoping or missing `autoDispose` annotations can cause memory leaks or stale state bugs.
**Mitigation**:
1. Architecture review checklist mandates review of all new providers for disposal scope.
2. `riverpod_lint` added to `analysis_options.yaml` to catch common provider misuse patterns.
3. Integration tests verify that memory footprint does not grow after repeated navigation.

### R-04: Cross-Platform Rendering Inconsistencies
**Probability**: Medium. **Impact**: Medium.
**Description**: Flutter rendering differences between Android, iOS, and desktop platforms (especially font rendering, blur effects, and keyboard insets) can cause visual regressions.
**Mitigation**:
1. Golden tests maintained per-platform in CI matrix (ubuntu, macos, windows).
2. Manual device testing on Android, iOS, and Linux before each milestone close.
3. Platform-specific conditional rendering kept in isolated `platform_helpers.dart` files.

### R-05: Backup Encryption Key Loss
**Probability**: Low. **Impact**: Critical.
**Description**: If the hardware keychain entry is deleted (e.g., app uninstall on Android), the encrypted database becomes permanently inaccessible.
**Mitigation**:
1. Onboarding explicitly warns users to export a plaintext backup before enabling encryption.
2. Plaintext daily JSON backup is written to a separate, unencrypted backup directory accessible via file manager.
3. Recovery Mode screen (Screen #47) offers restore from daily backup if key is unavailable.

### R-06: Large Dataset UI Performance
**Probability**: Medium. **Impact**: High.
**Description**: The Transaction History Ledger rendering 10,000+ rows could cause frame drops on low-end Android devices.
**Mitigation**:
1. `ListView.builder` with `itemExtent` for constant-height rows to eliminate layout recalculation.
2. Lazy-loaded pagination: load 100 records per page with reactive stream appending.
3. Heavy aggregate computations (net worth, MTD totals) run in Dart `Isolate` via `compute()`.

### R-07: Third-Party Package API Breaking Changes
**Probability**: Low. **Impact**: High.
**Description**: A major version bump of `drift`, `go_router`, or `flutter_riverpod` could require substantial refactoring.
**Mitigation**:
1. All dependency versions are pinned with `^` bounded ranges in `pubspec.yaml`.
2. Quarterly dependency upgrade review process with CI compatibility testing.
3. Each major dependency has an abstraction interface in the Data layer to limit blast radius of changes.

### R-08: Plugin Sandbox Security Violations
**Probability**: Low (v1.0 Plugin Manager is limited scope). **Impact**: High.
**Description**: A malicious community plugin could attempt raw database access or network exfiltration.
**Mitigation**:
1. v1.0 Plugin Manager only loads plugins from a curated in-repository manifest.
2. Plugins execute in a sandboxed Dart scope with no access to `drift` or `flutter_secure_storage`.
3. Community plugin submission requires maintainer review before manifest inclusion.

---

## 7. Quality Gates

### Gate 1 — After Milestone 1 (Bootstrap)
- [ ] All six platform runners compile without error on a clean checkout.
- [ ] GitHub Actions CI workflow runs and passes on `develop`.
- [ ] `README.md` contains accurate setup instructions verified by a second developer.
- [ ] All `.github/` templates and `CODEOWNERS` are committed.

### Gate 2 — After Milestone 2 (Core Infrastructure)
- [ ] `flutter analyze` reports 0 warnings.
- [ ] All infrastructure unit tests pass.
- [ ] `AppRouter` routes all SSFS-defined screens to non-crashing stubs.
- [ ] `MonetraLogger` outputs masked values in debug mode; zero output in release mode.

### Gate 3 — After Milestone 3 (Design System)
- [ ] All golden tests pass on CI.
- [ ] `DesignSystemPreviewScreen` renders all primitives in all three theme modes.
- [ ] Code review confirms zero hardcoded colors or pixel values in any committed file.
- [ ] All primitive component dartdoc comments are present and accurate.

### Gate 4 — After Milestone 4 (Database Layer)
- [ ] All DAO unit tests achieve 100% method coverage.
- [ ] All repository integration tests pass against in-memory test database.
- [ ] Migration test verifies data preservation from schema v1 → v2.
- [ ] FTS5 index query test returns results in ≤30ms on a 10,000-record fixture.

### Gate 5 — After Milestone 5 (Core Features)
- [ ] Complete transaction CRUD integration test passes.
- [ ] Authentication lock/unlock integration test passes on Android and iOS.
- [ ] Ledger scrolls at 60fps with 10,000 records on a target mid-range device.
- [ ] All Core Feature screens satisfy their SSFS acceptance criteria (documented in PR descriptions).

### Gate 6 — After Milestone 6 (Analytics & Reports)
- [ ] All chart screens render correct aggregate data verified by unit test.
- [ ] Export → re-import round-trip produces zero data delta (integration test).
- [ ] FTS5 search returns results in ≤30ms on a 100,000-record test fixture.

### Gate 7 — After Milestone 7 (Settings & Customization)
- [ ] All settings are persisted and applied without restart.
- [ ] Theme token swap widget test passes for all three modes.
- [ ] Contrast ratio audit passes for all six accent color presets.

### Gate 8 — After Milestone 8 (Testing & Optimization)
- [ ] Statement coverage report ≥85% across Domain and Data layers.
- [ ] Cold boot time ≤1.2s measured on a mid-range target device in profile mode.
- [ ] Frame render budget ≤8.3ms measured by Flutter DevTools (no jank frames in core flows).
- [ ] Memory consumption ≤150MB during 30-minute active session.
- [ ] Technical debt register: zero Critical or High severity open items.
- [ ] Accessibility audit: zero critical findings.
- [ ] Zero `flutter analyze` warnings on `develop`.

### Gate 9 — After Milestone 9 (Beta)
- [ ] Signed builds successfully installed on five distinct real devices.
- [ ] All Critical beta-reported bugs resolved before advancing.
- [ ] In-app feedback mechanism operational and responses received.
- [ ] Beta changelog published in `CHANGELOG.md`.

### Gate 10 — Before Milestone 10 (v1.0)
- [ ] Final Readiness Checklist (Section 13) fully checked.
- [ ] Store listings (Play Store, App Store) reviewed and ready for submission.
- [ ] `dart doc` generated and hosted on GitHub Pages.
- [ ] All open-source license attributions verified by license audit script.

---

## 8. Release Plan

### Stage 0 — Internal Development Builds
**Entry**: Milestone 1 complete.
**Purpose**: Developer-only builds. Sideloaded on team devices for daily dogfooding.
**Criteria to Exit**: Milestone 5 Gate passed.

### Stage 1 — Alpha (Invite-Only)
**Entry**: Milestone 5 Gate passed.
**Distribution**: Up to 20 trusted testers. Play Store Internal Testing track and TestFlight.
**Focus**: Core feature stability. Database integrity. Authentication reliability.
**Exit Criteria**: Zero transaction data loss bugs. Authentication works reliably on all invited device models.

### Stage 2 — Closed Beta
**Entry**: Milestone 8 Gate passed. All performance benchmarks met.
**Distribution**: Up to 200 testers via Play Store Closed Testing and TestFlight external group.
**Focus**: Full feature coverage. Edge cases. Export/import reliability. Platform-specific bugs.
**Exit Criteria**: Zero Critical severity issues open. All High severity issues resolved or scheduled. Performance targets maintained on tester-reported device models.

### Stage 3 — Open Beta
**Entry**: All Closed Beta exit criteria met.
**Distribution**: Public GitHub release tagged `v1.0.0-beta`. Play Store Open Testing. TestFlight public link.
**Focus**: Community feedback. Accessibility. Localization gaps. First-run experience.
**Exit Criteria**: Final Readiness Checklist ≥95% complete. No new Critical issues reported in 14-day window.

### Stage 4 — Release Candidate
**Entry**: Open Beta exit criteria met.
**Distribution**: GitHub Release `v1.0.0-rc.1` with signed binaries and SHA-256 checksums.
**Focus**: Final regression testing. Store submission preparation.
**Exit Criteria**: Final Readiness Checklist 100% complete. Store listings approved.

### Stage 5 — Stable v1.0
**Entry**: Release Candidate accepted with zero Critical regressions.
**Distribution**: Play Store Production, App Store, GitHub Release `v1.0.0`, direct binary downloads for Linux, macOS, Windows.
**Post-Launch**: Monitor crash-free rate. Triage reported issues into v1.0.1 patch and v1.1 feature milestones.

---

## 9. Open Source Contribution Roadmap

### Phase 1 — Foundation (Milestones 1–4, Pre-Feature)
- Repository is **contribution-read-only** during this phase. Core architecture must be established by the founding team before community PRs are accepted. This prevents architectural fragmentation from community contributions before the foundations are stable.
- **Community actions available**: Star/watch repository, read all specification documents, comment on GitHub Discussions.

### Phase 2 — Core Feature Completion (Milestones 5–7)
- Repository opens to **beginner-friendly contributions**. Issues labelled `good first issue` are published.
- **Beginner-Friendly Tasks (good first issue)**:
  - Add missing dartdoc comments to public symbols.
  - Implement a new default category with icon and color.
  - Translate `app_en.arb` to a new language.
  - Fix a formatting or linting issue reported by CI.
  - Add a missing empty state widget to a secondary screen.
  - Improve README documentation with a screenshot or diagram.
- **Documentation required**: All `good first issue` tasks must have a complete description, acceptance criteria, and a link to the relevant SSFS section so contributors can work independently.

### Phase 3 — Beta & Polish (Milestones 8–9)
- Repository opens to **intermediate contributions**.
- **Intermediate Tasks**:
  - Add widget tests for untested screens.
  - Implement an alternative chart visualization type.
  - Add keyboard shortcut support for a new action.
  - Build a new import parser plugin for a popular bank CSV format.
  - Add accessibility semantic labels to a feature screen.
  - Implement a new accent color theme preset.
- Maintainers provide a **one-week review SLA** for all non-draft PRs.

### Phase 4 — Post-v1.0 Community Growth
- **Advanced Architectural Tasks** (require Architecture Proposal issue template before implementation):
  - Plugin sandbox isolation improvements.
  - Cloud sync adapter abstraction (without adding a concrete cloud dependency).
  - Additional platform support (e.g., Wear OS companion).
  - Database encryption algorithm upgrade.
  - New reporting output format.
- **Mentorship Expectation**: Core maintainers will pair-review all Architecture Proposal issues within two weeks of submission and provide a formal Accept/Request Changes/Decline response with rationale.

---

## 10. Technical Debt Management

### 10.1 Debt Tracking
- All identified technical debt is recorded as GitHub Issues labelled `tech-debt`.
- Each debt item includes: the debt description, the ideal future state, the estimated effort, and the severity level (Critical / High / Medium / Low).
- The debt register is reviewed at the **start of every milestone** by the Technical Steering Committee.

### 10.2 Severity Definitions
| Severity | Definition | Action |
| :--- | :--- | :--- |
| **Critical** | Causes data loss, security vulnerability, or architectural violation | Must resolve before next milestone |
| **High** | Causes performance regression or significant maintainability impact | Must resolve before Beta |
| **Medium** | Increases implementation complexity for future features | Resolve within two milestones |
| **Low** | Cosmetic or minor code organization improvement | Address in quarterly refactoring sprint |

### 10.3 Refactoring Checkpoints
- A **Refactoring Sprint** is scheduled after Milestone 5 (Core Features complete) and after Milestone 7 (Settings complete). These sprints are dedicated solely to resolving Medium and Low debt items and improving code quality before the next major feature phase begins.
- No new feature work is merged during a Refactoring Sprint.

### 10.4 Architectural Change Policy
- Architectural changes (changes to the Clean Architecture layer boundaries, the Riverpod provider hierarchy, or the database schema) require:
  1. An Architecture Proposal issue documenting the problem, proposed change, impact, and migration path.
  2. Review and approval by the Technical Steering Committee before any implementation begins.
  3. A corresponding update to the relevant specification document (`SATD.md` or `DDD.md`).
- Architectural changes are never approved during a Beta or Release Candidate phase.

---

## 11. Performance Validation Plan

### 11.1 When Performance Testing Occurs
| Phase | Test Type |
| :--- | :--- |
| Sprint 6 (Transaction Ledger) | Virtualized scroll frame rate on 10,000 records |
| Sprint 9 (FTS5 Search) | Query latency on 100,000-record fixture |
| Sprint 10 (Analytics Charts) | Chart render time on 5-year daily dataset |
| Milestone 8 (Testing & Optimization) | Full benchmark suite: boot time, memory, frame budget, queries |
| Before each Beta distribution | Regression test on benchmark suite |

### 11.2 Benchmark Targets
| Metric | Target | Measurement Method |
| :--- | :--- | :--- |
| Cold Boot Latency | ≤1.2s | Stopwatch from OS process start to Dashboard first frame |
| Frame Render Budget | ≤8.3ms (120 FPS path), ≤16.6ms (60 FPS fallback) | Flutter DevTools Performance view in profile mode |
| FTS5 Query Latency | ≤30ms on 100,000 records | Dart `Stopwatch` around DAO query call |
| Active Memory | ≤150MB | Flutter DevTools Memory profiler after 30-min session |
| Chart Render Time | ≤200ms | Dart `Stopwatch` around chart data computation |
| Analytics Aggregate Query | ≤100ms for 5-year MTD rollup | Dart `Stopwatch` around repository aggregate call |

### 11.3 Profiling Strategy
1. **Flutter DevTools Timeline**: Used during Milestone 8 for frame-level jank identification.
2. **Drift Query Explain**: `EXPLAIN QUERY PLAN` run against all DAO queries to verify index utilization.
3. **Dart Isolate Profiling**: Verify that heavy computations (net worth aggregation, report generation) correctly offload to `Isolate.run()` without blocking the UI thread.
4. **Memory Leak Detection**: Navigator push/pop 50 cycles of the Transaction Ledger screen; verify memory returns to baseline after each cycle.
5. **Battery Profiling**: Android Battery Historian used to verify background work (daily backup, WAL checkpoint) does not trigger significant battery consumption.

---

## 12. Documentation Deliverables

| Milestone | Required Documentation |
| :--- | :--- |
| **Milestone 1** | `README.md` (setup, architecture overview), `CONTRIBUTING.md` draft, `CHANGELOG.md` initialized |
| **Milestone 2** | Architecture diagram in `docs/SATD.md` updated with implemented routing and error type hierarchy |
| **Milestone 3** | Design token reference table in `docs/DSUX.md` cross-referenced with implementation class names |
| **Milestone 4** | DAO method documentation via `dart doc`. Entity relationship diagram updated in `docs/DDD.md` |
| **Milestone 5** | Feature developer guide: how to add a new transaction field end-to-end (Domain → Data → Presentation) |
| **Milestone 6** | Analytics query documentation: what each aggregate query computes and how to extend it |
| **Milestone 7** | Settings key reference: all `AppSettingsTable` keys, types, defaults, and UI controls |
| **Milestone 8** | Performance benchmark report. Test coverage report. Accessibility audit report |
| **Milestone 9** | Beta release notes in `CHANGELOG.md`. In-app Help screen content reviewed and complete |
| **Milestone 10** | v1.0 `CHANGELOG.md`. Full `dart doc` API documentation on GitHub Pages. App Store / Play Store listing copy. `SECURITY.md` with responsible disclosure policy. `LICENSE` file verified |

---

## 13. Final Readiness Checklist (v1.0 Release Gate)

### Features
- [ ] All 47 screens defined in the SSFS are implemented and manually tested.
- [ ] Quick Add Transaction Modal completes in ≤5 seconds (timed user test).
- [ ] Export → Import round-trip produces zero data delta on 1,000-record test dataset.
- [ ] Budget exceeded notification fires correctly.
- [ ] Goal completion notification fires correctly.
- [ ] Daily automated backup runs and writes correctly.
- [ ] Database Recovery Mode (Screen #47) is reachable and functional.
- [ ] Plugin Manager enables and disables plugins without crash.

### Testing
- [ ] Unit test statement coverage ≥85% on Domain and Data layers.
- [ ] All widget tests pass for happy path and error state on all primary screens.
- [ ] All integration tests pass on Android, iOS, and Linux.
- [ ] All golden tests pass on CI matrix.
- [ ] Export/import integration test passes (lossless round-trip).
- [ ] Authentication integration test passes on Android and iOS physical devices.

### Accessibility
- [ ] All interactive elements have semantic labels.
- [ ] Minimum contrast ratio (WCAG AA: 4.5:1 for body text) passes for all theme modes.
- [ ] Screen reader navigation verified on Android TalkBack and iOS VoiceOver.
- [ ] No text is conveyed by color alone (pattern + label fallback present).
- [ ] All focus traversal orders are logical (keyboard and switch access).

### Localization
- [ ] Zero hardcoded user-visible strings (verified by grep for untranslated string literals).
- [ ] `app_en.arb` is complete and all pluralization forms are defined.
- [ ] RTL layout mirror verified on all 47 screens using pseudolocale test.
- [ ] Date and currency formatting respects locale in all display contexts.

### Security
- [ ] Master encryption key stored in native hardware keychain (verified on Android Keystore and iOS Secure Enclave).
- [ ] No secrets, API keys, or PII logged in release builds.
- [ ] `flutter_secure_storage` values are not accessible after app uninstall (Android `accountType` not set).
- [ ] Database AES-256 encryption verified by attempting direct SQLite access without key.
- [ ] `SECURITY.md` with responsible disclosure policy is committed and visible on repository landing page.

### Performance
- [ ] Cold boot ≤1.2s on mid-range target device (Pixel 6 / iPhone 12 or equivalent).
- [ ] No jank frames (>8.3ms frame duration) during 60-second active use session.
- [ ] FTS5 query latency ≤30ms on 100,000-record dataset.
- [ ] Memory ≤150MB after 30-minute active session.
- [ ] Daily backup operation completes in background without UI freeze.

### Documentation
- [ ] `README.md` includes: project description, screenshots, feature list, setup instructions, architecture summary, contribution pointer.
- [ ] `CONTRIBUTING.md` is complete and describes: setup, branching, commit format, PR process, coding standards.
- [ ] `CHANGELOG.md` v1.0.0 entry is written.
- [ ] `dart doc` generated and published on GitHub Pages.
- [ ] All public API symbols have `///` dartdoc comments.
- [ ] Architecture diagram in `docs/SATD.md` is current.

### Store Assets
- [ ] Play Store: feature graphic, 8 phone screenshots, short description, full description, content rating.
- [ ] App Store: app icon, 10 screenshots (two device sizes), promotional text, description, keywords.
- [ ] F-Droid compatible metadata in `fastlane/` directory.
- [ ] All store screenshots captured on physical devices (not simulators).

### Licensing
- [ ] `LICENSE` file (AGPLv3 or chosen OSI license) committed in repository root.
- [ ] License headers present in all source files as required by chosen license.
- [ ] All third-party package licenses verified as permissive (MIT / BSD / Apache 2.0).
- [ ] `licenses/` directory contains full copies of all third-party licenses.
- [ ] Open Source Licenses Screen (#39) correctly displays all package attributions via `LicensePage`.

### Open-Source Readiness
- [ ] `CONTRIBUTING.md` is clear and tested by at least one external contributor.
- [ ] At least five `good first issue` labels applied to real, well-described issues.
- [ ] Architecture Proposal issue template functional.
- [ ] GitHub Discussions enabled for Q&A and feature requests.
- [ ] `CODEOWNERS` correctly routes reviews to core maintainers.
- [ ] All specification documents in `docs/` are current and consistent with the implemented application.
