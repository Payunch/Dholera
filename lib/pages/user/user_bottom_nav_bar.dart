import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../updates_page.dart';
import '../investor_landing_page.dart';
import '../vault_page.dart';
import '../about_page.dart';
import '../../blocs/localization/localization_bloc.dart';
import '../../blocs/localization/localization_state.dart';
import '../../widgets/custom_side_menu.dart';

// TODO: Rename class to UserMainLayout since it no longer uses a BottomNavBar
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
    const VaultPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: CustomSideMenu(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            header: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                'Dholera Platform',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            items: [
              SideMenuItem(icon: Icons.home_rounded, label: state.translate('nav_home')),
              SideMenuItem(icon: Icons.feed_rounded, label: state.translate('nav_updates')),
              SideMenuItem(icon: Icons.account_balance_wallet_rounded, label: state.translate('nav_vault')),
              SideMenuItem(icon: Icons.person_rounded, label: state.translate('nav_about')),
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
      },
    );
  }
}
