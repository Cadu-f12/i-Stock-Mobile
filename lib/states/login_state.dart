import 'package:i_stock_mobile/models/login_session.dart';

/// Shared form data for all login states.
abstract class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.canUnlock = false,
    this.statusMessage,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool canUnlock;
  final String? statusMessage;
}

class LoginInitial extends LoginState {
  const LoginInitial({
    super.email,
    super.password,
    super.isPasswordVisible,
    super.canUnlock,
    super.statusMessage,
  });
}

class LoginError extends LoginState {
  const LoginError({
    super.email,
    super.password,
    super.isPasswordVisible,
    super.canUnlock,
    super.statusMessage,
    this.message,
    this.emailError,
    this.passwordError,
  });

  final String? message;
  final String? emailError;
  final String? passwordError;
}

class LoginLoading extends LoginState {
  const LoginLoading({
    super.email,
    super.password,
    super.isPasswordVisible,
    super.canUnlock,
    super.statusMessage,
  });
}

class LoginLoaded extends LoginState {
  const LoginLoaded({
    super.email,
    super.password,
    super.isPasswordVisible,
    super.canUnlock,
    required this.session,
    this.fromBiometrics = false,
  });

  final LoginSession session;
  final bool fromBiometrics;
}
