import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../updates_page.dart';
import '../maps_vault_hub_page.dart';
import '../investor_profile_page.dart';
import '../../blocs/localization/localization_bloc.dart';
import '../../blocs/localization/localization_state.dart';

class UserBottomNavBar extends StatefulWidget {
  final int initialIndex;
  const UserBottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();
}

class _UserBottomNavBarState extends State<UserBottomNavBar> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    UpdatesPage(),
    MapsVaultHubPage(),
    InvestorProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: const Color(0xFFFF7A00).withValues(alpha: 0.16),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Color(0xFFFF7A00), size: 24);
                    }
                    return IconThemeData(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 22,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7A00),
                        letterSpacing: 0.3,
                      );
                    }
                    return TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 64,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.feed_outlined),
                      selectedIcon: Icon(Icons.feed_rounded),
                      label: 'Intelligence',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map_rounded),
                      label: 'Maps & Vault',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.support_agent_outlined),
                      selectedIcon: Icon(Icons.support_agent_rounded),
                      label: 'Investor Desk',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
