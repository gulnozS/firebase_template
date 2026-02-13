import 'package:equatable/equatable.dart';

class AppFailure extends Equatable implements Exception {
  const AppFailure({required this.message, this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => <Object?>[message, code];
}
