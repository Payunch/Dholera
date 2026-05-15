import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class UserSessionsPage extends StatefulWidget {
  const UserSessionsPage({super.key});

  @override
  State<UserSessionsPage> createState() => _UserSessionsPageState();
}

class _UserSessionsPageState extends State<UserSessionsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getUserSessions();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() => _sessions = result['sessions']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sessions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return 'Active';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Login Sessions', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: _sessions.isEmpty
                  ? const Center(child: Text('No sessions found', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final loginAt = DateTime.parse(session['loginAt']).toLocal();
                        final logoutAt = session['logoutAt'] != null 
                            ? DateTime.parse(session['logoutAt']).toLocal() 
                            : null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(session['username'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Login: ${loginAt.day}/${loginAt.month}/${loginAt.year} ${loginAt.hour}:${loginAt.minute.toString().padLeft(2, '0')}'),
                                if (logoutAt != null)
                                  Text('Logout: ${logoutAt.day}/${logoutAt.month}/${logoutAt.year} ${logoutAt.hour}:${logoutAt.minute.toString().padLeft(2, '0')}')
                                else
                                  const Text('Status: Still logged in', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                Text('IP: ${session['ip'] ?? 'N/A'}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Duration', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                Text(_formatDuration(session['duration']), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
