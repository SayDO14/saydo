import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'date_format.dart';
import 'preferences.dart';

const languageKey = 'setting_language';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(languageKey) ?? 'fr';
    currentLanguageCode = code;
    return Locale(code);
  }

  Future<void> setLanguage(String code) async {
    await ref.read(sharedPreferencesProvider).setString(languageKey, code);
    currentLanguageCode = code;
    state = Locale(code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
