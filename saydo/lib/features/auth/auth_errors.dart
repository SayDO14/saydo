import 'dart:async';

import 'package:saydo/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns any auth-related exception into a short, friendly, localized message.
/// Never shows raw exception text to the user.
String friendlyAuthError(AppLocalizations l, Object error) {
  final text = error.toString().toLowerCase();

  // Network problems (Supabase wraps them in a "retryable fetch" exception).
  if (error is TimeoutException ||
      error.runtimeType.toString().contains('RetryableFetch') ||
      text.contains('socketexception') ||
      text.contains('clientexception') ||
      text.contains('failed host lookup') ||
      text.contains('network')) {
    return l.authErrNetwork;
  }

  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return l.authErrInvalidCredentials;
    }
    if (msg.contains('email not confirmed')) return l.authErrEmailNotConfirmed;
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('already exists')) {
      return l.authErrUserExists;
    }
    if (msg.contains('rate limit') ||
        msg.contains('too many') ||
        error.statusCode == '429') {
      return l.authErrRateLimit;
    }
    if (msg.contains('password') &&
        (msg.contains('weak') ||
            msg.contains('at least') ||
            msg.contains('should be'))) {
      return l.authErrWeakPassword;
    }
    if (msg.contains('provider') &&
        (msg.contains('not enabled') || msg.contains('unsupported'))) {
      return l.authErrProviderDisabled;
    }
  }
  return l.authErrUnknown;
}
