import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthLoginRequested>((event, emit) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        token: event.token,
        userName: event.userName,
        role: event.role,
      ));
    });

    on<AuthLogoutRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated, role: AppRole.unknown));
    });

    on<AuthCheckRequested>((event, emit) {
      if (state.token != null && state.status == AuthStatus.authenticated) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AuthState state) => state.toJson();
}
