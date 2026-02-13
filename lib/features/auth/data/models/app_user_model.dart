import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_template/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({required super.id, required super.email});

  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(id: user.uid, email: user.email ?? '');
  }
}
