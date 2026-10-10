import 'package:flutter/material.dart';

import '../../core/widgets.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: const EmptyView(
        icon: Icons.settings_outlined,
        message: 'Paramètres du compte et préférences...',
      ),
    );
  }
}
