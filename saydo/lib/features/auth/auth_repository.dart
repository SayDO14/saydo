import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../calendar/google_token_store.dart';

class AuthRepository {
  AuthRepository(this._client) {
    // Supabase exposes the Google token only on the sign-in event: keep it.
    _sub = _client.auth.onAuthStateChange.listen((state) {
      final token = state.session?.providerToken;
      if (token != null && token.isNotEmpty) {
        GoogleTokenStore.save(token);
      }
      if (state.event == AuthChangeEvent.signedOut) {
        GoogleTokenStore.clear();
      }
    });
  }

  final SupabaseClient _client;
  // ignore: unused_field
  late final StreamSubscription<AuthState> _sub;

  /// Asked at sign-in so events and tasks are created in the USER's own
  /// Google Calendar / Google Tasks (not in the n8n owner's account).
  static const calendarScope = 'https://www.googleapis.com/auth/calendar.events';
  static const tasksScope = 'https://www.googleapis.com/auth/tasks';

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  /// Opens the browser for Google sign-in. The session arrives later through
  /// [authChanges] when the OS hands the deep link back to the app.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirect,
      scopes: '$calendarScope $tasksScope',
      queryParams: const {'access_type': 'offline', 'prompt': 'consent'},
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await GoogleTokenStore.clear();
    await _client.auth.signOut();
  }
}
