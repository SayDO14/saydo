import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  /// Opens the browser for Google sign-in. The session arrives later through
  /// [authChanges] when the OS hands the deep link back to the app.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
      scopes: 'openid email profile https://www.googleapis.com/auth/calendar',
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
