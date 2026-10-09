/// Values injected at build time, never committed:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Python agent. Android emulator reaches your PC at 10.0.2.2; a real phone
  /// needs your PC's LAN IP (e.g. http://192.168.1.20:8000).
  static const agentUrl =
      String.fromEnvironment('AGENT_URL', defaultValue: 'http://10.0.2.2:8000');

  /// Must match the Android intent-filter / iOS URL scheme and be listed in
  /// Supabase > Authentication > URL Configuration > Redirect URLs.
  static const authRedirect = 'io.supabase.saydo://login-callback';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
