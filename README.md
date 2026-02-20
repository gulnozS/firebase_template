# Firebase Enterprise Flutter Template

Scalable Flutter starter with:

- Firebase Auth (email/password, session restore, sign-out)
- Firestore CRUD demo (`users/{uid}/notes`)
- Firebase Storage image upload/delete
- Riverpod for dependency injection + state management
- Clean architecture + feature modules
- Error mapping + structured logging + reusable UI primitives
- `go_router` auth guards
- CI workflow (format + analyze + test)
- Environment JSON files for `dev/stage/prod`

---

## 1) Prerequisites

- Flutter stable installed (`flutter --version`)
- Dart SDK (included with Flutter)
- Firebase project access
- Optional tooling:
  - Firebase CLI: `npm i -g firebase-tools`
  - FlutterFire CLI: `dart pub global activate flutterfire_cli`

---

## 2) Project Setup (copy/paste)

From project root:

```bash
flutter pub get
```

Run quality checks:

```bash
dart format lib test
flutter analyze
flutter test
```

---

## 3) Firebase Console Setup (step-by-step)

1. Create a Firebase project in Firebase Console.
2. Add apps:
   - Android app
   - iOS app
   - Web app
3. Enable services:
   - Authentication -> Sign-in method -> Email/Password
   - Cloud Firestore -> Create database (start in production mode)
   - Firebase Storage -> Get started
4. Copy config values from each app and use them as runtime `--dart-define`.

---

## 4) Runtime Config (`--dart-define`)

This template loads Firebase config from environment at runtime in
`lib/core/config/firebase_runtime_options.dart` using values declared in
`lib/core/config/env.dart`.

### Required keys

- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_IOS_API_KEY`
- `FIREBASE_IOS_APP_ID`
- `FIREBASE_IOS_BUNDLE_ID`

### Run command

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your-storage-bucket \
  --dart-define=FIREBASE_WEB_API_KEY=your-web-api-key \
  --dart-define=FIREBASE_WEB_APP_ID=your-web-app-id \
  --dart-define=FIREBASE_ANDROID_API_KEY=your-android-api-key \
  --dart-define=FIREBASE_ANDROID_APP_ID=your-android-app-id \
  --dart-define=FIREBASE_IOS_API_KEY=your-ios-api-key \
  --dart-define=FIREBASE_IOS_APP_ID=your-ios-app-id \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.app
```

Tip: use shell aliases or CI variables so you do not keep typing this.

### Easier env-based run (`--dart-define-from-file`)

This project includes:

- `env/dev.json`
- `env/stage.json`
- `env/prod.json`

Fill values, then run:

```bash
flutter run --dart-define-from-file=env/dev.json
```

---

## 5) Security Rules (minimum safe baseline)

Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/notes/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## 6) App Flow (what happens when app starts)

1. `main.dart` initializes Firebase with runtime options.
2. `ProviderScope` bootstraps Riverpod DI container.
3. `GoRouter` applies auth redirect rules using Firebase auth stream.
4. Signed-out users are routed to `SignInPage`.
5. Signed-in users are routed to `NotesPage`.
6. `NotesPage` streams Firestore notes and lets you create/update/delete notes.
7. If image selected, file is uploaded to Firebase Storage first, then URL is
   saved in Firestore.

---

## 7) Architecture (what each layer is used for)

- `core`: app-wide shared pieces (config, logging, failures, widgets, theme).
- `core/routing`: centralized `go_router` setup and auth redirects.
- `features/*/domain`:
  - Pure business contracts (`Repository` interfaces)
  - Entities
  - Use-cases (single-purpose operations)
- `features/*/data`:
  - Firebase datasources (SDK calls)
  - Repository implementations
  - Data models (Firestore mapping)
- `features/*/presentation`:
  - UI pages/widgets
  - Riverpod controllers/providers
  - Loading and error state orchestration

See full file-by-file explanations in `docs/FILE_GUIDE.md`.
See architecture rationale in `docs/ARCHITECTURE_DECISIONS.md`.

---

## 8) Folder Tree

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── config/
│   ├── di/
│   ├── error/
│   ├── logging/
│   ├── services/
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── notes/
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 9) Development Commands

```bash
# format
dart format lib test

# static analysis
flutter analyze

# tests
flutter test

# integration test scaffold
flutter test integration_test
```

---

## 10) Troubleshooting

- Error: `Missing Firebase dart-defines`
  - You missed one or more required `--dart-define` keys.
- Sign-in works but notes fail
  - Firestore rules likely block path `users/{uid}/notes`.
- Upload fails
  - Storage rules likely block `users/{uid}/notes/...`.
- iOS init issues
  - Verify `FIREBASE_IOS_BUNDLE_ID` matches actual bundle identifier.

---

## 11) What to build next

- Add Firebase Emulator integration tests.
- Add pull-request templates and CODEOWNERS for review quality.
- Add release workflows for Android/iOS build artifacts.

---

## 12) CI

GitHub Actions workflow is preconfigured in:

- `.github/workflows/flutter_ci.yml`

Checks on push/PR:

1. `flutter pub get`
2. `dart format --set-exit-if-changed`
3. `flutter analyze`
4. `flutter test`

---

## 13) Commented Documentation Map

- `README.md` -> setup + run + troubleshooting
- `docs/FILE_GUIDE.md` -> what each file is used for
- `docs/ARCHITECTURE_DECISIONS.md` -> why decisions were made
