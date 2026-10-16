import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Creates events in the user's own Google Calendar.
class GoogleCalendarService {
  GoogleCalendarService(this._client);
  final SupabaseClient _client;

  AuthClient? _authClient;

  /// Get the user's Google OAuth token from Supabase.
  Future<AuthClient?> _getAuthClient() async {
    if (_authClient != null) {
      return _authClient!;
    }

    final session = _client.auth.currentSession;
    if (session == null) return null;

    final accessToken = session.accessToken;
    if (accessToken == null) return null;

    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().add(const Duration(hours: 1)),
      ),
      session.refreshToken,
      [CalendarApi.calendarScope],
    );

    _authClient = authenticatedClient(http.Client(), credentials);
    return _authClient;
  }

  /// Create an event in the user's Google Calendar.
  /// Returns the Google Calendar event ID if successful.
  Future<String?> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    List<String> people = const [],
  }) async {
    try {
      final authClient = await _getAuthClient();
      if (authClient == null) {
        debugPrint('[GoogleCalendar] No auth client — user not signed in with Google');
        return null;
      }

      final calendar = CalendarApi(authClient);

      final event = Event()
        ..summary = title
        ..description = description ?? '';

      final startDateTime = EventDateTime()..dateTime = start;
      final endDateTime = EventDateTime()..dateTime = end;

      event.start = startDateTime;
      event.end = endDateTime;

      if (people.isNotEmpty) {
        event.attendees = people
            .map((name) => EventAttendee()..displayName = name)
            .toList();
      }

      final created = await calendar.events.insert(event, 'primary');
      debugPrint('[GoogleCalendar] Created event: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[GoogleCalendar] Failed to create event: $e');
      return null;
    }
  }
}
