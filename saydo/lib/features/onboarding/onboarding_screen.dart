import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

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
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _SplashPage(),
                  _WelcomePage(),
                  _SmartUnderstandingPage(),
                ],
              ),
            ),
            _PageDots(count: 3, current: _currentPage),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Splash ──────────────────────────────────────────────────────────

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SayDo',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Say it. Do it.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 2: Welcome ─────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          // Illustration placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const _WelcomeIllustration(),
          ),
          const Spacer(),
          const Text(
            'WELCOME',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Just say it out loud,\nSayDo manages your schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Person icon
        Positioned(
          left: 20,
          bottom: 30,
          child: Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.primaryLight.withValues(alpha: 0.8),
          ),
        ),
        // Robot icon
        Positioned(
          right: 20,
          bottom: 30,
          child: Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.9),
          ),
        ),
        // Calendar
        Positioned(
          top: 20,
          left: 30,
          child: Icon(
            Icons.calendar_today_outlined,
            size: 32,
            color: AppColors.primaryLight.withValues(alpha: 0.7),
          ),
        ),
        // Lamp
        Positioned(
          top: 20,
          right: 30,
          child: Icon(
            Icons.lightbulb_outline,
            size: 32,
            color: AppColors.warning.withValues(alpha: 0.7),
          ),
        ),
        // Sound waves
        Positioned(
          top: 60,
          child: Icon(
            Icons.graphic_eq,
            size: 40,
            color: AppColors.primaryLight.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ─── Page 3: Smart Understanding ─────────────────────────────────────────────

class _SmartUnderstandingPage extends StatelessWidget {
  const _SmartUnderstandingPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          // Illustration placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const _SmartUnderstandingIllustration(),
          ),
          const Spacer(),
          const Text(
            'SMART\nUNDERSTANDING',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Mix Darija, French, and English naturally.\nSayDo extracts dates, tasks, and people effortlessly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SmartUnderstandingIllustration extends StatelessWidget {
  const _SmartUnderstandingIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Phone
        Icon(
          Icons.phone_android,
          size: 100,
          color: AppColors.primaryLight.withValues(alpha: 0.8),
        ),
        // Gears
        Positioned(
          top: 20,
          right: 20,
          child: Icon(
            Icons.settings_outlined,
            size: 36,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
        ),
        Positioned(
          top: 50,
          right: 50,
          child: Icon(
            Icons.settings_outlined,
            size: 24,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
        // Robot
        Positioned(
          bottom: 20,
          right: 20,
          child: Icon(
            Icons.smart_toy_outlined,
            size: 50,
            color: AppColors.primary.withValues(alpha: 0.9),
          ),
        ),
        // Email
        Positioned(
          bottom: 30,
          left: 20,
          child: Icon(
            Icons.email_outlined,
            size: 32,
            color: AppColors.primaryLight.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ─── Page Dots ───────────────────────────────────────────────────────────────

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
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
