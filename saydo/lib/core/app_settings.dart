import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// IANA zone names offered in Settings. Must be valid names: they are sent to
/// the agent and stored in the `events.timezone` column.
const supportedTimezones = [
  'Africa/Algiers',
  'Africa/Casablanca',
  'Africa/Tunis',
  'Europe/Paris',
  'Europe/London',
  'America/New_York',
  'America/Los_Angeles',
  'Asia/Dubai',
];

const defaultTimezone = 'Africa/Algiers';

const timezoneKey = 'setting_timezone';
const notificationsKey = 'setting_notifications';

/// User's chosen timezone. Single source of truth: the voice agent and the
/// save service both read this instead of hardcoding a zone.
class TimezoneNotifier extends Notifier<String> {
  @override
  String build() {
    final stored = ref.read(sharedPreferencesProvider).getString(timezoneKey);
    if (stored == null) return defaultTimezone;
    // Older builds saved the typo 'Afrique/...'; migrate it silently.
    final fixed = stored.startsWith('Afrique/')
        ? stored.replaceFirst('Afrique/', 'Africa/')
        : stored;
    return supportedTimezones.contains(fixed) ? fixed : defaultTimezone;
  }

  Future<void> set(String tz) async {
    await ref.read(sharedPreferencesProvider).setString(timezoneKey, tz);
    state = tz;
  }
}

final timezoneProvider =
    NotifierProvider<TimezoneNotifier, String>(TimezoneNotifier.new);

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(notificationsKey) ?? true;

  Future<void> set(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(notificationsKey, value);
    state = value;
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, bool>(NotificationsNotifier.new);
