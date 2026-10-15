import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../onboarding/onboarding_screen.dart';
import 'auth_errors.dart';
import 'auth_providers.dart';
import 'package:saydo/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool _isValidEmail(String v) => _emailRegex.hasMatch(v);

  /// One consistent, readable message style for errors and confirmations.
  void _showMessage(String text, {bool error = true}) {
    if (!mounted) return;
    final accent =
        error ? const Color(0xFFFF6B6B) : const Color(0xFF34D399);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withValues(alpha: 0.5)),
          ),
          backgroundColor:
              error ? const Color(0xFF2A1218) : const Color(0xFF0E2A22),
          content: Row(
            children: [
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: accent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _handleLogin() async {
    final l = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(l.loginFillFields);
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessage(l.authInvalidEmail);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref.read(authRepositoryProvider).signInWithPassword(
            email: email,
            password: password,
          );
      await markOnboardingSeen();
      if (!mounted) return;
      if (res.session != null) {
        context.go('/');
      }
    } catch (e) {
      _showMessage(friendlyAuthError(l, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSignUp() async {
    final l = AppLocalizations.of(context)!;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(l.signupFillFields);
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessage(l.authInvalidEmail);
      return;
    }
    if (password.length < 6) {
      _showMessage(l.passwordTooShort);
      return;
    }
    if (password != confirmPassword) {
      _showMessage(l.passwordsMismatch);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            fullName: fullName,
          );

      // With email confirmation on, Supabase answers an already-used email
      // with no error and an empty identities list.
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        _showMessage(l.authErrUserExists);
        return;
      }

      await markOnboardingSeen();
      if (!mounted) return;
      if (res.session != null) {
        // Signed in immediately -> go straight into the app.
        context.go('/');
      } else {
        _showMessage(l.authConfirmEmailSent, error: false);
        setState(() => _isSignUp = false);
      }
    } catch (e) {
      _showMessage(friendlyAuthError(l, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSocial(Future<void> Function() signIn) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await markOnboardingSeen();
      await signIn();
    } catch (e) {
      _showMessage(friendlyAuthError(l, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() =>
      _handleSocial(ref.read(authRepositoryProvider).signInWithGoogle);

  Future<void> _showForgotPasswordDialog() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _emailController.text.trim());

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13172B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l.forgotPasswordTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.forgotPasswordHint,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l.fieldEmail,
                hintStyle: const TextStyle(color: Color(0xFF8E9BB5)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.forgotPasswordSend),
          ),
        ],
      ),
    );

    if (email == null) return; // dismissed
    if (!_isValidEmail(email)) {
      _showMessage(l.authInvalidEmail);
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      // Same message whether or not the account exists (no account probing).
      _showMessage(l.forgotPasswordSent, error: false);
    } catch (e) {
      _showMessage(friendlyAuthError(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF070A18),
      body: Stack(
        children: [
          // 1. Digital wave background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_wave.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Subtle dark overlay gradient for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF070A18).withValues(alpha: 0.35),
                    const Color(0xFF070A18).withValues(alpha: 0.8),
                    const Color(0xFF070A18),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Ambient neon glow blobs
          Positioned(
            top: -50,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                    blurRadius: 90,
                    spreadRadius: 25,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          // 4. Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SayDo Official Logo (without background)
                  Center(
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 3,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/images/saydo_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.smart_toy_rounded,
                            size: 64,
                            color: Color(0xFF4C7DFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isSignUp
                          ? AppLocalizations.of(context)!.loginSubtitleSignup
                          : AppLocalizations.of(context)!.loginSubtitleLogin,
                      key: ValueKey(_isSignUp),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Switch between Login and Sign Up
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isSignUp
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildLoginSection(),
                    secondChild: _buildSignUpSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. LOGIN SECTION (Robot + Glass Card + White G)
  // ==========================================
  Widget _buildLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3D Robot Illustration with cyan glow underneath
        Center(
          child: SizedBox(
            height: 195,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 130,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/robot_standing.png',
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Glassmorphism Card Container
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFF13172B).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tab Switcher (Login / Sign up)
                  _buildTabSwitcher(),

                  const SizedBox(height: 20),

                  // Email Input (Single Uniform Glass Field)
                  _buildGlassField(
                    controller: _emailController,
                    hintText: AppLocalizations.of(context)!.fieldEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // Password Input (Single Uniform Glass Field)
                  _buildGlassField(
                    controller: _passwordController,
                    hintText: AppLocalizations.of(context)!.fieldPassword,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF8E9BB5),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  // Forgot password
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 2),
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: const TextStyle(
                            color: Color(0xFF7AA2FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Primary Button (Sign In)
                  _buildPrimaryButton(
                    label: AppLocalizations.of(context)!.signIn,
                    onTap: _handleLogin,
                  ),

                  const SizedBox(height: 20),

                  // Divider "—— Or ——"
                  _buildOrDivider(text: AppLocalizations.of(context)!.dividerOr),

                  const SizedBox(height: 18),

                  // Google sign-in button (squircle, pure white "G")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlassSquircleButton(
                        onTap: _handleGoogleSignIn,
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. SIGN UP SECTION (Single Glass Fields + Provided Google Logo)
  // ==========================================
  Widget _buildSignUpSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF13172B).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab Switcher (Login / Sign up)
              _buildTabSwitcher(),

              const SizedBox(height: 20),

              // Full Name Label & Single Glass Field
              _buildFieldLabel(AppLocalizations.of(context)!.fieldFullName),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _fullNameController,
                builder: (context, value, _) {
                  return _buildGlassField(
                    controller: _fullNameController,
                    hintText: AppLocalizations.of(context)!.fieldFullName,
                    suffixIcon: value.text.trim().isNotEmpty
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          )
                        : null,
                  );
                },
              ),

              const SizedBox(height: 14),

              // Email Label & Single Glass Field
              _buildFieldLabel(AppLocalizations.of(context)!.fieldEmail),
              const SizedBox(height: 8),
              _buildGlassField(
                controller: _emailController,
                hintText: AppLocalizations.of(context)!.fieldEmail,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              // Password Label & Single Glass Field
              _buildFieldLabel(AppLocalizations.of(context)!.fieldPassword),
              const SizedBox(height: 8),
              _buildGlassField(
                controller: _passwordController,
                hintText: AppLocalizations.of(context)!.fieldPassword,
                obscureText: _obscurePassword,
              ),

              const SizedBox(height: 14),

              // Confirm Password Label & Single Glass Field
              _buildFieldLabel(AppLocalizations.of(context)!.fieldConfirmPassword),
              const SizedBox(height: 8),
              _buildGlassField(
                controller: _confirmPasswordController,
                hintText: AppLocalizations.of(context)!.fieldConfirmPassword,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF8E9BB5),
                    size: 20,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),

              const SizedBox(height: 22),

              // Primary Button: Create account ->
              _buildPrimaryButton(
                label: AppLocalizations.of(context)!.createAccountArrow,
                onTap: _handleSignUp,
              ),

              const SizedBox(height: 20),

              // Divider "—— OR ——"
              _buildOrDivider(text: AppLocalizations.of(context)!.dividerOr),

              const SizedBox(height: 18),

              // White Google Pill Button using the exact provided google_logo asset
              _buildGooglePillButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SHARED DESIGN SYSTEM WIDGETS
  // ==========================================

  Widget _buildTabSwitcher() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: AppLocalizations.of(context)!.loginTab,
              selected: !_isSignUp,
              onTap: () => setState(() => _isSignUp = false),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: AppLocalizations.of(context)!.signUpTab,
              selected: _isSignUp,
              onTap: () => setState(() => _isSignUp = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCBD5E1),
      ),
    );
  }

  /// Single 100% uniform glass field: No inner box, no color split, perfectly smooth glass
  Widget _buildGlassField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2238).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF8E9BB5),
                  fontSize: 14.5,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            suffixIcon,
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : onTap,
          borderRadius: BorderRadius.circular(26),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider({required String text}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8E9BB5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  /// Glass Squircle Button (exactement comme 3ème capture : verre sombre + icône blanche)
  Widget _buildGlassSquircleButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: child),
        ),
      ),
    );
  }

  /// White Google Pill Button using the user-uploaded google_logo.png asset
  Widget _buildGooglePillButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _loading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.continueWithGoogle,
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F111E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF8E9BB5),
          ),
        ),
      ),
    );
  }
}