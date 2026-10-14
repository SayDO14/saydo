import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saydo/l10n/app_localizations.dart';
import '../../core/app_settings.dart';
import '../../core/locale.dart';

const supportedLanguages = [
  {'code': 'fr', 'label': 'Français'},
  {'code': 'en', 'label': 'English'},
  {'code': 'ar', 'label': 'العربية'},
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _languageLabel(String code) {
    return supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'code': code, 'label': code},
    )['label']!;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider).languageCode;
    final timezone = ref.watch(timezoneProvider);
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      body: Stack(
        children: [
          // Background mesh wave asset at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/bg_wave.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      // Header with back button & SayDo / Paramètres
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // User specifically requested: back arrow takes to vocal (home) screen
                              context.go('/');
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF141738),
                                border: Border.all(
                                  color: const Color(0xFF2A3268),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SayDo',
                                style: TextStyle(
                                  color: Color(0xFF4E78FF),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.navSettings,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 1. Profil
                      _SettingsItemCard(
                        icon: Icons.person_outline_rounded,
                        title: AppLocalizations.of(context)!.settingsProfile,
                        subtitle: AppLocalizations.of(context)!.settingsProfileSub,
                        onTap: () => context.push('/settings/profile'),
                      ),
                      const SizedBox(height: 12),

                      // 2. Compte et sécurité
                      _SettingsItemCard(
                        icon: Icons.lock_outline_rounded,
                        title: AppLocalizations.of(context)!.settingsAccountSecurity,
                        subtitle: AppLocalizations.of(context)!.settingsAccountSecuritySub,
                        onTap: () => context.push('/settings/security'),
                      ),
                      const SizedBox(height: 12),

                      // 3. Langue
                      _SettingsItemCard(
                        icon: Icons.language_rounded,
                        title: AppLocalizations.of(context)!.language,
                        subtitle: _languageLabel(language),
                        onTap: () => _pickLanguage(context),
                      ),
                      const SizedBox(height: 12),

                      // 4. Fuseau horaire
                      _SettingsItemCard(
                        icon: Icons.access_time_rounded,
                        title: AppLocalizations.of(context)!.settingsTimezone,
                        subtitle: timezone,
                        onTap: () => _pickTimezone(context),
                      ),
                      const SizedBox(height: 12),

                      // 5. Notifications (Switch)
                      Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121533),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF222754), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.settingsNotifications,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: notifications,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF2853DE),
                              inactiveTrackColor: const Color(0xFF1F224D),
                              inactiveThumbColor: Colors.white70,
                              onChanged: (val) =>
                                  ref.read(notificationsProvider.notifier).set(val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 6. Calendrier connecté
                      _SettingsItemCard(
                        icon: Icons.calendar_today_outlined,
                        title: AppLocalizations.of(context)!.settingsCalendar,
                        subtitle: 'Google Calendar',
                        onTap: () => _showCalendarInfo(context),
                      ),
                      const SizedBox(height: 12),

                      // 7. Confidentialité et sécurité
                      _SettingsItemCard(
                        icon: Icons.shield_outlined,
                        title: AppLocalizations.of(context)!.settingsPrivacy,
                        onTap: () => _showPrivacyInfo(context),
                      ),
                      const SizedBox(height: 12),

                      // 8. Aide et support
                      _SettingsItemCard(
                        icon: Icons.help_outline_rounded,
                        title: AppLocalizations.of(context)!.settingsHelp,
                        onTap: () => _showHelpInfo(context),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTimezone(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF131533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsTimezone,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...supportedTimezones.map((tz) {
                  final isSelected = tz == ref.read(timezoneProvider);
                  return ListTile(
                    title: Text(
                      tz,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: Color(0xFF00E5FF))
                        : null,
                    onTap: () => Navigator.pop(ctx, tz),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      await ref.read(timezoneProvider.notifier).set(picked);
    }
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF131533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  AppLocalizations.of(ctx)!.appLanguage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...supportedLanguages.map((lang) {
                  final code = lang['code']!;
                  final label = lang['label']!;
                  final isSelected = code == ref.read(localeProvider).languageCode;
                  return ListTile(
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: Color(0xFF00E5FF))
                        : null,
                    onTap: () => Navigator.pop(ctx, code),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
  await ref.read(localeProvider.notifier).setLanguage(picked);
}
  }

  void _showCalendarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.calendarSyncedTitle, style: TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.calendarSyncedBody,
          style: TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.gotIt, style: TextStyle(color: Color(0xFF4E78FF))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.privacyTitle, style: TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.privacyBody,
          style: TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.close, style: TextStyle(color: Color(0xFF4E78FF))),
          ),
        ],
      ),
    );
  }

  void _showHelpInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.settingsHelp, style: TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.helpBody,
          style: TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.great, style: TextStyle(color: Color(0xFF4E78FF))),
          ),
        ],
      ),
    );
  }
}

class _SettingsItemCard extends StatelessWidget {
  const _SettingsItemCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF121533),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF222754), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF7E89B5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6874A6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
