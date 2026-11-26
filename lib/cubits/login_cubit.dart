import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/models/stored_session.dart';
import 'package:i_stock_mobile/repositories/device_authenticator.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/repositories/session_store.dart';
import 'package:i_stock_mobile/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._repository,
    this._sessionStore,
    this._authenticator, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const LoginInitial());

  final LoginRepository _repository;
  final SessionStore _sessionStore;
  final DeviceAuthenticator _authenticator;
  final DateTime Function() _now;
  int _attemptId = 0;
  Timer? _expiryTimer;
  StoredSession? _activeSession;

  Future<void> signOut({bool expired = false}) async {
    _attemptId++;
    if (expired) {
      try {
        await _sessionStore.clear();
      } catch (_) {
        // An expired JWT cannot be restored even if secure storage fails.
      }
    } else {
      await _sessionStore.clear();
    }
    _expiryTimer?.cancel();
    _activeSession = null;
    if (!isClosed) {
      emit(
        LoginInitial(
          statusMessage: expired
              ? 'Sua sessão expirou. Entre com e-mail e senha.'
              : null,
        ),
      );
    }
  }

  /// Return to Login without ending a still-valid, opted-in session.
  void lock() {
    if (state is! LoginLoaded) return;
    _attemptId++;
    _activeSession = null;
    emit(const LoginInitial());
  }

  Future<void> initialize() async {
    if (state is LoginLoaded || state is LoginLoading) return;
    final attemptId = _attemptId;
    try {
      final expiry = await _sessionStore.readExpiry();
      if (isClosed ||
          attemptId != _attemptId ||
          state is LoginLoaded ||
          state is LoginLoading) {
        return;
      }
      if (expiry == null) return;
      if (!_now().toUtc().isBefore(expiry)) {
        await _sessionStore.clear();
        if (!isClosed) {
          emit(
            LoginInitial(
              email: state.email,
              statusMessage: 'Sua sessão expirou. Entre com e-mail e senha.',
            ),
          );
        }
        return;
      }
      final available = await _authenticator.hasEnrolledBiometrics();
      if (!isClosed &&
          attemptId == _attemptId &&
          state is! LoginLoaded &&
          state is! LoginLoading) {
        emit(
          LoginInitial(
            email: state.email,
            password: state.password,
            isPasswordVisible: state.isPasswordVisible,
            canUnlock: available,
            statusMessage: available
                ? null
                : 'Biometria indisponível. Entre com e-mail e senha.',
          ),
        );
      }
    } catch (_) {
      if (!isClosed && attemptId == _attemptId) {
        emit(
          LoginInitial(
            email: state.email,
            password: state.password,
            statusMessage:
                'Desbloqueio indisponível. Entre com e-mail e senha.',
          ),
        );
      }
    }
  }

  Future<bool> canEnableBiometrics() async {
    try {
      return await _authenticator.hasEnrolledBiometrics();
    } catch (_) {
      return false;
    }
  }

  Future<bool> enableBiometrics() async {
    final session = _activeSession;
    final attemptId = _attemptId;
    if (session == null || !session.isValidAt(_now().toUtc())) return false;
    try {
      if (!await _authenticator.hasEnrolledBiometrics()) return false;
      if (attemptId != _attemptId || _activeSession != session) return false;
      await _sessionStore.clear();
      await _sessionStore.save(session);
      if (attemptId != _attemptId || _activeSession != session) {
        await _sessionStore.clear();
        return false;
      }
      return true;
    } catch (_) {
      try {
        await _sessionStore.clear();
      } catch (_) {}
      return false;
    }
  }

  Future<void> unlockWithBiometrics() async {
    if (state is LoginLoading) return;
    if (!state.canUnlock) {
      await initialize();
      if (state is LoginLoaded || state is LoginLoading) return;
      if (!state.canUnlock) {
        emit(
          LoginInitial(
            email: state.email,
            password: state.password,
            isPasswordVisible: state.isPasswordVisible,
            statusMessage: state.statusMessage ?? 'Entre com e-mail e senha para ativar o desbloqueio neste aparelho.',
          ),
        );
        return;
      }
    }
    final attemptId = ++_attemptId;
    final email = state.email;
    final password = state.password;
    final isPasswordVisible = state.isPasswordVisible;
    emit(
      LoginLoading(
        email: email,
        password: password,
        isPasswordVisible: isPasswordVisible,
        canUnlock: true,
      ),
    );
    try {
      final expiry = await _sessionStore.readExpiry();
      if (expiry == null || !_now().toUtc().isBefore(expiry)) {
        await _sessionStore.clear();
        if (!isClosed && attemptId == _attemptId) {
          emit(
            LoginInitial(
              email: email,
              password: password,
              isPasswordVisible: isPasswordVisible,
              statusMessage: 'Sua sessão expirou. Entre com e-mail e senha.',
            ),
          );
        }
        return;
      }
      if (!await _authenticator.hasEnrolledBiometrics()) {
        if (!isClosed && attemptId == _attemptId) {
          emit(
            LoginInitial(
              email: email,
              password: password,
              isPasswordVisible: isPasswordVisible,
              statusMessage:
                  'Biometria indisponível. Entre com e-mail e senha.',
            ),
          );
        }
        return;
      }
      final result = await _authenticator.authenticate();
      if (result != DeviceAuthResult.authenticated) {
        if (!isClosed && attemptId == _attemptId) {
          emit(
            LoginInitial(
              email: email,
              password: password,
              isPasswordVisible: isPasswordVisible,
              canUnlock: true,
              statusMessage: result == DeviceAuthResult.cancelled
                  ? 'Desbloqueio cancelado. Você pode entrar com e-mail e senha.'
                  : 'A autenticação do aparelho falhou. Tente novamente ou entre com e-mail e senha.',
            ),
          );
        }
        return;
      }
      if (isClosed || attemptId != _attemptId) return;
      final saved = await _sessionStore.readSession();
      if (isClosed || attemptId != _attemptId) return;
      if (saved == null || !saved.isValidAt(_now().toUtc())) {
        await _sessionStore.clear();
        if (!isClosed && attemptId == _attemptId) {
          emit(
            LoginInitial(
              email: email,
              password: password,
              isPasswordVisible: isPasswordVisible,
              statusMessage: 'Sua sessão expirou. Entre com e-mail e senha.',
            ),
          );
        }
        return;
      }
      _activate(saved);
      emit(
        LoginLoaded(email: '', session: saved.session, fromBiometrics: true),
      );
    } on BiometricsUnavailableException {
      if (!isClosed && attemptId == _attemptId) {
        emit(
          LoginInitial(
            email: email,
            password: password,
            isPasswordVisible: isPasswordVisible,
            statusMessage: 'Biometria indisponível. Entre com e-mail e senha.',
          ),
        );
      }
    } catch (_) {
      if (!isClosed && attemptId == _attemptId) {
        emit(
          LoginInitial(
            email: email,
            password: password,
            isPasswordVisible: isPasswordVisible,
            canUnlock: true,
            statusMessage:
                'Não foi possível desbloquear. Entre com e-mail e senha.',
          ),
        );
      }
    }
  }

  void _activate(StoredSession session) {
    _activeSession = session;
    _expiryTimer?.cancel();
    final remaining = session.expiresAt.difference(_now().toUtc());
    _expiryTimer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      signOut(expired: true);
    });
  }

  void emailChanged(String email) {
    if (state is LoginLoading) return;
    emit(
      LoginInitial(
        email: email,
        password: state.password,
        isPasswordVisible: state.isPasswordVisible,
        canUnlock: state.canUnlock,
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
        canUnlock: state.canUnlock,
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
        canUnlock: state.canUnlock,
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
          canUnlock: state.canUnlock,
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
        canUnlock: state.canUnlock,
      ),
    );
    final attemptId = ++_attemptId;
    final requestStartedAt = _now().toUtc();

    try {
      final session = await _repository.login(
        LoginCredentials(email: email, password: password),
      );
      if (isClosed || attemptId != _attemptId) return;
      try {
        await _sessionStore.clear();
      } catch (_) {
        // Password sign-in still works when device storage is unavailable.
      }
      if (isClosed || attemptId != _attemptId) return;
      final stored = StoredSession(
        session,
        StoredSession.deadline(session.accessToken, requestStartedAt),
      );
      if (!stored.isValidAt(_now().toUtc())) {
        emit(
          LoginError(
            email: email,
            password: password,
            message: 'A sessão recebida já expirou. Entre novamente.',
          ),
        );
        return;
      }
      _activate(stored);
      emit(
        LoginLoaded(
          email: email,
          isPasswordVisible: passwordVisible,
          canUnlock: state.canUnlock,
          session: session,
        ),
      );
    } on LoginInvalidCredentialsException {
      if (isClosed || attemptId != _attemptId) return;
      emit(
        LoginError(
          email: email,
          password: password,
          isPasswordVisible: passwordVisible,
          canUnlock: state.canUnlock,
          message: 'E-mail ou senha inválidos.',
        ),
      );
    } catch (_) {
      if (isClosed || attemptId != _attemptId) return;
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

  @override
  Future<void> close() async {
    _expiryTimer?.cancel();
    await super.close();
  }
}
