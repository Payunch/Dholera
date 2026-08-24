import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final ApiService _api = ApiService();

  AuthBloc() : super(const AuthState()) {
    on<AuthLoginRequested>((event, emit) async {
      await _api.setAuthToken(event.token);
      await _api.saveUserInfo(
        name: event.userName,
        role: event.role.name,
        email: event.userEmail,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          token: event.token,
          userName: event.userName,
          userEmail: event.userEmail,
          role: event.role,
        ),
      );
    });

    on<AuthLogoutRequested>((event, emit) async {
      // Revoke the server-side mobile refresh token before clearing local
      // credentials. Without this, a logged-out device can still refresh an
      // old session until the refresh token expires.
      await _api.logout();
      await _api.clearAuthToken();
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          role: AppRole.unknown,
        ),
      );
    });

    on<AuthCheckRequested>((event, emit) async {
      String? token = state.token;
      if (token == null || token.isEmpty) {
        token = await _api.getAuthToken();
      }

      if (token == null || token.isEmpty) {
        emit(
          const AuthState(
            status: AuthStatus.unauthenticated,
            role: AppRole.unknown,
          ),
        );
        return;
      }

      final userInfo = await _api.getUserInfo();
      final savedName = userInfo['name'] ?? state.userName ?? 'User';
      final savedEmail = userInfo['email'] ?? state.userEmail;
      final savedRoleStr = userInfo['role'] ?? state.role.name;
      final fallbackRole = savedRoleStr == AppRole.adminOwner.name
          ? AppRole.adminOwner
          : AppRole.userInvestor;

      // Restore the last known session immediately so the app stays open on
      // relaunch even if the backend validation takes a moment.
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          userName: savedName,
          userEmail: savedEmail,
          role: fallbackRole,
        ),
      );

      final candidates = <AppRole>[
        if (savedRoleStr == AppRole.adminOwner.name) AppRole.adminOwner,
        if (savedRoleStr == AppRole.userInvestor.name) AppRole.userInvestor,
        if (savedRoleStr != AppRole.adminOwner.name &&
            savedRoleStr != AppRole.userInvestor.name)
          AppRole.userInvestor,
        if (savedRoleStr != AppRole.adminOwner.name) AppRole.adminOwner,
      ];

      Map<String, dynamic>? successResult;
      AppRole? resolvedRole;
      bool sawExplicitAuthFailure = false;

      for (final candidate in candidates) {
        final meResult = await _api.getMe(role: candidate.name);
        if (meResult['success'] == true) {
          successResult = meResult;
          resolvedRole = candidate;
          break;
        }

        final errorText = meResult['error']?.toString() ?? '';
        if (errorText.contains('401') ||
            errorText.contains('Unauthorized') ||
            errorText.contains('expired')) {
          sawExplicitAuthFailure = true;
        }
      }

      if (successResult != null && resolvedRole != null) {
        final userData = successResult['user'] ?? successResult['data'] ?? {};
        final name =
            userData['name']?.toString() ??
            userData['username']?.toString() ??
            savedName;
        final email = userData['email']?.toString() ?? savedEmail;
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            token: token,
            userName: name,
            userEmail: email,
            role: resolvedRole,
          ),
        );
      } else if (sawExplicitAuthFailure) {
        // Token explicitly expired or invalidated by server.
        await _api.clearAuthToken();
        emit(
          const AuthState(
            status: AuthStatus.unauthenticated,
            role: AppRole.unknown,
          ),
        );
      } else {
        // Network offline, endpoint mismatch, or a temporary backend error.
        // Keep the last known session so reopening the app does not force login.
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            token: token,
            userName: savedName,
            userEmail: savedEmail,
            role: fallbackRole,
          ),
        );
      }
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AuthState state) => state.toJson();
}
