import 'package:equatable/equatable.dart';

enum AuthStatus { authenticated, unauthenticated, loading }
enum AppRole { adminOwner, userInvestor, unknown }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppRole role;
  final String? token;
  final String? userName;
  final String? userEmail;

  const AuthState({
    this.status = AuthStatus.loading,
    this.role = AppRole.unknown,
    this.token,
    this.userName,
    this.userEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppRole? role,
    String? token,
    String? userName,
    String? userEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      token: token ?? this.token,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props => [status, role, token, userName, userEmail];

  Map<String, dynamic> toJson() {
    return {
      'status': status.index,
      'role': role.index,
      'token': token,
      'userName': userName,
      'userEmail': userEmail,
    };
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      status: AuthStatus.values[json['status'] as int? ?? AuthStatus.loading.index],
      role: AppRole.values[json['role'] as int? ?? AppRole.unknown.index],
      token: json['token'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }
}
