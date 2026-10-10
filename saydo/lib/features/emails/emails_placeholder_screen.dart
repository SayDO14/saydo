import 'package:flutter/material.dart';

import '../../core/widgets.dart';

class EmailsPlaceholderScreen extends StatelessWidget {
  const EmailsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emails')),
      body: const EmptyView(
        icon: Icons.mail_outline_rounded,
        message: 'Boîte d\'envoi en cours de préparation...',
      ),
    );
  }
}
