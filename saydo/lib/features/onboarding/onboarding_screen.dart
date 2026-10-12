import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saydo/l10n/app_localizations.dart';

const _onboardingSeenKey = 'onboarding_seen';

/// Tracks whether the user has completed onboarding.
final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingSeenKey) ?? false;
});

/// Marks onboarding as completed.
Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingSeenKey, true);
}

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bg            = Color(0xFF070818);
const _cardColor     = Color(0xFF0F1230);
const _cardBorder    = Color(0xFF1E2760);
const _accent        = Color(0xFF4E78FF);
const _textPrimary   = Colors.white;
const _textSecondary = Color(0xFF8E9AC5);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await markOnboardingSeen();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
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
                // Top bar: SayDo brand + Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/saydo_logo.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.bubble_chart_rounded,
                              color: _accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'SayDo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPage < 2)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF13193E).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF222C68)),
                          ),
                          child: InkWell(
                            onTap: _finish,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                              child: Text(
                                AppLocalizations.of(context)!.onbSkip,
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 70),
                    ],
                  ),
                ),

                // Slide Carousel
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: const [
                      _SplashSlide(),
                      _WelcomeSlide(),
                      _SmartUnderstandingSlide(),
                    ],
                  ),
                ),

                // Dots indicator
                _PageDots(count: 3, current: _currentPage),
                const SizedBox(height: 28),

                // Next / Get Started Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3861FB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3861FB).withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2 ? AppLocalizations.of(context)!.onbGetStarted : AppLocalizations.of(context)!.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 1: SayDo Brand & Mascot ───────────────────────────────────────────

class _SplashSlide extends StatelessWidget {
  const _SplashSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // AI Voice Assistant Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F173D).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF23367C), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: Color(0xFF4E78FF)),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.onbTag,
                  style: TextStyle(
                    color: Color(0xFF8BA5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3D Robot Mascot + Floating Speech Bubbles
          SizedBox(
            width: 300,
            height: 260,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Standing Robot
                Image.asset(
                  'assets/images/robot_standing.png',
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/robot_card_avatar.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.smart_toy_rounded,
                      size: 90,
                      color: _accent,
                    ),
                  ),
                ),

                // Top Right Speech Bubble: "Rappelle-moi..."
                Positioned(
                  top: 24,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F173D).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF23367C)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, size: 14, color: Color(0xFF4E78FF)),
                        SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.onbBubble,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left Chip: Tâche créée
                Positioned(
                  bottom: 24,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F173D).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF23367C)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.onbTaskCreated,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // Title
          const Text(
            'SayDo',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle / Slogan
          Text(
            AppLocalizations.of(context)!.onbHeadline,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF3861FB),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            AppLocalizations.of(context)!.onbDesc1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8E9AC5),
              height: 1.45,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ─── Slide 2: Welcome & Schedule Hub ──────────────────────────────────────────

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Glassmorphism Hub Card
          Container(
            width: 260,
            height: 260,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Left: Calendar
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: _accent,
                      size: 24,
                    ),
                  ),
                ),

                // Top Right: Bulb / Ideas
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFFBBF24),
                      size: 24,
                    ),
                  ),
                ),

                // Center: Voice Soundwaves
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4E78FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                // Bottom Left: Person / Contacts
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF60A5FA),
                      size: 24,
                    ),
                  ),
                ),

                // Bottom Right: 3D Robot
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/robot_avatar_head.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded,
                          color: _accent,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          Text(
            AppLocalizations.of(context)!.onbWelcome,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)!.onbDesc2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ─── Slide 3: Smart Understanding & Multilingual AI ───────────────────────────

class _SmartUnderstandingSlide extends StatelessWidget {
  const _SmartUnderstandingSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Illustration Showcase Card
          Container(
            width: 260,
            height: 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center Phone / Robot illustration
                Positioned(
                  child: Image.asset(
                    'assets/images/robot_laptop.png',
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.phone_android_rounded,
                      size: 90,
                      color: _accent,
                    ),
                  ),
                ),

                // Top Left: Email chip
                Positioned(
                  top: 8,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mail_outline_rounded, size: 14, color: _accent),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.navEmails,
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right: Language badges
                Positioned(
                  top: 8,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.translate_rounded, size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          '🇩🇿 Darija / 🇫🇷 FR / 🇬🇧 EN',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left: Tasks chip
                Positioned(
                  bottom: 8,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_box_outlined, size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.navTasks,
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Right: Events chip
                Positioned(
                  bottom: 8,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF222B6E)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFFBBF24)),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.onbAgenda,
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          Text(
            AppLocalizations.of(context)!.onbSmart,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 1.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)!.onbDesc3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ─── Animated Page Dots ───────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF4E78FF)],
                  )
                : null,
            color: active ? null : const Color(0xFF1E2760),
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF4E78FF).withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
