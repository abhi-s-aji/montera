# Flutter Engineering & Project Bootstrap Specification
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-BOOTSTRAP  
**Status:** Approved Engineering Handbook  
**Author:** Principal Software Architect & Technical Steering Committee  

---

## 1. Repository Layout Specification

```text
monetra/
├── .github/                  # CI/CD Workflows, Issue/PR Templates, CODEOWNERS
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CODEOWNERS
│   └── workflows/
├── android/                  # Android native runner platform configuration
├── ios/                      # iOS native runner platform configuration
├── linux/                    # Linux GTK/C++ runner platform configuration
├── macos/                    # macOS CocoaRunner platform configuration
├── windows/                  # Windows Win32 C++ runner platform configuration
├── web/                      # Web Assembly / OPFS entry runner
├── assets/                   # Static binary assets (Fonts, Icons, Schemas)
│   ├── fonts/
│   ├── icons/
│   └── schemas/
├── docs/                     # Immutable Specification Documents
│   ├── SRS.md
│   ├── SATD.md
│   ├── DDD.md
│   ├── DSUX.md
│   ├── SSFS.md
│   └── BOOTSTRAP_SPEC.md
├── lib/                      # Core Clean Architecture & Feature Code
│   ├── core/
│   ├── features/
│   ├── l10n/
│   └── main.dart
├── scripts/                  # Developer CLI scripts (build, test, db check)
├── test/                     # Unit, DAO, and Provider Tests
├── integration_test/         # End-to-End Workflow Integration Tests
├── tool/                     # Code generation & lint validation utilities
├── analysis_options.yaml     # Strict Static Analysis Rules
├── pubspec.yaml              # Package Dependencies & Flutter Configuration
└── README.md                 # Open Source Repository Landing Page
```

---

## 2. Flutter SDK & Toolchain Requirements

- **Flutter Channel**: `stable`
- **Minimum Flutter SDK**: `>=3.16.0`
- **Minimum Dart SDK**: `>=3.2.0 <4.0.0`
- **SDK Upgrade Strategy**: SDK versions are locked per major release cycle. Dependencies upgraded quarterly via automated CI compatibility test runs.

---

## 3. Package Management Policy

- **Primary Rule**: Prefer official Flutter / Dart team packages (`flutter_localizations`, `path_provider`, `intl`).
- **Audit Rules**:
  1. **License**: Permissive open-source licenses only (MIT, BSD-3-Clause, Apache 2.0). GPL or copyleft licenses strictly prohibited.
  2. **Security**: Zero network telemetry dependencies.
  3. **Maintenance**: Active updates within last 6 months; pub.dev points $\ge 130/140$.

---

## 4. Curated Dependency Specification

| Package | Version | Layer / Purpose |
| :--- | :--- | :--- |
| `flutter_riverpod` | `^2.5.1` | Application State Management & Dependency Injection |
| `drift` | `^2.16.0` | Type-Safe SQLite Persistence & Reactive Streams |
| `sqlite3_flutter_libs` | `^0.5.20` | Native SQLite Binaries with FTS5 Support |
| `path_provider` | `^2.1.2` | Platform Sandboxed File System Paths |
| `uuid` | `^4.3.3` | RFC 4122 UUID v4 Generation |
| `intl` | `^0.20.2` | Date & Multi-Currency Formatting |
| `google_fonts` | `^6.1.0` | Custom Typography Loading (Inter, JetBrains Mono, Outfit) |
| `flutter_animate` | `^4.5.0` | Declarative Micro-interactions |
| `equatable` | `^2.0.5` | Value Equality Comparison for Domain Entities |
| `flutter_secure_storage`| `^9.0.0` | Hardware Keychain Master Key Encryption Storage |
| `local_auth` | `^2.1.8` | Native Biometric Authentication (Fingerprint/FaceID) |

---

## 5. Project Configuration & Analysis Options

### 5.1 Strict Linter Options (`analysis_options.yaml`)
- `always_declare_return_types`: `true`
- `avoid_empty_else`: `true`
- `avoid_print`: `true` (Enforces `debugPrint` or logger abstraction)
- `prefer_single_quotes`: `true`
- `unawaited_futures`: `true`
- `cancel_subscriptions`: `true`

---

## 6. Coding & Naming Standards

### 6.1 Naming Conventions
- **Folders & Files**: `snake_case` (e.g., `transaction_editor_dialog.dart`).
- **Classes & Enums**: `PascalCase` (e.g., `TransactionRepositoryImpl`).
- **Variables & Methods**: `camelCase` (e.g., `filteredTransactionsProvider`).
- **Constants**: `lowerCamelCase` or `UPPER_SNAKE_CASE` for global values.

### 6.2 Code Size Boundaries
- **Maximum File Length**: 300 lines of code.
- **Maximum Class Size**: 200 lines of code.
- **Maximum Method Length**: 40 lines of code.

---

## 7. Architecture Rules & Dependency Boundaries

```text
[ Presentation Layer ]  ──>  [ Application Layer ]  ──>  [ Domain Layer ]
         │                            │                        ▲
         │                            │                        │ (implements)
         └────────────────────────────┴──────────────>  [ Data Layer ]
```

- **Rule 1**: Domain Layer classes MUST NOT import `package:flutter/` or any database package.
- **Rule 2**: Features MUST NOT import private folders of other features.
- **Rule 3**: All asynchronous operations must return typed `Result<Success, Failure>` domain objects.

---

## 8. State Management Rules (Riverpod)

