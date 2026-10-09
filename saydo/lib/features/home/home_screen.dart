import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../voice/voice_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(voiceControllerProvider);
    final theme = Theme.of(context);
    final recording = voice.status == VoiceStatus.recording;
    final uploading = voice.status == VoiceStatus.uploading;

    final hint = switch (voice.status) {
      VoiceStatus.idle => 'Tap and speak',
      VoiceStatus.recording => 'Listening... tap to send',
      VoiceStatus.uploading => 'Understanding...',
      VoiceStatus.done => 'Tap to record again',
      VoiceStatus.error => voice.error ?? 'Something went wrong',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('SayDo'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(child: _ResultPreview(voice: voice)),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: voice.status == VoiceStatus.error ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 96,
              height: 96,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: recording ? theme.colorScheme.error : null,
                ),
                onPressed: uploading ? null : () => ref.read(voiceControllerProvider.notifier).toggle(),
                child: uploading
                    ? const CircularProgressIndicator(strokeWidth: 3)
                    : Icon(recording ? Icons.stop_rounded : Icons.mic_rounded, size: 44),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Temporary raw view. The confirmation card (next feature) replaces this.
class _ResultPreview extends StatelessWidget {
  const _ResultPreview({required this.voice});
  final VoiceState voice;

  @override
  Widget build(BuildContext context) {
    final r = voice.result;
    if (r == null) return const SizedBox.shrink();
    final lines = <String>[
      'You said: ${r.transcript}',
      if (r.needsInfo) 'Agent asks: ${r.question}',
      if (r.isProposal) ...[
        'Type: ${r.type}',
        if (r.title != null) 'Title: ${r.title}',
        if (r.date != null) 'Date: ${r.date}',
        if (r.time != null) 'Time: ${r.time}',
        if (r.people.isNotEmpty) 'People: ${r.people.join(', ')}',
        if (r.toName != null) 'To: ${r.toName}',
        if (r.subject != null) 'Subject: ${r.subject}',
        if (r.body != null) 'Body: ${r.body}',
      ],
    ];
    return SingleChildScrollView(child: Text(lines.join('\n\n')));
  }
}
