# AI Implementation Protocol (AIP)
## Monetra — Personal Finance Workspace
**Tagline:** Offline. Private. Yours.  
**Version:** 1.0.0-AIP  
**Status:** Approved Implementation Protocol  
**Author:** Lead Software Architect & Technical Steering Committee  

---

## 1. Overview & Governing Principles

This AI Implementation Protocol (AIP) governs all future software implementation, refactoring, and code review activities for Monetra. 

The preceding 8 specification documents:
1. Master Engineering Prompt
2. Software Requirements Specification (SRS)
3. System Architecture & Technical Design (SATD)
4. Database & Data Model Design (DDD)
5. Design System & UI/UX Specification (DSUX)
6. Screen-by-Screen Functional Specification (SSFS)
7. Flutter Engineering & Project Bootstrap Specification (BOOTSTRAP_SPEC)
8. Development Roadmap & Implementation Plan (ROADMAP)

are **immutable, authoritative project reference documents**. Every line of code written must comply strictly with these blueprints.

---

## 2. Pre-Implementation Review Workflow

Before any Dart/Flutter code or database schema change is written, the engineer/AI must execute the following 7-step pre-implementation analysis:

1. **Read Relevant Documentation**: Cross-reference the target feature with the SRS, SATD, DDD, DSUX, and SSFS screen specifications.
2. **Identify Affected Modules**: Map all affected files across Presentation, Application, Domain, and Data layers.
3. **Explain Implementation Strategy**: Detail how Clean Architecture boundaries are maintained.
4. **List Assumptions**: State all assumptions regarding data availability, system state, or platform APIs.
5. **Identify Risks**: Highlight potential edge cases, breaking changes, or performance risks.
6. **Verify Architectural Compliance**: Confirm zero forbidden imports (e.g. Domain importing Flutter/Drift, features importing peer private files).
7. **Formulate Test Plan**: Define required unit, widget, and integration test coverage.

---

## 3. Mandatory 15-Step Feature Implementation Lifecycle

Every feature implementation proceeds strictly through these 15 execution steps:

$$\begin{aligned}
1.\text{ Requirement Review} &\longrightarrow 2.\text{ Architecture Review} \longrightarrow 3.\text{ Database Review} \\
&\longrightarrow 4.\text{ UI Review} \longrightarrow 5.\text{ State Management Review} \\
&\longrightarrow 6.\text{ Testing Strategy} \longrightarrow 7.\text{ Documentation Update} \\
&\longrightarrow 8.\text{ Code Implementation} \longrightarrow 9.\text{ Static Analysis} \\
&\longrightarrow 10.\text{ Unit Tests} \longrightarrow 11.\text{ Widget Tests} \\
&\longrightarrow 12.\text{ Integration Tests} \longrightarrow 13.\text{ Performance Review} \\
&\longrightarrow 14.\text{ Accessibility Review} \longrightarrow 15.\text{ Final Validation}
\end{aligned}$$

---

## 4. Mandatory Output Format for Implementation Tasks

Whenever an implementation request is received, the response MUST structure its analysis using the following standardized sections before emitting any code:

```markdown
## Objective
[Clear 1-2 sentence description of what is being built or modified.]

## Affected Modules
- Domain: [Entities, Repositories, Use Cases]
- Data: [DAOs, Drift Tables, Repository Impls]
- Presentation: [Pages, Widgets, Controllers]
- Core/Utils: [Providers, Helpers, Theme]

## Dependencies
[Required providers, entities, or packages.]

## Risks & Mitigation
- Risk: [Potential issue] | Mitigation: [Prevention strategy]

## Implementation Plan
1. Step 1...
2. Step 2...

## Files to Create
- [NEW] `lib/path/to/file.dart`

## Files to Modify
- [MODIFY] `lib/path/to/file.dart`

## Testing Strategy
- Unit Tests: [Coverage plan]
- Widget Tests: [UI test plan]
- Integration Tests: [Workflow test plan]

## Documentation Updates
- Update `docs/SATD.md` / `task.md` / `CHANGELOG.md`
```

---

## 5. Code Quality & Architectural Rules

- **Clean Architecture Boundaries**:
  - `lib/core/domain/` — Pure Dart. Zero `package:flutter/` or database imports.
  - `lib/core/data/` — Implements domain interfaces. Manages Drift, Secure Storage, file system.
  - `lib/features/*/presentation/` — Consumes Riverpod state. Zero direct database queries.
- **SOLID Principles**: Single responsibility classes ($\le 200$ lines), open/closed interfaces, explicit dependency injection via Riverpod.
- **Zero Raw Styling**: No hardcoded hex colors or arbitrary pixel numbers. All styling must consume `MonetraTheme`, `MonetraColors`, `MonetraSpacing`, and `MonetraRadius`.
- **Dartdoc Mandatory**: All public symbols (`class`, `enum`, `mixin`, public `method`) MUST be documented with `///` dartdoc comments.

---

## 6. Security & Data Protection Standards

- **Privacy Masking**: `MonetraLogger` MUST mask financial amounts, account identifiers, and descriptions (`***MASKED***`) in debug logs; release builds output zero logs.
- **Local Vault Storage**: Sensitive keys and PINs MUST be persisted exclusively via hardware keychain (`flutter_secure_storage`).
- **Input Validation**: All forms MUST validate inputs client-side before invoking repository operations.

---

## 7. Performance & Accessibility Gating

- **Frame Render Budget**: UI components MUST NOT trigger rebuild cascades ($8.3\text{ms}$ budget for $120\text{ FPS}$). Use `ref.watch(provider.select(...))`.
- **Database Indexing**: All foreign keys and filtered columns MUST be backed by SQLite indexes.
- **Accessibility**: All interactive elements must supply `Semantics(label: ...)` and pass WCAG AA contrast ratio requirements ($4.5:1$).

---

## 8. Final Readiness Verification Checklist

Before marking any feature implementation as complete, verify:
- [x] Clean Architecture boundaries strictly preserved.
- [x] Documentation updated across docs & changelog.
- [x] Unit/Widget/Integration tests written and passing.
- [x] `flutter analyze` reports 0 errors and 0 warnings.
- [x] No `print()`, debug stubs, dead code, or `TODO` items without linked issue numbers.
- [x] Frame performance and accessibility criteria verified.
