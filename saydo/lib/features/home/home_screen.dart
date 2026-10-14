import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_providers.dart';
import '../voice/voice_controller.dart';
import '../voice/voice_flow.dart';
import 'package:saydo/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulse1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulse2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
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

    ref.listen(voiceControllerProvider, (prev, next) {
      final result = next.result;
      if (next.status != VoiceStatus.done ||
          prev?.status == VoiceStatus.done ||
          result == null ||
          !result.isProposal) {
        return;
      }
      // Home stays mounted inside the IndexedStack. When the capture came
      // from the voice sheet (opened on another tab), that flow already
      // handles the result, so stand down to avoid a second proposal sheet.
      if (ref.read(voiceSheetOpenProvider)) return;
      presentProposal(context, ref, result);
    });

    final recording = voice.status == VoiceStatus.recording;
    final uploading = voice.status == VoiceStatus.uploading;

    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/bg_wave.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/saydo_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.smart_toy_rounded,
                                  color: Color(0xFF4E78FF),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'SayDo',
                            style: TextStyle(
                              color: Color(0xFF4E78FF),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Contacts button
                      _NavIconBtn(
                        icon: Icons.contacts_outlined,
                        onTap: () => context.push('/contacts'),
                      ),
                      const SizedBox(width: 10),
                      // Sign out button
                      _NavIconBtn(
                        icon: Icons.logout_rounded,
                        onTap: () =>
                            ref.read(authRepositoryProvider).signOut(),
                      ),
                    ],
                  ),
                ),

                // ── Robot mascot floating above card ─────────────────
                SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/robot_standing.png',
                          height: 148,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 100,
                            height: 140,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Main voice card ───────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1030),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF1E2760),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4E78FF).withValues(alpha: 0.08),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.homeSpeakTo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'SayDo',
                                  style: TextStyle(
                                    color: Color(0xFF4E78FF),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ── Mic button with pulse rings ──────────────
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring 1
                                if (recording)
                                  AnimatedBuilder(
                                    animation: _pulse1,
                                    builder: (_, __) => _PulseRing(
                                      progress: _pulse1.value,
                                      color: const Color(0xFF4E78FF),
                                      maxRadius: 88,
                                    ),
                                  ),
                                // Pulse ring 2
                                if (recording)
                                  AnimatedBuilder(
                                    animation: _pulse2,
                                    builder: (_, __) => _PulseRing(
                                      progress: _pulse2.value,
                                      color: const Color(0xFF00CFFF),
                                      maxRadius: 80,
                                    ),
                                  ),
                                // Outer glow ring (always visible)
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: recording
                                          ? const Color(0xFF4E78FF)
                                              .withValues(alpha: 0.6)
                                          : const Color(0xFF1E3080),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                // Mid ring
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: recording
                                          ? const Color(0xFF4E78FF)
                                              .withValues(alpha: 0.4)
                                          : const Color(0xFF162060),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                // Mic button core
                                GestureDetector(
                                  onTap: uploading
                                      ? null
                                      : () => ref
                                          .read(voiceControllerProvider
                                              .notifier)
                                          .toggle(),
                                  child: Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: recording
                                            ? [
                                                const Color(0xFF5060FF),
                                                const Color(0xFF2B3DC8),
                                              ]
                                            : [
                                                const Color(0xFF2A3AD0),
                                                const Color(0xFF192080),
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4E78FF)
                                              .withValues(alpha: recording ? 0.65 : 0.35),
                                          blurRadius: recording ? 28 : 16,
                                          spreadRadius: recording ? 4 : 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: uploading
                                          ? const SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Icon(
                                              recording
                                                  ? Icons.stop_rounded
                                                  : Icons.mic_rounded,
                                              color: Colors.white,
                                              size: 38,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Waveform icon
                          if (!recording && !uploading)
                            const Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFF3D5CCF),
                              size: 32,
                            ),
                          if (recording)
                            const Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFF4E78FF),
                              size: 32,
                            ),

                          const SizedBox(height: 16),

                          // Status / hint text
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              voice.status == VoiceStatus.error
                                  ? voiceErrorText(AppLocalizations.of(context)!, voice.error)
                                  : voice.status == VoiceStatus.recording
                                      ? AppLocalizations.of(context)!.homeListening
                                      : voice.status == VoiceStatus.uploading
                                          ? AppLocalizations.of(context)!.homeProcessing
                                          : voice.status == VoiceStatus.done
                                              ? AppLocalizations.of(context)!.homeTapRetry
                                              : AppLocalizations.of(context)!.homeDefaultHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: voice.status == VoiceStatus.error
                                    ? const Color(0xFFFF6B8A)
                                    : const Color(0xFF8E9AC5),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),

                          // Result preview
                          if (voice.result != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                              child: _ResultPreview(voice: voice),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulse ring painter ──────────────────────────────────────────────────────
class _PulseRing extends StatelessWidget {
  const _PulseRing(
      {required this.progress,
      required this.color,
      required this.maxRadius});
  final double progress;
  final Color color;
  final double maxRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(maxRadius * 2, maxRadius * 2),
      painter: _PulseRingPainter(
          progress: progress, color: color, maxRadius: maxRadius),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter(
      {required this.progress, required this.color, required this.maxRadius});
  final double progress;
  final Color color;
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) => old.progress != progress;
}

// ── Nav icon button ───────────────────────────────────────────────────────
class _NavIconBtn extends StatelessWidget {
  const _NavIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF111535),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF222A60),
            width: 1.1,
          ),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

// ── Result preview ────────────────────────────────────────────────────────
class _ResultPreview extends StatelessWidget {
  const _ResultPreview({required this.voice});
  final VoiceState voice;

  @override
  Widget build(BuildContext context) {
    final r = voice.result;
    if (r == null) return const SizedBox.shrink();
    final lines = <String>[
      AppLocalizations.of(context)!.previewSaid('${r.transcript}'),
      if (r.needsInfo) AppLocalizations.of(context)!.previewAgentAsks('${r.question}'),
      if (r.isProposal) ...[
        AppLocalizations.of(context)!.previewType('${r.type}'),
        if (r.title != null) AppLocalizations.of(context)!.previewTitle('${r.title}'),
        if (r.date != null) AppLocalizations.of(context)!.previewDate('${r.date}'),
        if (r.time != null) AppLocalizations.of(context)!.previewTime('${r.time}'),
        if (r.people.isNotEmpty) AppLocalizations.of(context)!.previewPeople(r.people.join(', ')),
      ],
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2760), width: 1),
      ),
      child: Text(
        lines.join('\n'),
        style: const TextStyle(
          color: Color(0xFFB0BCFF),
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
