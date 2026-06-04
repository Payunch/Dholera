import 'package:flutter/material.dart';
import '../dashboard_page.dart';
import '../leads_page.dart';
import '../updates_page.dart';
import '../settings_page.dart';

class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({super.key});

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const LeadsPage(),
    const UpdatesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Leads'),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Blogs'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
