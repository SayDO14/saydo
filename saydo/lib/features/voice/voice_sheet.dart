import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../confirm/proposal_sheet.dart';
import '../events/events_repository.dart';
import '../tasks/tasks_repository.dart';
import 'parse_result.dart';
import 'voice_controller.dart';

Future<void> showVoiceAssistant(BuildContext context, WidgetRef ref) async {
  ref.read(voiceControllerProvider.notifier).reset();

  final result = await showModalBottomSheet<ParseResult?>( 
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => const _VoiceSheetContent(),
  );

  if (result != null && result.isProposal && context.mounted) {
    final outcome = await showModalBottomSheet<ProposalOutcome>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => ProposalSheet(result: result),
    );

    ref.read(voiceControllerProvider.notifier).reset();
    if (outcome == ProposalOutcome.saved) {
      ref.invalidate(eventsProvider);
      ref.invalidate(tasksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Enregistré avec succès ! 🎉'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _VoiceSheetContent extends ConsumerStatefulWidget {
  const _VoiceSheetContent();

  @override
  ConsumerState<_VoiceSheetContent> createState() => _VoiceSheetContentState();
}

class _VoiceSheetContentState extends ConsumerState<_VoiceSheetContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(voiceControllerProvider);
    final recording = voice.status == VoiceStatus.recording;
    final uploading = voice.status == VoiceStatus.uploading;

    if (recording && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat();
    } else if (!recording && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }

    ref.listen(voiceControllerProvider, (prev, next) {
      final result = next.result;
      if (next.status == VoiceStatus.done &&
          prev?.status != VoiceStatus.done &&
          result != null &&
          result.isProposal) {
        if (mounted) Navigator.of(context).pop(result);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C102C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFF1E2860), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3678),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),

            // Top row with Robot and Close button
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    'assets/images/robot_avatar_head.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/robot_standing.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.smart_toy_rounded,
                        color: Color(0xFF4E78FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SayDo Vocal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Créez une tâche ou un rendez-vous',
                        style: TextStyle(
                          color: Color(0xFF8E9AC5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9AC5)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Animated Mic Center
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (recording)
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return Container(
                            width: 100 + (_pulseCtrl.value * 55),
                            height: 100 + (_pulseCtrl.value * 55),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4E78FF)
                                    .withValues(alpha: 1.0 - _pulseCtrl.value),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                    // Mic Button
                    GestureDetector(
                      onTap: uploading
                          ? null
                          : () => ref.read(voiceControllerProvider.notifier).toggle(),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: recording
                                ? [const Color(0xFF5A72FF), const Color(0xFF2E46DE)]
                                : [const Color(0xFF3861FB), const Color(0xFF1E359E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4E78FF)
                                  .withValues(alpha: recording ? 0.75 : 0.4),
                              blurRadius: recording ? 30 : 16,
                              spreadRadius: recording ? 4 : 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: uploading
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  recording ? Icons.stop_rounded : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Text
            Text(
              voice.status == VoiceStatus.error
                  ? (voice.error ?? 'Une erreur est survenue')
                  : recording
                      ? 'En écoute... Appuyez pour valider'
                      : uploading
                          ? 'Traitement en cours par SayDo...'
                          : voice.status == VoiceStatus.done
                              ? 'Analyse terminée'
                              : 'Appuyez pour parler',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: voice.status == VoiceStatus.error
                    ? const Color(0xFFFF6B8A)
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Hint
            Text(
              recording
                  ? 'Parlez naturellement, SayDo s\'occupe du reste.'
                  : uploading
                      ? 'Reconnaissance vocale & extraction des détails...'
                      : 'Ex: "Rendez-vous demain à 14h avec Sophie" ou "Acheter du lait"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E9AC5),
                fontSize: 13,
              ),
            ),

            if (voice.status == VoiceStatus.error) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref.read(voiceControllerProvider.notifier).toggle(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2866),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
