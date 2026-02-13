import 'package:firebase_template/core/error/error_mapper.dart';
import 'package:firebase_template/core/logging/app_logger.dart';
import 'package:firebase_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_template/features/auth/domain/entities/app_user.dart';
import 'package:firebase_template/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required ErrorMapper errorMapper,
    required AppLogger logger,
  }) : _remoteDataSource = remoteDataSource,
       _errorMapper = errorMapper,
       _logger = logger;

  final AuthRemoteDataSource _remoteDataSource;
  final ErrorMapper _errorMapper;
  final AppLogger _logger;

  @override
  Stream<AppUser?> authStateChanges() {
    return _remoteDataSource.authStateChanges();
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('Sign-in succeeded: $email');
    } catch (error, stackTrace) {
      _logger.error('Sign-in failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to sign in right now.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _logger.info('Sign-out succeeded.');
    } catch (error, stackTrace) {
      _logger.error('Sign-out failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to sign out right now.',
      );
    }
  }
}
