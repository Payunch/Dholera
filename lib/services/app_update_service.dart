import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  final ApiService _apiService = ApiService();
  bool _hasPromptedThisSession = false;

  /// Check for app updates and prompt the user if an update is available.
  /// [silent] = true means do not show anything if the app is already up to date.
  /// [silent] = false means show a snackbar/dialog confirming the app is on the latest version.
  Future<bool> checkForUpdates(
    BuildContext context, {
    bool silent = true,
    bool forcePrompt = false,
  }) async {
    if (!forcePrompt && silent && _hasPromptedThisSession) {
      return false;
    }

    try {
      final appInfo = await _apiService.getAppInfo();
      if (appInfo['success'] != true) {
        if (!silent && context.mounted) {
          _showSnackBar(context, 'Unable to check for updates right now.');
        }
        return false;
      }

      final requiredBuild =
          int.tryParse(appInfo['requiredBuildNumber']?.toString() ?? '') ?? 0;
      final latestBuild =
          int.tryParse(appInfo['latestBuildNumber']?.toString() ?? '') ?? 0;
      final latestVersion =
          appInfo['latestVersionName']?.toString().trim().isNotEmpty == true
              ? appInfo['latestVersionName'].toString().trim()
              : (latestBuild > 0 ? 'Build $latestBuild' : '');

      String apkUrl = appInfo['apkUrl']?.toString().trim() ?? '';
      if (apkUrl.isEmpty) {
        apkUrl = 'https://www.dholeraplatform.com/downloads/dholera.apk';
      }

      final updateTitle =
          appInfo['updateTitle']?.toString().trim().isNotEmpty == true
              ? appInfo['updateTitle'].toString().trim()
              : 'New Update Available';

      final updateMessage =
          appInfo['updateMessage']?.toString().trim().isNotEmpty == true
              ? appInfo['updateMessage'].toString().trim()
              : 'A newer version of Dholera Platform is available with the latest 2026 infrastructure maps and breaking news.';

      final releaseNotes = appInfo['releaseNotes']?.toString().trim() ?? '';
      final isForced = appInfo['forceUpdate'] == true;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      final bool isMandatory =
          (requiredBuild > 0 && currentBuild < requiredBuild) ||
          (isForced && currentBuild < latestBuild);
      final bool isUpdateAvailable =
          isMandatory || (latestBuild > 0 && currentBuild < latestBuild);

      if (!isUpdateAvailable) {
        if (!silent && context.mounted) {
          _showUpToDateDialog(context, packageInfo.version, packageInfo.buildNumber);
        }
        return false;
      }

      if (!context.mounted) return true;

      _hasPromptedThisSession = true;
      await _showUpdateDialog(
        context,
        title: updateTitle,
        message: updateMessage,
        releaseNotes: releaseNotes,
        apkUrl: apkUrl,
        isMandatory: isMandatory,
        latestVersion: latestVersion,
        currentVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      );

      return true;
    } catch (e) {
      debugPrint('[AppUpdateService] Error: $e');
      if (!silent && context.mounted) {
        _showSnackBar(context, 'Error checking updates: $e');
      }
      return false;
    }
  }

  Future<void> _showUpdateDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String releaseNotes,
    required String apkUrl,
    required bool isMandatory,
    required String latestVersion,
    required String currentVersion,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isMandatory,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.system_update_rounded, color: Color(0xFF1E88E5)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current: $currentVersion',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (latestVersion.isNotEmpty)
                          Text(
                            'Latest: $latestVersion',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (releaseNotes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'What\'s New:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      releaseNotes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Later'),
                ),
              FilledButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download & Update'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (!isMandatory) {
                    Navigator.of(dialogContext).pop();
                  }
                  final uri = Uri.tryParse(apkUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpToDateDialog(
    BuildContext context,
    String version,
    String build,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text('Up to Date'),
            ],
          ),
          content: Text(
            'You are already using the latest official version of Dholera Platform (v$version+$build).',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
