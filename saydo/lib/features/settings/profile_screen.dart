import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController(
    text: 'Étudiante en informatique\nPassionnée par la technologie 💻',
  );

  bool _loading = true;
  bool _saving = false;
  bool _showSuccessNotif = false;
  String _successMsg = 'Le nom a été modifié avec succès.';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;

    String name = prefs.getString('user_display_name') ?? '';
    String bio = prefs.getString('user_bio') ??
        'Étudiante en informatique\nPassionnée par la technologie 💻';

    if (name.isEmpty && user != null) {
      name = user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          '';
      if (name.isEmpty) {
        try {
          final res = await Supabase.instance.client
              .from('profiles')
              .select('display_name, bio')
              .eq('id', user.id)
              .maybeSingle();
          if (res != null) {
            if (res['display_name'] != null) name = res['display_name'] as String;
            if (res['bio'] != null) bio = res['bio'] as String;
          }
        } catch (_) {}
      }
      if (name.isEmpty && user.email != null) {
        name = user.email!.split('@').first;
      }
    }

    if (mounted) {
      setState(() {
        _nameCtrl.text = name;
        _bioCtrl.text = bio;
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    setState(() => _saving = true);

    final newName = _nameCtrl.text.trim();
    final newBio = _bioCtrl.text.trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', newName);
      await prefs.setString('user_bio', newBio);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {
            'full_name': newName,
            'bio': newBio,
          }),
        );

        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': user.id,
            'display_name': newName,
            'bio': newBio,
          });
        } catch (_) {
          try {
            await Supabase.instance.client.from('profiles').upsert({
              'id': user.id,
              'display_name': newName,
            });
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _saving = false;
          _showSuccessNotif = true;
          _successMsg = 'Le nom a été modifié avec succès.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: const Color(0xFFE57373),
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101435),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Photo de profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1D2658),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF00E5FF), size: 22),
                ),
                title: const Text('Avatar Robot SayDo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Actuellement utilisé', style: TextStyle(color: Color(0xFF7E89B5), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _showSuccessNotif = true;
                    _successMsg = 'Avatar SayDo sélectionné avec succès.';
                  });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1D2658),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 22),
                ),
                title: const Text('Choisir dans la galerie', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Importer une image personnelle', style: TextStyle(color: Color(0xFF7E89B5), fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Galerie photo bientôt disponible'),
                      backgroundColor: Color(0xFF1B224E),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bioLength = _bioCtrl.text.length;

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
              opacity: 0.40,
              child: Image.asset(
                'assets/images/bg_wave.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4E78FF)),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      // Header with back button & SayDo / Profil & Robot unclipped illustration
                      SizedBox(
                        height: 95,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Back button & Title
                            Positioned(
                              left: 0,
                              top: 6,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF121533),
                                        border: Border.all(
                                          color: const Color(0xFF242A58),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'SayDo',
                                        style: TextStyle(
                                          color: Color(0xFF4E78FF),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Profil',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 3D Robot with laptop sitting at top right (fully framed)
                            Positioned(
                              right: 4,
                              top: -4,
                              child: SizedBox(
                                width: 95,
                                height: 95,
                                child: Image.asset(
                                  'assets/images/robot_laptop.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const SizedBox(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card 1: Avatar + Nom (Unified iOS glassmorphic card)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101332),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF222858),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Perfectly centered circular robot avatar with cyan glow & camera badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00E5FF),
                                      width: 2.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x5500E5FF),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: const Color(0xFF0A0C1E),
                                      child: Image.asset(
                                        'assets/images/robot_avatar_head.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.asset(
                                          'assets/images/robot_standing.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: GestureDetector(
                                    onTap: _showPhotoOptions,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF121533),
                                        border: Border.all(
                                          color: const Color(0xFF2A3468),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Nom input (Harmonious unified style matching card)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nom',
                                    style: TextStyle(
                                      color: Color(0xFF8E9AC5),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B0D22),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E244E),
                                        width: 1.1,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _nameCtrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Votre nom',
                                        hintStyle: TextStyle(color: Color(0xFF4B5380)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card 2: Bio (Unified single glass container, NO weird double background)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101332),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF222858),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF8E9AC5),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Bio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Textarea container that blends smoothly with the card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0D22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF1E244E),
                                  width: 1.1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextField(
                                    controller: _bioCtrl,
                                    maxLines: 3,
                                    maxLength: 150,
                                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                                        null,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Décrivez-vous brièvement...',
                                      hintStyle: TextStyle(color: Color(0xFF4B5380)),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$bioLength/150',
                                    style: const TextStyle(
                                      color: Color(0xFF5E6796),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card 3: Photo de profil
                      InkWell(
                        onTap: _showPhotoOptions,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101332),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF222858),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Photo de profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF6874A6),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Button: Mettre à jour les informations
                      // Refined dark indigo / sleek glass button matching the Figma mock
                      FilledButton(
                        onPressed: _saving ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF223577),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFF334B96),
                              width: 1.2,
                            ),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Mettre à jour les informations',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Success notification card (exact Figma card design)
                      if (_showSuccessNotif)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11173A),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF242E64),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF202A54),
                                  border: Border.all(
                                    color: const Color(0xFF303C74),
                                    width: 1.1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Profil mis à jour !',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _successMsg,
                                      style: const TextStyle(
                                        color: Color(0xFF8E9AC5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
