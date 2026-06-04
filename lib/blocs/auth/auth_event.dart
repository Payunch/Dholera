import 'package:equatable/equatable.dart';
import 'auth_state.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String token;
  final String userName;
  final AppRole role;

  const AuthLoginRequested({
    required this.token,
    required this.userName,
    required this.role,
  });

  @override
  List<Object?> get props => [token, userName, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
