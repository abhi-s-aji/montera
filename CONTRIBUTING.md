# Contributing to Monetra

Thank you for your interest in contributing to Monetra!

Monetra is an open-source, privacy-first, offline-first personal finance platform built with Flutter, Riverpod, and Drift.

---

## Development Setup Guidelines

1. **Prerequisites**:
   - Flutter SDK (v3.22.0 or higher)
   - Dart SDK (v3.4.0 or higher)
2. **Clone & Setup**:
   ```bash
   git clone https://github.com/monetra/monetra.git
   cd monetra
   flutter pub get
   ```
3. **Run Code Verification**:
   Before submitting any pull request, ensure all three check steps pass cleanly:
   ```bash
   dart format .
   flutter analyze lib/
   flutter test
   ```

---

## Code Quality Standards

- Keep components modular, decoupled, and reusable.
- Follow standard Clean Architecture principles (Domain, Presentation, Service layers).
- Maintain 100% offline functionality. Do NOT introduce external cloud network dependencies.
