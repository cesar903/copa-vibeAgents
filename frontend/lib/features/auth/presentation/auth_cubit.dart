import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.session,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  final AuthStatus status;
  final AuthSession? session;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, isSubmitting, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.loading());

  final AuthRepository _repository;

  Future<void> restore() async {
    final session = await _repository.restoreSession();
    emit(
      AuthState(
        status: session == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        session: session,
      ),
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _submit(() => _repository.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _submit(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void expireSession() {
    if (state.status == AuthStatus.authenticated) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> _submit(Future<AuthSession> Function() action) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final session = await action();
      emit(AuthState(status: AuthStatus.authenticated, session: session));
      return true;
    } on ApiException catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      return false;
    }
  }
}
