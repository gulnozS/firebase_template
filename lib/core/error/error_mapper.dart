import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_template/core/error/app_failure.dart';

class ErrorMapper {
  const ErrorMapper();

  AppFailure map(
    Object error, {
    StackTrace? stackTrace,
    required String fallbackMessage,
  }) {
    if (error is AppFailure) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return AppFailure(
        message: error.message ?? 'Authentication failed.',
        code: error.code,
        stackTrace: stackTrace,
      );
    }

    if (error is FirebaseException) {
      return AppFailure(
        message: error.message ?? fallbackMessage,
        code: error.code,
        stackTrace: stackTrace,
      );
    }

    return AppFailure(message: fallbackMessage, stackTrace: stackTrace);
  }
}
