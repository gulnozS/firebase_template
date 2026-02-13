import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_template/core/config/env.dart';

class FirebaseRuntimeOptions {
  FirebaseRuntimeOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      _assertNonEmpty(<String, String>{
        'FIREBASE_WEB_API_KEY': Env.firebaseWebApiKey,
        'FIREBASE_WEB_APP_ID': Env.firebaseWebAppId,
        'FIREBASE_MESSAGING_SENDER_ID': Env.firebaseMessagingSenderId,
        'FIREBASE_PROJECT_ID': Env.firebaseProjectId,
        'FIREBASE_STORAGE_BUCKET': Env.firebaseStorageBucket,
      });
      return const FirebaseOptions(
        apiKey: Env.firebaseWebApiKey,
        appId: Env.firebaseWebAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _assertNonEmpty(<String, String>{
          'FIREBASE_ANDROID_API_KEY': Env.firebaseAndroidApiKey,
          'FIREBASE_ANDROID_APP_ID': Env.firebaseAndroidAppId,
          'FIREBASE_MESSAGING_SENDER_ID': Env.firebaseMessagingSenderId,
          'FIREBASE_PROJECT_ID': Env.firebaseProjectId,
          'FIREBASE_STORAGE_BUCKET': Env.firebaseStorageBucket,
        });
        return const FirebaseOptions(
          apiKey: Env.firebaseAndroidApiKey,
          appId: Env.firebaseAndroidAppId,
          messagingSenderId: Env.firebaseMessagingSenderId,
          projectId: Env.firebaseProjectId,
          storageBucket: Env.firebaseStorageBucket,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _assertNonEmpty(<String, String>{
          'FIREBASE_IOS_API_KEY': Env.firebaseIosApiKey,
          'FIREBASE_IOS_APP_ID': Env.firebaseIosAppId,
          'FIREBASE_IOS_BUNDLE_ID': Env.firebaseIosBundleId,
          'FIREBASE_MESSAGING_SENDER_ID': Env.firebaseMessagingSenderId,
          'FIREBASE_PROJECT_ID': Env.firebaseProjectId,
          'FIREBASE_STORAGE_BUCKET': Env.firebaseStorageBucket,
        });
        return const FirebaseOptions(
          apiKey: Env.firebaseIosApiKey,
          appId: Env.firebaseIosAppId,
          messagingSenderId: Env.firebaseMessagingSenderId,
          projectId: Env.firebaseProjectId,
          storageBucket: Env.firebaseStorageBucket,
          iosBundleId: Env.firebaseIosBundleId,
        );
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static void _assertNonEmpty(Map<String, String> values) {
    final missing = values.entries
        .where((entry) => entry.value.trim().isEmpty)
        .map((entry) => entry.key)
        .toList();

    if (missing.isNotEmpty) {
      throw StateError('Missing Firebase dart-defines: ${missing.join(', ')}');
    }
  }
}
