import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_event.dart';
import '../blocs/localization/localization_state.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';
import '../services/api_service.dart';
import '../theme/board_theme.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Settings Page');
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final labels = context.read<LocalizationBloc>().state;
        return AlertDialog(
          title: Text(labels.translate('logout_confirm_title')),
          content: Text(labels.translate('logout_confirm_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(labels.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(labels.translate('sign_out')),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final labels = context.read<LocalizationBloc>().state;
        return AlertDialog(
          title: Text(labels.translate('delete_account')),
          content: Text(labels.translate('delete_account_warning')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(labels.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final authBloc = context.read<AuthBloc>();
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final token = await _apiService.getAuthToken();
                  if (token == null || token.isEmpty) {
                    throw Exception('Your session has expired. Please sign in again.');
                  }
                  final apiResult = await _apiService.deleteUserAccount();
                  if (apiResult['success'] != true) {
                    throw Exception(apiResult['error'] ?? 'Failed to delete account.');
                  }

                  navigator.pop();
                  if (!mounted) return;
                  if (mounted) {
                    authBloc.add(AuthLogoutRequested());
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    });
                  }
                } catch (_) {
                  navigator.pop();
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to delete account. Please sign in again and retry.',
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(labels.translate('delete_permanently')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.status == AuthStatus.authenticated &&
        authState.role == AppRole.adminOwner;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              localState.translate('settings_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountCard(context, localState, authState),
                const SizedBox(height: 24),
                _buildSectionHeader(localState.translate('app_preferences')),
                const SizedBox(height: 16),
                _buildThemeToggle(localState),
                const SizedBox(height: 12),
                _buildLanguageSelector(context, localState),
                const SizedBox(height: 32),
                if (isAdmin) ...[
                  _buildSectionHeader(localState.translate('admin_controls')),
                  const SizedBox(height: 16),
                  _buildAdminTile(
                    localState.translate('business_settings'),
                    localState.translate('business_settings_desc'),
                    Icons.admin_panel_settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminBusinessSettingsPage(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    LocalizationState labels,
    AuthState authState,
  ) {
    final userName = authState.userName ?? 'User';
    final userEmail = authState.userEmail ?? '';
    final initials = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFF7A00),
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail.isEmpty ? labels.translate('settings_title') : userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(labels.translate('sign_out')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleDeleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.person_remove_rounded, size: 18),
                  label: Text(labels.translate('delete_account')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(LocalizationState labels) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.boardTheme == AppBoardTheme.blueBoard;
        return _buildPreferenceTile(
          labels.translate('dark_mode'),
          labels.translate('dark_mode_desc'),
          Icons.dark_mode_outlined,
          trailing: Switch(
            value: isDark,
            activeThumbColor: Colors.orange,
            onChanged: (val) {
              context.read<ThemeBloc>().add(
                    ThemeChanged(
                      val ? AppBoardTheme.blueBoard : AppBoardTheme.standard,
                    ),
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    LocalizationState state,
  ) {
    return _buildPreferenceTile(
      state.translate('language'),
      state.translate('language_desc_short'),
      Icons.translate_rounded,
      trailing: DropdownButton<String>(
        value: state.locale.languageCode,
        underline: const SizedBox(),
        onChanged: (code) {
          if (code != null) {
            context.read<LocalizationBloc>().add(
                  LocalizationChanged(Locale(code)),
                );
          }
        },
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
          DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAdminTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: _buildPreferenceTile(
        title,
        subtitle,
        icon,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

}

class AdminBusinessSettingsPage extends StatefulWidget {
  const AdminBusinessSettingsPage({super.key});

  @override
  State<AdminBusinessSettingsPage> createState() =>
      _AdminBusinessSettingsPageState();
}

class _AdminBusinessSettingsPageState extends State<AdminBusinessSettingsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.getSettings();
      if (response['success'] == true) {
        setState(() {
          _settings = response['settings'] ?? {};
          _controllers.forEach((_, c) => c.dispose());
          _controllers.clear();
          _settings.forEach(
            (k, v) => _controllers[k] = TextEditingController(text: v.toString()),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final Map<String, dynamic> updates = {};
    _controllers.forEach((k, c) => updates[k] = c.text);
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.updateSettings(updates);
      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
        }
        await _fetchSettings();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BUSINESS SETTINGS')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ..._controllers.keys.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _controllers[k],
                      decoration: InputDecoration(
                        labelText: k.toUpperCase(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text('SAVE SETTINGS'),
                ),
              ],
            ),
    );
  }
}
