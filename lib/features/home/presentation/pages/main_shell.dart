import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'home_page.dart';
import '../../../reels/presentation/pages/reels_page.dart';
import '../../../astrology/presentation/pages/astrology_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

import 'package:easy_localization/easy_localization.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const AstrologyPage(),
    const ReelsPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_stories),
            label: 'astrology'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_circle_outline),
            label: 'reels'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: 'favorites'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // Use existing HomePage content
  }
}
