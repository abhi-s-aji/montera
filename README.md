# Monetra — Personal Finance Workspace

> **Offline. Private. Yours.**

Monetra is an open-source, offline-first, privacy-first Personal Finance Workspace built with Flutter and Dart. Designed for power users, freelancers, and individuals who demand absolute sovereignty over their financial records.

---

## Key Principles

- **Offline-First & Local Vault**: All your accounts, ledgers, budgets, and settings remain exclusively on your device inside an encrypted SQLite database. Zero remote telemetry, zero analytics SDKs, and zero cloud tracking.
- **Clean Architecture & SOLID Design**: Built following strict Clean Architecture principles (Presentation, Application, Domain, Data) with Riverpod state management and Drift type-safe persistence.
- **Design System Excellence**: Modern responsive UI supporting Light, Dark, and OLED Pitch Black modes, customizable accent colors, dynamic corner radius controls, and curated typography.
- **Data Ownership**: Export complete workspace backups into human-readable JSON or CSV formats at any time. No vendor lock-in.

---

## Directory Structure

```text
monetra/
├── assets/                 # Fonts, icons, and static schemas
├── docs/                   # Immutable specification documents
│   ├── SRS.md              # Software Requirements Specification
│   ├── SATD.md             # System Architecture & Technical Design
│   ├── DDD.md              # Database & Data Model Design
│   ├── DSUX.md             # Design System & UI/UX Specification
│   ├── SSFS.md             # Screen-by-Screen Functional Specification
│   ├── BOOTSTRAP_SPEC.md   # Flutter Engineering & Bootstrap Specification
│   ├── ROADMAP.md          # Development Roadmap & Implementation Plan
│   ├── AIP.md              # AI Implementation Protocol
│   └── PGESM.md            # Project Governance & Engineering Manual
├── lib/
│   ├── core/               # Theme, database, providers, domain interfaces, widgets
│   └── features/           # Accounts, Budgets, Categories, Dashboard, Settings, Transactions
├── test/                   # Domain, repository, and widget unit tests
├── pubspec.yaml            # Flutter project dependencies
└── analysis_options.yaml   # Linter configuration
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>=3.16.0`, `stable` channel)
- Dart SDK (`>=3.2.0 <4.0.0`)

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/monetra/monetra.git
cd monetra

# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit test suite
flutter test

# Run application locally
flutter run -d chrome  # or macos / linux / windows / android
```

---

## Documentation

Full architectural specifications and development guidelines are available in the [`docs/`](file:///home/abhisaji/montera/docs/) directory:
- [Software Architecture & Technical Design (SATD)](file:///home/abhisaji/montera/docs/SATD.md)
- [Database & Data Model Design (DDD)](file:///home/abhisaji/montera/docs/DDD.md)
- [Design System & UI/UX Specification (DSUX)](file:///home/abhisaji/montera/docs/DSUX.md)
- [Project Governance & Engineering Manual (PGESM)](file:///home/abhisaji/montera/docs/PGESM.md)

---

## License

Monetra is released under the [AGPLv3 License](file:///home/abhisaji/montera/LICENSE).
