import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saydo/l10n/app_localizations.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _client = Supabase.instance.client;

  void _showChangePasswordDialog() {
    final pwdCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.securityChangePassword,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.securityNewPassword,
                  style: TextStyle(color: Color(0xFF8E9AC5), fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: pwdCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.securityMin6,
                    hintStyle: const TextStyle(color: Color(0xFF4B5380)),
                    filled: true,
                    fillColor: const Color(0xFF0B0D22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E244E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E244E)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)!.fieldConfirmPassword,
                  style: TextStyle(color: Color(0xFF8E9AC5), fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.securityRepeat,
                    hintStyle: const TextStyle(color: Color(0xFF4B5380)),
                    filled: true,
                    fillColor: const Color(0xFF0B0D22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E244E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E244E)),
                    ),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorText!,
                    style: const TextStyle(color: Color(0xFFE57373), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final p1 = pwdCtrl.text.trim();
                          final p2 = confirmCtrl.text.trim();
                          if (p1.length < 6) {
                            setModalState(() => errorText = AppLocalizations.of(context)!.passwordTooShort);
                            return;
                          }
                          if (p1 != p2) {
                            setModalState(() => errorText = AppLocalizations.of(context)!.passwordsMismatch);
                            return;
                          }
                          setModalState(() {
                            saving = true;
                            errorText = null;
                          });

                          try {
                            await _client.auth.updateUser(
                              UserAttributes(password: p1),
                            );
                            if (mounted && ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.securityPasswordUpdated),
                                  backgroundColor: Color(0xFF13193E),
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() {
                              saving = false;
                              errorText = AppLocalizations.of(context)!.errorWithMessage('$e');
                            });
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2853DE),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          AppLocalizations.of(context)!.securityUpdatePassword,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _switchAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.securitySwitchTitle, style: TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.securitySwitchBody,
          style: TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2853DE)),
            child: Text(AppLocalizations.of(context)!.continueLabel),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await _client.auth.signOut();
      if (mounted) context.go('/onboarding');
    }
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.securityLogoutTitle, style: TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.securityLogoutBody,
          style: TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE57373)),
            child: Text(AppLocalizations.of(context)!.logoutAction),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await _client.auth.signOut();
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    final email = user?.email ?? 'hibayes814@gmail.com';

    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      body: Stack(
        children: [
          // Background mesh wave asset at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/bg_wave.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Header with back button & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF141738),
                          border: Border.all(
                            color: const Color(0xFF2A3268),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SayDo',
                          style: TextStyle(
                            color: Color(0xFF4E78FF),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.settingsAccountSecurity,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Card 1: Changer de compte
                _SecurityCard(
                  icon: Icons.person_outline_rounded,
                  title: AppLocalizations.of(context)!.securitySwitchAccount,
                  subtitle:
                      AppLocalizations.of(context)!.securitySwitchSub,
                  onTap: _switchAccount,
                ),
                const SizedBox(height: 14),

                // Card 2: Changer le mot de passe
                _SecurityCard(
                  icon: Icons.lock_outline_rounded,
                  title: AppLocalizations.of(context)!.securityChangePassword,
                  subtitle:
                      AppLocalizations.of(context)!.securityChangePasswordSub,
                  onTap: _showChangePasswordDialog,
                ),
                const SizedBox(height: 14),

                // Card 3: E-mail (read-only explanation card matching Figma)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121533),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF222754), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.fieldEmail,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Color(0xFF4E78FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)!.securityEmailLocked,
                              style: TextStyle(
                                color: Color(0xFF7E89B5),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Card 4: Se déconnecter button
                InkWell(
                  onTap: _signOut,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF121533),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF222754), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.securityLogoutButton,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF121533),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF222754), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7E89B5),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6874A6),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
