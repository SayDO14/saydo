import 'package:flutter/material.dart';

import '../../core/widgets.dart';
import 'package:saydo/l10n/app_localizations.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.navSettings)),
      body: EmptyView(
        icon: Icons.settings_outlined,
        message: AppLocalizations.of(context)!.placeholderMessage,
      ),
    );
  }
}
