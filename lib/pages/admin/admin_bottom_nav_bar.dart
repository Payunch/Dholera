import 'package:flutter/material.dart';
import '../dashboard_page.dart';
import '../leads_page.dart';
import '../updates_page.dart';
import '../settings_page.dart';
import '../../widgets/custom_side_menu.dart';

// TODO: Rename class to AdminMainLayout
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
      extendBodyBehindAppBar: true,
      drawer: CustomSideMenu(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        header: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        items: const [
          SideMenuItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          SideMenuItem(icon: Icons.people_alt_rounded, label: 'Leads'),
          SideMenuItem(icon: Icons.article_rounded, label: 'Blogs'),
          SideMenuItem(icon: Icons.settings_suggest_rounded, label: 'Settings'),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Positioned(
            top: 48,
            left: 16,
            child: Builder(
              builder: (ctx) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withAlpha(216),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(25, 0, 0, 0),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
