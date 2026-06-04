import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/preferences/preferences_bloc.dart';
import '../blocs/preferences/preferences_event.dart';
import '../services/notification_service.dart';
import 'role_selection_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Verified Intelligence',
      description: 'Access real-time TP maps and land records cross-checked with official data.',
      image: 'assets/images/sub1.png',
    ),
    OnboardingItem(
      title: 'Smart Analytics',
      description: 'Track Dholera\'s growth with precision data and investment insights.',
      image: 'assets/images/sub2.png',
    ),
    OnboardingItem(
      title: 'Priority Connection',
      description: 'Directly connect with experts for verified plot inquiries and support.',
      image: 'assets/images/logo.png',
    ),
  ];

  void _finishOnboarding() async {
    context.read<PreferencesBloc>().add(OnboardingCompleted());
    
    // Sync notification token
    await NotificationService().syncTokenWithBackend();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(item.image, height: 200, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 200)),
                    const SizedBox(height: 40),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('SKIP'),
                ),
                Row(
                  children: List.generate(
                    _items.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.orange : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_currentPage < _items.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  icon: Icon(_currentPage == _items.length - 1 ? Icons.check_circle : Icons.arrow_circle_right),
                  color: Colors.orange,
                  iconSize: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({required this.title, required this.description, required this.image});
}
