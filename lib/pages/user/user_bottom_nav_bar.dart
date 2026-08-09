import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../updates_page.dart';
import '../investor_landing_page.dart';
import '../about_page.dart';
import '../tp_maps_page.dart';
import '../projects_page.dart';
import '../portals_page.dart';
import '../airport_page.dart';
import '../infrastructure_page.dart';
import '../contact_page.dart';
import '../vault_page.dart';
import '../../blocs/localization/localization_bloc.dart';
import '../../blocs/localization/localization_state.dart';
import '../../blocs/auth/auth_bloc.dart';
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
    const TpMapsPage(),
    const VaultPage(),
    const PortalsPage(),
    const ProjectsPage(),
    const AirportPage(),
    const InfrastructurePage(),
    const UpdatesPage(),
    const AboutPage(),
    const ContactPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        final userName = context.read<AuthBloc>().state.userName ?? 'User';
        final initials = userName
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0])
            .join()
            .toUpperCase();
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: CustomSideMenu(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            header: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      initials.isEmpty ? 'U' : initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Text(
                          'Dholera Platform',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            items: [
              SideMenuItem(
                icon: Icons.home_rounded,
                label: state.translate('nav_home'),
              ),
              SideMenuItem(
                icon: Icons.map_rounded,
                label: state.translate('nav_tp_maps'),
              ),
              SideMenuItem(
                icon: Icons.picture_as_pdf_rounded,
                label: state.translate('nav_pdf'),
              ),
              SideMenuItem(
                icon: Icons.public_rounded,
                label: state.translate('nav_portals'),
              ),
              SideMenuItem(
                icon: Icons.business_rounded,
                label: state.translate('nav_projects'),
              ),
              SideMenuItem(
                icon: Icons.flight_takeoff_rounded,
                label: state.translate('nav_airport'),
              ),
              SideMenuItem(
                icon: Icons.construction_rounded,
                label: state.translate('nav_infrastructure'),
              ),
              SideMenuItem(
                icon: Icons.feed_rounded,
                label: state.translate('nav_updates'),
              ),
              SideMenuItem(
                icon: Icons.person_rounded,
                label: state.translate('nav_about'),
              ),
              SideMenuItem(
                icon: Icons.contact_support_rounded,
                label: state.translate('nav_contact'),
              ),
            ],
          ),
          body: Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _pages),
              Positioned(
                top: 48,
                left: 16,
                child: Builder(
                  builder: (ctx) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withAlpha(216),
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
