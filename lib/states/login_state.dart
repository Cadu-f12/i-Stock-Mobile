import 'package:i_stock_mobile/models/login_session.dart';

/// Shared form data for all login states.
abstract class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;
}

class LoginInitial extends LoginState {
  const LoginInitial({super.email, super.password, super.isPasswordVisible});
}

class LoginError extends LoginState {
  const LoginError({
    super.email,
    super.password,
    super.isPasswordVisible,
    this.message,
    this.emailError,
    this.passwordError,
  });

  final String? message;
  final String? emailError;
  final String? passwordError;
}

class LoginLoading extends LoginState {
  const LoginLoading({super.email, super.password, super.isPasswordVisible});
}

class LoginLoaded extends LoginState {
  const LoginLoaded({
    super.email,
    super.password,
    super.isPasswordVisible,
    required this.session,
  });

  final LoginSession session;
}
