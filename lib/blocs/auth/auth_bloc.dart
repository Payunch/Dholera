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
      AppRole role = AppRole.userInvestor;
      if (savedRoleStr == AppRole.adminOwner.name) {
        role = AppRole.adminOwner;
      }

      // Perform background session verification with backend
      // The two account types use different /me endpoints. Passing the saved
      // role prevents an admin session from being checked as a normal user.
      final meResult = await _api.getMe(role: role.name);
      if (meResult['success'] == true) {
        final userData = meResult['user'] ?? meResult['data'] ?? {};
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
            role: role,
          ),
        );
      } else if (meResult['error'] != null &&
          (meResult['error'].toString().contains('401') ||
              meResult['error'].toString().contains('Unauthorized') ||
              meResult['error'].toString().contains('expired'))) {
        // Token explicitly expired or invalidated by server
        await _api.clearAuthToken();
        emit(
          const AuthState(
            status: AuthStatus.unauthenticated,
            role: AppRole.unknown,
          ),
        );
      } else {
        // Network offline or timeout - preserve existing valid session locally
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            token: token,
            userName: savedName,
            userEmail: savedEmail,
            role: role,
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
