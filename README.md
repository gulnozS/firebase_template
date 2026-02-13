# Firebase Enterprise Flutter Template

Production-oriented Flutter template with:

- Firebase Auth (email/password + persistent session + sign-out)
- Cloud Firestore CRUD example (`users/{uid}/notes`)
- Firebase Storage image upload/delete example
- Riverpod-based dependency injection and state management
- Clean architecture and feature-based modules

## Architecture

The template uses strict layer separation:

- `core`: shared config, logging, failures, DI providers, widgets, theme
- `features/<feature>/data`: Firebase datasources + repository impl
- `features/<feature>/domain`: entities, repositories, use-cases
- `features/<feature>/presentation`: Riverpod controllers + UI

Why this structure:

- Keeps Firebase SDK details out of UI and domain logic
- Makes each feature independently testable and scalable
- Enables incremental migration to additional backends if needed

## Firebase setup (Console + CLI)

1. Create a Firebase project in the Firebase Console.
2. Enable:
   - Authentication -> Email/Password
   - Cloud Firestore
   - Firebase Storage
3. Install Firebase CLI:
   - `npm i -g firebase-tools`
   - `firebase login`
4. (Optional but recommended) Install FlutterFire CLI:
   - `dart pub global activate flutterfire_cli`
5. Register Android/iOS/Web apps in Firebase and collect config values.
6. Run app with runtime config:

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

## Firestore and Storage rules (starter)

Use strong rules and tune to your auth/role model:

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
