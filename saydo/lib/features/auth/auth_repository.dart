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
    );
  }

  /// Opens the browser for Apple sign-in.
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: AppConfig.authRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Opens the browser for Facebook sign-in.
  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: AppConfig.authRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email, password and optional display name.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null && fullName.isNotEmpty ? {'full_name': fullName} : null,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