- **Rule 1 (Immutability)**: All state models must be $100\%$ immutable with `copyWith` methods.
- **Rule 2 (Disposal)**: Transient UI controllers must use `.autoDispose` to release memory on unmount.
- **Rule 3 (Rebuild Minimization)**: Views must subscribe via `ref.watch(provider.select((s) => s.property))` to isolate widget rebuilds.

---

## 9. Theme & Design System Integration Rules

- **Zero Hardcoded Pixels**: Spacing MUST reference base grid scale ($4, 8, 12, 16, 20, 24, 32, 48\text{px}$).
- **Zero Hardcoded Colors**: UI MUST reference `MonetraColors` tokens or `Theme.of(context).colorScheme`.
- **Dynamic Radius Handling**: All container borders MUST consume `BorderRadius.circular(settings.borderRadius)`.

---

## 10. Asset & Font Organization

```text
assets/
├── fonts/
│   ├── Inter-Regular.ttf
│   ├── JetBrainsMono-SemiBold.ttf
│   └── Outfit-Bold.ttf
├── icons/
│   ├── app_icon_dark.png
│   └── app_icon_light.png
└── schemas/
    └── monetra_backup_v1_schema.json
```

---

## 11. Localization (i18n) & RTL Strategy

- **ARB Format**: Source localization files stored in `lib/l10n/app_en.arb`.
- **Formatting Rules**: Multi-currency and dates MUST format via `intl` `NumberFormat` and `DateFormat` respecting target locale parameters.

---

## 12. Logging & Diagnostics Policy

- **Debug Mode**: Structured logging via `MonetraLogger` class.
- **Release Mode**: Zero log output to system stdout (`avoid_print = true`).
- **Privacy Masking**: Financial amounts, account numbers, and user descriptions are strictly masked in log strings (`***MASKED***`).

---

## 13. Error Handling Architecture

- **Global Catch Block**: Uncaught errors in UI render loops caught by `FlutterError.onError`.
- **User Display**: System exceptions translated to domain failures (`DatabaseFailure`, `ValidationFailure`) and presented via non-intrusive snackbar toasts.

---

## 14. Testing Standards & Coverage Thresholds

```text
        / \
       /   \         E2E / Integration Tests (10%)
      /-----\        -----------------------------
     /       \       Widget & UI Component Tests (30%)
    /---------\      ---------------------------------
   /           \     Unit & Repository Integration Tests (60%)
  --------------
```

- **Target Statement Coverage**: Minimum $85\%$ statement coverage across Domain, Data, and Application layers.
- **Continuous Integration Gate**: Pull requests failing unit test suites or coverage thresholds are automatically blocked from merging.

---

## 15. Git Workflow & Branching Model

- `main`: Production stable release branch.
- `develop`: Primary integration branch.
- `feature/feature-name`: Topic branches for new capabilities.
- `bugfix/issue-description`: Topic branches for bug fixes.
- **Commit Format**: Conventional Commits (e.g., `feat(ledger): add multi-tag search filter`).

---

## 16. GitHub Standards & Open Source Governance

- **Issue Templates**: Bug Report, Feature Request, Architecture Proposal.
- **PR Requirement**: Minimum 2 core maintainer approvals + $100\%$ passing CI checks.
- **CODEOWNERS**: Technical Steering Committee members assigned as mandatory reviewers for `lib/core/` and `docs/`.

---

## 17. CI/CD Pipeline (GitHub Actions)

```yaml
name: Monetra CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
```

---

## 18. Documentation Standards

- All public classes, interfaces, and methods MUST include `dartdoc` comments (`///`).
- Architecture changes MUST append an Architectural Decision Record (ADR) in `docs/SATD.md`.

---

## 19. Open Source Community Guidelines

- **Code Review Etiquette**: Constructive, polite, and architectural-focused feedback.
- **PR Size Goal**: Keep PRs under 400 lines of changed code for fast, thorough reviews.

---

## 20. Security Standards & Audit

- **Secrets Policy**: Zero API keys or secrets stored in source code.
- **Secure Storage**: Master DB encryption keys stored exclusively in native hardware keychains (`flutter_secure_storage`).

---

## 21. Performance Benchmarks

| Metric | Threshold Limit |
| :--- | :--- |
| **Cold Boot Latency** | $< 1.2\text{ s}$ |
| **Frame Render Budget** | $8.3\text{ ms}$ ($120\text{ FPS}$) / $16.6\text{ ms}$ ($60\text{ FPS}$) |
| **Query Performance** | $< 30\text{ ms}$ for 100,000 ledger rows |
| **Active Memory Limit** | $< 150\text{ MB}$ |

---

## 22. Release Checklist

- [ ] All unit and integration tests pass ($100\%$).
- [ ] Static analyzer reports 0 warnings and 0 errors.
- [ ] Version number updated in `pubspec.yaml` following Semantic Versioning (`MAJOR.MINOR.PATCH`).
- [ ] Release changelog generated in `CHANGELOG.md`.

---

## 23. Development Feature Workflow

```text
[Issue Created] ──> [Specification Review] ──> [Branch Created]
                                                     │
                                                     ▼
[Merge to develop] <── [PR Review & CI Pass] <── [Implementation & Tests]
```

---

## 24. Pre-Commit Engineering Checklist

Before submitting a Pull Request, every contributor must verify:
- [x] Code strictly formatted via `dart format .`.
- [x] Static analyzer passes via `flutter analyze` with 0 warnings.
- [x] All unit and repository integration tests pass via `flutter test`.
- [x] Public APIs documented with `///` dartdoc comments.
- [x] No raw hardcoded colors or arbitrary pixel values used.
- [x] No network calls or unmasked sensitive data logging added.
