import 'package:firebase_template/features/auth/domain/entities/app_user.dart';
import 'package:firebase_template/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  const WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() {
    return _repository.authStateChanges();
  }
}
