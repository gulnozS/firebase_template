# File Guide (What Each File Is For)

This guide maps each important file to its exact responsibility so new
contributors can navigate fast.

## Entry + App Shell

- `lib/main.dart`
  - App entry point.
  - Initializes Firebase with runtime options.
  - Wraps app with Riverpod `ProviderScope`.
- `lib/app.dart`
  - Global `MaterialApp` setup (theme + root page).

## Core Layer

- `lib/core/config/env.dart`
  - Typed access to all runtime `--dart-define` keys.
- `lib/core/config/firebase_runtime_options.dart`
  - Builds `FirebaseOptions` per platform using `Env`.
  - Throws explicit error when required keys are missing.

- `lib/core/di/app_providers.dart`
  - Global dependency providers:
    - `FirebaseAuth`
    - `FirebaseFirestore`
    - `FirebaseStorage`
    - Logger + ErrorMapper

- `lib/core/routing/app_router.dart`
  - `go_router` route table and auth redirect policy.
  - Prevents signed-out access to protected routes.
- `lib/core/routing/go_router_refresh_stream.dart`
  - Refresh bridge so router reacts to auth stream changes.

- `lib/core/error/app_failure.dart`
  - Unified failure type used across layers.
- `lib/core/error/error_mapper.dart`
  - Converts SDK exceptions into user-facing `AppFailure`.

- `lib/core/logging/app_logger.dart`
  - Logging wrapper around `logger` package.

- `lib/core/services/storage_service.dart`
  - Storage abstraction (interface).
- `lib/core/services/firebase_storage_service.dart`
  - Firebase Storage implementation (upload + delete).

- `lib/core/theme/app_theme.dart`
  - Centralized light/dark theme.

- `lib/core/widgets/app_loader.dart`
  - Shared loading widget.
- `lib/core/widgets/app_error_text.dart`
  - Shared error text widget.

## Auth Feature

### Domain

- `lib/features/auth/domain/entities/app_user.dart`
  - Domain-safe user representation.
- `lib/features/auth/domain/repositories/auth_repository.dart`
  - Auth contract used by use-cases.
- `lib/features/auth/domain/usecases/sign_in_use_case.dart`
  - Sign-in action.
- `lib/features/auth/domain/usecases/sign_out_use_case.dart`
  - Sign-out action.
- `lib/features/auth/domain/usecases/watch_auth_state_use_case.dart`
  - Stream of auth session changes.

### Data

- `lib/features/auth/data/models/app_user_model.dart`
  - Firebase `User` to domain mapping.
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
  - Direct `FirebaseAuth` calls.
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
  - Error handling + logging + datasource orchestration.

### Presentation

- `lib/features/auth/presentation/providers/auth_providers.dart`
  - Riverpod wiring for auth feature.
  - Includes action controller state for loading/error handling.
- `lib/features/auth/presentation/pages/sign_in_page.dart`
  - Email/password UI + validation + sign-in action trigger.

## Notes Feature (Firestore + Storage demo)

### Domain

- `lib/features/notes/domain/entities/note.dart`
  - Core note entity.
- `lib/features/notes/domain/repositories/note_repository.dart`
  - Notes contract (stream + CRUD).
- `lib/features/notes/domain/usecases/*.dart`
  - Single-purpose actions:
    - `watch_notes_use_case.dart`
    - `create_note_use_case.dart`
    - `update_note_use_case.dart`
    - `delete_note_use_case.dart`

### Data

- `lib/features/notes/data/models/note_model.dart`
  - Firestore data mapping (`Timestamp <-> DateTime`).
- `lib/features/notes/data/datasources/note_remote_data_source.dart`
  - Firestore collection operations.
  - Storage image upload integration for create/update.
- `lib/features/notes/data/repositories/note_repository_impl.dart`
  - Repository implementation with mapped failures + logging.

### Presentation

- `lib/features/notes/presentation/providers/notes_providers.dart`
  - Feature-local DI and action controllers.
  - Stream provider for notes list.
- `lib/features/notes/presentation/pages/notes_page.dart`
  - Notes list UI + create/update/delete dialogs.
  - Image picker integration for Storage upload demo.

## Tests

- `test/widget_test.dart`
  - Baseline unit-level use-case test scaffold.
  - Intended as starter pattern for more tests.

- `integration_test/app_smoke_test.dart`
  - Placeholder integration test scaffold.
  - Intended for Firebase Emulator-backed end-to-end tests.

## Environment + CI

- `env/dev.json`
  - Local development Firebase values.
- `env/stage.json`
  - Staging Firebase values.
- `env/prod.json`
  - Production Firebase values.
- `.github/workflows/flutter_ci.yml`
  - CI checks for formatting, analysis, and test validation.
