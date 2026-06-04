import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_event.dart';
import '../blocs/localization/localization_state.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';
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
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to terminate your secure session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthBloc>().state is AuthAuthenticated;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('APP SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('APP PREFERENCES'),
                const SizedBox(height: 16),
                _buildThemeToggle(context),
                const SizedBox(height: 12),
                _buildLanguageSelector(context, localState),
                const SizedBox(height: 32),
                if (isAdmin) ...[
                  _buildSectionHeader('ADMIN CONTROLS'),
                  const SizedBox(height: 16),
                  _buildAdminTile(
                    'Business Settings',
                    'Manage platform contact and configuration.',
                    Icons.admin_panel_settings,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBusinessSettingsPage())),
                  ),
                ],
                const SizedBox(height: 48),
                _buildLogoutTile(context),
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
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.black, letterSpacing: 1.2, color: Colors.grey),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.boardTheme == AppBoardTheme.blueBoard;
        return _buildPreferenceTile(
          'Dark Mode',
          'Switch between light and dark visual themes.',
          Icons.dark_mode_outlined,
          trailing: Switch(
            value: isDark,
            activeColor: Colors.orange,
            onChanged: (val) {
              context.read<ThemeBloc>().add(ThemeChanged(val ? AppBoardTheme.blueBoard : AppBoardTheme.standard));
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, LocalizationState state) {
    return _buildPreferenceTile(
      'Language',
      'Choose your preferred UI language.',
      Icons.translate_rounded,
      trailing: DropdownButton<String>(
        value: state.locale.languageCode,
        underline: const SizedBox(),
        onChanged: (code) {
          if (code != null) {
            context.read<LocalizationBloc>().add(LocalizationChanged(Locale(code)));
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

  Widget _buildPreferenceTile(String title, String subtitle, IconData icon, {Widget? trailing}) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAdminTile(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: _buildPreferenceTile(title, subtitle, icon, trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey)),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.logout_rounded, color: Colors.red),
      ),
      title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      subtitle: const Text('Safely terminate your session.', style: TextStyle(fontSize: 10)),
      onTap: _handleLogout,
    );
  }
}

class AdminBusinessSettingsPage extends StatefulWidget {
  const AdminBusinessSettingsPage({super.key});

  @override
  State<AdminBusinessSettingsPage> createState() => _AdminBusinessSettingsPageState();
}

class _AdminBusinessSettingsPageState extends State<AdminBusinessSettingsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  String? _error;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await _apiService.getSettings();
      if (response['success'] == true) {
        setState(() {
          _settings = response['settings'] ?? {};
          _controllers.forEach((_, c) => c.dispose());
          _controllers.clear();
          _settings.forEach((k, v) => _controllers[k] = TextEditingController(text: v.toString()));
          _isLoading = false;
        });
      } else {
        setState(() { _error = response['error']; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _saveSettings() async {
    final Map<String, dynamic> updates = {};
    _controllers.forEach((k, c) => updates[k] = c.text);
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.updateSettings(updates);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully')));
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
              ..._controllers.keys.map((k) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _controllers[k],
                  decoration: InputDecoration(labelText: k.toUpperCase(), border: const OutlineInputBorder()),
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(20)),
                child: const Text('SAVE SETTINGS'),
              ),
            ],
          ),
    );
  }
}
