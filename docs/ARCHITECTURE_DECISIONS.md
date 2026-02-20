# Architecture Decisions (Plain English)

This document explains why each major technical decision exists.

## Why Clean Architecture?

- UI should not know Firebase implementation details.
- Domain rules should survive backend changes.
- Data layer isolates SDK and serialization concerns.

## Why Riverpod?

- Strong compile-time safety for dependency wiring.
- Localized feature providers improve modularity.
- Easy async state handling with `AsyncValue`.

## Why GoRouter + Redirects?

- Navigation guards are centralized and explicit.
- URL/deep-link support is cleaner than ad-hoc Navigator stacks.
- Auth session changes automatically trigger redirect refreshes.

## Why Runtime Environment Config?

- Keeps secrets and project IDs out of code.
- Makes `dev/stage/prod` switching predictable.
- Works in CI and local development uniformly.

## Why Repository Pattern?

- Presentation talks to use-cases, not SDKs.
- Repositories keep error mapping and logging in one place.
- Testability improves because interfaces are mockable/fakeable.

## Why Shared Error Mapper?

- Normalizes Firebase exceptions to one app-level failure type.
- UI gets user-safe error messages without SDK branching logic.

## Why CI Gates?

- Format/analyze/test gates block broken code from merging.
- Keeps quality consistent as the project scales.

## Why Integration Test Scaffold?

- Gives a clear place to add emulator-backed end-to-end tests.
- Encourages validating real flows beyond unit tests.
