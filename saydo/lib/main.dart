import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/locale.dart';
import 'package:saydo/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config.dart';
import 'core/preferences.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SayDoApp(),
    ),
  );
}

class SayDoApp extends ConsumerWidget {
  const SayDoApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    

    return MaterialApp.router(
  title: 'SayDo',
  // Every screen is styled for the dark palette, so the app is dark-only
  // until the screens read their colors from the theme.
  theme: buildSayDoTheme(Brightness.dark),
  themeMode: ThemeMode.dark,
  routerConfig: ref.watch(routerProvider),
  locale: ref.watch(localeProvider),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  debugShowCheckedModeBanner: false
  ,
);
  }
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing SUPABASE_URL / SUPABASE_ANON_KEY.\n\n'
              'Run with:\nflutter run --dart-define=SUPABASE_URL=... '
              '--dart-define=SUPABASE_ANON_KEY=...',
            ),
          ),
        ),
      ),
    );
  }
}
