# Project Governance & Engineering Standards Manual (PGESM)
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-PGESM  
**Status:** Official Engineering & Governance Handbook  
**Author:** Technical Steering Committee & Core Maintainers  

---

## 1. Project Vision & Philosophy

### 1.1 Mission Statement
Monetra is dedicated to providing a high-performance, aesthetically stunning, open-source Personal Finance Workspace that puts complete data ownership back into the hands of the individual user. All user data stays strictly local, encrypted, and accessible offline.

### 1.2 Core Principles
1. **Offline-First & Local Sovereignty**: Zero required remote servers, tracking pixels, or third-party cloud backends.
2. **Architectural Purity**: Clean Architecture, strict SOLID principles, and type-safe database schemas over speed hacks.
3. **Design Excellence**: Modern typography, harmonious color palettes, fluid animations, and dark/OLED theme support.
4. **Long-Term Sustainability**: Code written today must remain readable, maintainable, and extensible for a decade.

### 1.3 Non-Goals
- **Cloud Account Synchronization**: Monetra will not host user authentication servers or proprietary sync clouds.
- **Third-Party Telemetry/Analytics**: Monetra will never integrate crash reporting or telemetry SDKs that exfiltrate data.
- **Ad Platforms & Monetization Frameworks**: Zero ads or affiliate marketing trackers.

---

## 2. Governance Model & Roles

```text
[ Technical Steering Committee (TSC) ]
                 │
                 ▼
      [ Core Maintainers ]
                 │
      ┌──────────┴──────────┐
      ▼                     ▼
[ PR Reviewers ]     [ Contributors ]
```

### 2.1 Technical Steering Committee (TSC)
- Composed of project leads and core architects.
- **Responsibilities**: Approves Architecture Decision Records (ADRs), governs release schedules, manages repository security keys, and settles technical disputes.

### 2.2 Core Maintainers
- **Responsibilities**: Reviews and merges pull requests, triages issues, mentors new contributors, and manages release builds.
- **Merge Authority**: Direct write access to `develop` and `main` branches.

### 2.3 PR Reviewers
- Active community members with domain expertise.
- **Responsibilities**: Evaluates PRs for architectural compliance, unit test completeness, and code formatting.

---

## 3. Repository Standards & Branching

- **`main`**: Production-ready release branch. Protected. Direct commits forbidden.
- **`develop`**: Primary integration branch for upcoming releases. Protected. Requires 2 maintainer approvals and passing CI.
- **`feature/feature-name`**: Topic branches for new capabilities.
- **`bugfix/issue-description`**: Topic branches for bug fixes.
- **`release/vX.Y.Z`**: Release preparation branches.

---

## 4. Coding & Quality Standards

### 4.1 Code Complexity Limits
- **Maximum File Length**: 300 lines.
- **Maximum Class Length**: 200 lines.
- **Maximum Method Length**: 40 lines.
- **Cyclomatic Complexity Target**: $\le 10$ per function.

### 4.2 Mandatory Dart Linter Rules
All code must pass `flutter analyze` enforcing strict options (`always_declare_return_types`, `avoid_print`, `cancel_subscriptions`, `unawaited_futures`).

---

## 5. Documentation Standards

- **Dartdoc Required**: Every public class, enum, method, and provider MUST include `///` documentation comments explaining its behavior, parameters, and thrown exceptions.
- **Architecture Updates**: Any structural refactor requires updating `docs/SATD.md` and logging an Architecture Decision Record (ADR).

---

## 6. Pull Request Standards & Merge Requirements

Every Pull Request must meet the following mandatory criteria before merging:

```text
[ PR Submitted ] ──> [ CI Analysis & Tests Pass ] ──> [ 2 Maintainer Approvals ] ──> [ Squash & Merge ]
```

- [x] Clear title using Conventional Commits format (`feat:`, `fix:`, `docs:`, `refactor:`).
- [x] Description cross-referencing a closed GitHub Issue (`Fixes #123`).
- [x] 100% clean static analysis (`flutter analyze`).
- [x] Unit/Widget tests added achieving $\ge 85\%$ statement coverage on modified logic.
- [x] Documentation updated across relevant files.

---

## 7. Architecture Governance & ADR Lifecycle

Significant structural changes MUST follow the Architecture Decision Record (ADR) process:

1. **Draft**: Create `docs/adr/ADR-XXXX-title.md` detailing Context, Proposed Decision, Alternatives, and Consequences.
2. **Review**: Discuss in a dedicated GitHub RFC Issue.
3. **Approval**: Require unanimous TSC sign-off.
4. **Implementation**: Code changes executed per approved ADR.

---

## 8. Security & Vulnerability Policy

- **Reporting**: Security vulnerabilities should be disclosed privately via `security@monetra.org` or GitHub Private Vulnerability Reporting (NEVER in public issues).
- **Secrets & Storage**: API keys and unmasked PII strictly prohibited. DB master keys stored in native hardware keychains.

---

## 9. Release Engineering & Versioning

Monetra follows **Semantic Versioning 2.0.0** (`MAJOR.MINOR.PATCH`):
- `MAJOR`: Incompatible API or database schema migrations requiring manual intervention.
- `MINOR`: Backward-compatible new features and analytics capability additions.
- `PATCH`: Backward-compatible bug fixes and minor UI tweaks.

---

## 10. Long-Term Maintenance & Upgrade Schedule

- **Flutter SDK Upgrades**: Evaluated quarterly against the `stable` channel.
- **Dependency Audits**: Automated quarterly audit for outdated pub packages, security advisories, and license compliance.

---

## 11. Maintainer Pre-Merge Verification Checklist

Before clicking **Squash and Merge**, the maintainer must confirm:

- [ ] CI build is green across all platform matrix jobs.
- [ ] No raw hardcoded styles or unmasked log statements exist.
- [ ] Domain layer contains zero UI or database imports.
- [ ] Unit and widget tests pass locally and on CI.
- [ ] Conventional Commit title is clear and descriptive.
- [ ] `task.md` and `CHANGELOG.md` updated.
