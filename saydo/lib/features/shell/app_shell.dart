import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saydo/l10n/app_localizations.dart';
/// Barre de navigation inférieure flottante style glassmorphism moderne (conforme Photo 3).
<<<<<<< HEAD
=======

/// Bottom navigation around the main tabs.
>>>>>>> pr-3
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F2E).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF222C68),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _BarItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: AppLocalizations.of(context)!.navHome,
                      isSelected: shell.currentIndex == 0,
                      onTap: () => shell.goBranch(0, initialLocation: shell.currentIndex == 0),
                    ),
                    _BarItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      label: AppLocalizations.of(context)!.navEvents,
                      isSelected: shell.currentIndex == 1,
                      onTap: () => shell.goBranch(1, initialLocation: shell.currentIndex == 1),
                    ),
                    _BarItem(
                      icon: Icons.check_box_outlined,
                      activeIcon: Icons.check_box_rounded,
                      label: AppLocalizations.of(context)!.navTasks,
                      isSelected: shell.currentIndex == 2,
                      onTap: () => shell.goBranch(2, initialLocation: shell.currentIndex == 2),
                    ),
                    _BarItem(
                      icon: Icons.mail_outline_rounded,
                      activeIcon: Icons.mail_rounded,
                      label: AppLocalizations.of(context)!.navEmails,
                      isSelected: shell.currentIndex == 3,
                      onTap: () => shell.goBranch(3, initialLocation: shell.currentIndex == 3),
                    ),
                    _BarItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: AppLocalizations.of(context)!.navSettings,
                      isSelected: shell.currentIndex == 4,
                      onTap: () => shell.goBranch(4, initialLocation: shell.currentIndex == 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 4 : 2,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1B2666) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: const Color(0xFF3861FB).withValues(alpha: 0.4), width: 1)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3861FB).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? const Color(0xFF4E78FF) : const Color(0xFF6B7AA8),
                size: 21,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF93C5FD) : const Color(0xFF6B7AA8),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
<<<<<<< HEAD
=======
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
>>>>>>> pr-3
      ),
    );
  }
}
