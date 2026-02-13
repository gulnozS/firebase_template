import 'package:firebase_template/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
