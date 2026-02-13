import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_template/core/di/app_providers.dart';
import 'package:firebase_template/core/error/app_failure.dart';
import 'package:firebase_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_template/features/auth/domain/entities/app_user.dart';
import 'package:firebase_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:firebase_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:firebase_template/features/auth/domain/usecases/watch_auth_state_use_case.dart';

// Providers are grouped by feature so modules stay independent and easy to
// extract into packages in larger apps.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(firebaseAuthProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    errorMapper: ref.watch(errorMapperProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(watchAuthStateUseCaseProvider).call();
});

final authActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthActionController, void>(
      AuthActionController.new,
    );

class AuthActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(signInUseCaseProvider)
          .call(email: email.trim(), password: password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider).call();
    });
  }

  String? errorMessage() {
    final error = state.asError?.error;
    if (error is AppFailure) {
      return error.message;
    }
    return error?.toString();
  }
}
