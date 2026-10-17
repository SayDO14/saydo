import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'google_token_store.dart';

/// Creates events in the user's own Google Calendar.
class GoogleCalendarService {
  GoogleCalendarService(this._client);
  // ignore: unused_field
  final SupabaseClient _client;

  /// Creates the event in the signed-in user's primary calendar.
  /// Returns the Google event id, or null if it couldn't be synced
  /// (no/expired Google token, scope not granted, network...).
  Future<String?> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    List<String> people = const [],
  }) async {
    http.Client? base;
    try {
      // IMPORTANT: this must be the *Google* token, not Supabase's JWT
      // (session.accessToken) — Google rejects the latter with 401.
      final saved = await GoogleTokenStore.read();
      if (saved == null) {
        debugPrint('[GoogleCalendar] No valid Google token — user must sign in again');
        return null;
      }

      base = http.Client();
      final authClient = authenticatedClient(
        base,
        AccessCredentials(
          AccessToken('Bearer', saved.token, saved.expiry.toUtc()),
          null,
          [CalendarApi.calendarEventsScope],
        ),
      );

      // Attendees are NOT added: Google requires a real email for each one
      // and rejects the whole event otherwise. Names go in the description.
      final event = Event()
        ..summary = title
        ..description = description ?? ''
        ..start = (EventDateTime()..dateTime = start.toUtc())
        ..end = (EventDateTime()..dateTime = end.toUtc());

      final created = await CalendarApi(authClient).events.insert(event, 'primary');
      debugPrint('[GoogleCalendar] Created event: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[GoogleCalendar] Failed to create event: $e');
      return null;
    } finally {
      base?.close();
    }
  }
}
