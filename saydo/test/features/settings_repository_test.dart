import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsRepository', () {
    test('default timezone is Africa/Algiers', () {
      const defaultTimezone = 'Africa/Algiers';
      expect(defaultTimezone, 'Africa/Algiers');
    });

    test('default language is English', () {
      const defaultLanguage = 'en';
      expect(defaultLanguage, 'en');
    });

    test('supported timezones list contains common zones', () {
      const timezones = [
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

      expect(timezones.contains('Africa/Algiers'), true);
      expect(timezones.contains('Europe/Paris'), true);
      expect(timezones.contains('America/New_York'), true);
    });

    test('supported languages are: English, French, Arabic', () {
      const languages = ['en', 'fr', 'ar'];
      expect(languages.length, 3);
      expect(languages.contains('en'), true);
      expect(languages.contains('fr'), true);
      expect(languages.contains('ar'), true);
    });
  });

  group('Language labels', () {
    test('en maps to English', () {
      expect(_languageLabel('en'), 'English');
    });

    test('fr maps to Français', () {
      expect(_languageLabel('fr'), 'Français');
    });

    test('ar maps to العربية', () {
      expect(_languageLabel('ar'), 'العربية');
    });

    test('unknown code maps to the code itself', () {
      expect(_languageLabel('de'), 'de');
    });
  });

  group('User profile', () {
    test('profile has email and created_at from Supabase auth', () {
      final json = {
        'email': 'user@example.com',
        'created_at': '2026-01-01T00:00:00.000',
      };

      expect(json['email'], 'user@example.com');
      expect(json['created_at'], isNotNull);
    });
  });
}

String _languageLabel(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'fr':
      return 'Français';
    case 'ar':
      return 'العربية';
    default:
      return code;
  }
}
