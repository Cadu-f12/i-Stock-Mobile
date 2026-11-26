import 'package:bloc/bloc.dart';
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginInitial());

  final LoginRepository _repository;

  void signOut() => emit(const LoginInitial());

  void emailChanged(String email) {
    if (state is LoginLoading) return;
    emit(
      LoginInitial(
        email: email,
        password: state.password,
        isPasswordVisible: state.isPasswordVisible,
      ),
    );
  }

  void passwordChanged(String password) {
    if (state is LoginLoading) return;
    emit(
      LoginInitial(
        email: state.email,
        password: password,
        isPasswordVisible: state.isPasswordVisible,
      ),
    );
  }

  void togglePasswordVisibility() {
    if (state is LoginLoading) return;
    emit(
      LoginInitial(
        email: state.email,
        password: state.password,
        isPasswordVisible: !state.isPasswordVisible,
      ),
    );
  }

  Future<void> submit() async {
    if (state is LoginLoading) return;

    final email = state.email;
    final password = state.password;
    final passwordVisible = state.isPasswordVisible;
    final emailIsEmpty = email.trim().isEmpty;
    final passwordIsEmpty = password.isEmpty;

    if (emailIsEmpty || passwordIsEmpty) {
      emit(
        LoginError(
          email: email,
          password: password,
          isPasswordVisible: passwordVisible,
          emailError: emailIsEmpty ? 'Informe seu e-mail.' : null,
          passwordError: passwordIsEmpty ? 'Informe sua senha.' : null,
        ),
      );
      return;
    }

    emit(
      LoginLoading(
        email: email,
        password: password,
        isPasswordVisible: passwordVisible,
      ),
    );

    try {
      final session = await _repository.login(
        LoginCredentials(email: email, password: password),
      );
      emit(
        LoginLoaded(
          email: email,
          isPasswordVisible: passwordVisible,
          session: session,
        ),
      );
    } on LoginInvalidCredentialsException {
      emit(
        LoginError(
          email: email,
          password: password,
          isPasswordVisible: passwordVisible,
          message: 'E-mail ou senha inválidos.',
        ),
      );
    } catch (_) {
      emit(
        LoginError(
          email: email,
          password: password,
          isPasswordVisible: passwordVisible,
          message: 'Não foi possível entrar. Tente novamente.',
        ),
      );
    }
  }
}
