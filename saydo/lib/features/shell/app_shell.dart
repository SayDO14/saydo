import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation around the main tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final Widget navigationShell;

  @override
  Widget build(BuildContext context) {
    final shellState = context.findAncestorStateOfType<StatefulNavigationShellState>();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shellState?.currentIndex ?? 0,
        onDestinationSelected: (i) => shellState?.goBranch(i, initialLocation: i == shellState.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none_rounded),
            selectedIcon: Icon(Icons.mic_rounded),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.email_outlined),
            selectedIcon: Icon(Icons.email),
            label: 'Emails',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
