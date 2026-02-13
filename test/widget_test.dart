import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:firebase_template/features/auth/domain/entities/app_user.dart';

void main() {
  group('SignInUseCase', () {
    test('delegates sign in to repository', () async {
      final repository = _FakeAuthRepository();
      final useCase = SignInUseCase(repository);

      await useCase.call(email: 'dev@template.app', password: 'secret-123');

      expect(repository.lastEmail, 'dev@template.app');
      expect(repository.lastPassword, 'secret-123');
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<AppUser?> authStateChanges() => const Stream<AppUser?>.empty();

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> signOut() async {}
}
