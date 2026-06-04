import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../user_dashboard_page.dart';
import '../updates_page.dart';
import '../settings_page.dart';
import '../investor_landing_page.dart';
import '../../blocs/localization/localization_bloc.dart';
import '../../blocs/localization/localization_state.dart';

class UserBottomNavBar extends StatefulWidget {
  const UserBottomNavBar({super.key});

  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();
}

class _UserBottomNavBarState extends State<UserBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InvestorLandingPage(),
    const UpdatesPage(),
    const UserDashboardPage(), // This might be renamed to My Vault or similar for investors
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: state.translate('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.feed_rounded),
                label: state.translate('nav_updates'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: state.translate('nav_vault'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: state.translate('nav_about'),
              ),
            ],
          ),
        );
      },
    );
  }
}
