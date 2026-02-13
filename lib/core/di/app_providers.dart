import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_template/core/error/error_mapper.dart';
import 'package:firebase_template/core/logging/app_logger.dart';

// Single source of truth for infrastructure dependencies. Features depend on
// abstractions and request these instances via Riverpod (constructor DI style).
final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

final errorMapperProvider = Provider<ErrorMapper>((ref) {
  return const ErrorMapper();
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
