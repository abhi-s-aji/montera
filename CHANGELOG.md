# Changelog

All notable changes to the Monetra project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0-foundation] - 2026-07-22

### Added
- Complete Clean Architecture foundation and folder hierarchy (`lib/core/` and `lib/features/`).
- Riverpod state management setup with providers for Accounts, Budgets, Categories, Transactions, and Settings.
- Drift database schema, repositories, in-memory test providers, and DAOs.
- Design System tokens (`MonetraColors`, `MonetraTheme`, `MonetraCard`, `MonetraChart`, `StatCard`).
- Interactive screens for Workspace Dashboard, Transaction History Ledger, Financial Accounts Grid, Category Taxonomy, Budget Limits, and Privacy Settings.
- Export local JSON backup dialog for 100% data portability.
- Unit test suite verifying Domain entities, account balance updates, transaction soft deletes, and search query filters.
- Complete documentation suite in `docs/` (`SRS`, `SATD`, `DDD`, `DSUX`, `SSFS`, `BOOTSTRAP_SPEC`, `ROADMAP`, `AIP`, `PGESM`).
