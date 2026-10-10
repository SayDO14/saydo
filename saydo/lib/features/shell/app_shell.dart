import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Barre de navigation inférieure persistante à style moderne néon.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF08091B),
          border: Border(
            top: BorderSide(color: Color(0xFF171A3B), width: 1.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0x334E78FF),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                color: isSelected ? const Color(0xFF4E78FF) : const Color(0xFF6B76A0),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected ? const Color(0xFF4E78FF) : const Color(0xFF6B76A0),
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            elevation: 0,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today_rounded),
                label: 'Événements',
              ),
              NavigationDestination(
                icon: Icon(Icons.check_box_outlined),
                selectedIcon: Icon(Icons.check_box_rounded),
                label: 'Tâches',
              ),
              NavigationDestination(
                icon: Icon(Icons.mail_outline_rounded),
                selectedIcon: Icon(Icons.mail_rounded),
                label: 'Emails',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
