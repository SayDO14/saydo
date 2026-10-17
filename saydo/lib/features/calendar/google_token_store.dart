import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the user's Google access token (Supabase only hands it over once,
/// right after sign-in, as `session.providerToken`).
class GoogleTokenStore {
  static const _tokenKey = 'google_provider_token';
  static const _expiryKey = 'google_provider_token_expiry';

  static Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    // Same token as already saved = an old session restored at app start:
    // keep the original expiry instead of pretending it is fresh.
    if (prefs.getString(_tokenKey) == token) return;
    await prefs.setString(_tokenKey, token);
    // Google access tokens last 1 hour.
    await prefs.setInt(
      _expiryKey,
      DateTime.now().add(const Duration(minutes: 55)).millisecondsSinceEpoch,
    );
  }

  /// Returns a still-valid token, or null (user must sign in again).
  static Future<({String token, DateTime expiry})?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryMs = prefs.getInt(_expiryKey);
    if (token == null || expiryMs == null) return null;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    if (!expiry.isAfter(DateTime.now())) return null;
    return (token: token, expiry: expiry);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
  }
}
