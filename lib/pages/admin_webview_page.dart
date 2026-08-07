import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/api_config.dart';
import 'login_page.dart'; // Just in case they want to fall back to the native login

class AdminWebViewPage extends StatefulWidget {
  const AdminWebViewPage({super.key});

  @override
  State<AdminWebViewPage> createState() => _AdminWebViewPageState();
}

class _AdminWebViewPageState extends State<AdminWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Convert API URL to the Frontend URL
    // Assuming Next.js Admin is hosted at the same root but without /api
    String adminUrl = ApiConfig.productionUrl.replaceAll('/api', '/admin');
    if (ApiConfig.useLocalBackend) {
       adminUrl = 'http://${ApiConfig.localIp}:3000/admin';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: \${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(adminUrl));
  }

  void _navigateTo(String path) {
    String baseUrl = ApiConfig.productionUrl.replaceAll('/api', '');
    if (ApiConfig.useLocalBackend) {
       baseUrl = 'http://${ApiConfig.localIp}:3000';
    }
    _controller.loadRequest(Uri.parse('$baseUrl$path'));
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Dholera Smart City', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Admin Portal', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _navigateTo('/admin'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Leads'),
              onTap: () => _navigateTo('/admin/leads'),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () => _navigateTo('/admin/analytics'),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Campaigns'),
              onTap: () => _navigateTo('/admin/campaigns'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Native Login (Fallback)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
        ],
      ),
    );
  }
}
