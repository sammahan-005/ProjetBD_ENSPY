import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Discussions'),
    _TabItem(icon: Icons.circle_outlined, activeIcon: Icons.circle, label: 'Statuts'),
    _TabItem(icon: Icons.call_outlined, activeIcon: Icons.call, label: 'Appels'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF1A1A2E),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          indicatorColor: const Color(0xFF6C63FF).withOpacity(0.2),
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(tab.icon, color: const Color(0xFF666680)),
                  selectedIcon: Icon(tab.activeIcon, color: const Color(0xFF6C63FF)),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}
