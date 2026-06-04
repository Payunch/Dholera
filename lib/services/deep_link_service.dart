import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../pages/secure_pdf_viewer_page.dart';
import '../pages/project_detail_page.dart';
import '../models/project.dart';
import 'api_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    // 1. Handle links when app is already open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, navigatorKey);
    });

    // 2. Handle links that opened the app
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri, navigatorKey);
    });
  }

  void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) async {
    final path = uri.path;
    final params = uri.queryParameters;

    if (path.contains('/pdf/view/')) {
      final idStr = path.split('/').last;
      final id = int.tryParse(idStr);
      if (id != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => SecurePdfViewerPage(pdfId: id, title: 'Secured Document')),
        );
      }
    } else if (path.contains('/projects/')) {
      final slug = path.split('/').last;
      // Fetch project details first
      final api = ApiService();
      final response = await api.getProjects();
      if (response['success'] == true) {
        final List projects = response['projects'];
        final projectJson = projects.firstWhere((p) => p['slug'] == slug, orElse: () => null);
        if (projectJson != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ProjectDetailPage(project: Project.fromJson(projectJson))),
          );
        }
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
