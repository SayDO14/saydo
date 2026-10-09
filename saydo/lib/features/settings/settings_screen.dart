import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

const _timezoneKey = 'setting_timezone';
const _languageKey = 'setting_language';

final supportedTimezones = [
  'Africa/Algiers',
  'Africa/Casablanca',
  'Africa/Tunis',
  'Europe/Paris',
  'Europe/London',
  'America/New_York',
  'America/Los_Angeles',
  'Asia/Dubai',
  'Asia/Riyadh',
];

const supportedLanguages = ['en', 'fr', 'ar'];

String languageLabel(String code) => switch (code) {
      'en' => 'English',
      'fr' => 'Français',
      'ar' => 'العربية',
      _ => code,
    };

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prefs = snapshot.data!;
          final timezone = prefs.getString(_timezoneKey) ?? 'Africa/Algiers';
          final language = prefs.getString(_languageKey) ?? 'en';

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Profile section
              _SectionHeader('Profile'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Account'),
                subtitle: const Text('Manage your Supabase account'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              // Preferences
              const _SectionHeader('Preferences'),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Timezone'),
                subtitle: Text(timezone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTimezone(context, prefs, timezone),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(languageLabel(language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLanguage(context, prefs, language),
              ),

              // About
              const _SectionHeader('About'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Version'),
                subtitle: Text('0.1.0'),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickTimezone(BuildContext context, SharedPreferences prefs, String current) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select timezone'),
        children: supportedTimezones.map((tz) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, tz),
            child: Text(
              tz,
              style: TextStyle(
                fontWeight: tz == current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (picked != null) {
      await prefs.setString(_timezoneKey, picked);
    }
  }

  Future<void> _pickLanguage(BuildContext context, SharedPreferences prefs, String current) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select language'),
        children: supportedLanguages.map((lang) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, lang),
            child: Text(
              languageLabel(lang),
              style: TextStyle(
                fontWeight: lang == current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (picked != null) {
      await prefs.setString(_languageKey, picked);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use SayDo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // Sign out is handled by the auth repository
      // Navigate to onboarding/login
      context.go('/onboarding');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
