import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'contact_sheet.dart';
import 'contacts_repository.dart';
import 'package:saydo/l10n/app_localizations.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF222A60), width: 1.2),
        ),
        title: Text(
          AppLocalizations.of(context)!.contactsDeleteTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.contactsDeleteBody(c.name, c.email),
          style: const TextStyle(color: Color(0xFF8E9AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Color(0xFF6B76A0))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(contactsRepositoryProvider).delete(c.id);
      ref.invalidate(contactsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070818),
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111535),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF222A60),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!.contactsTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Contact list ─────────────────────────────────────
                Expanded(
                  child: contacts.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4E78FF)),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFF6B76A0), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.contactsLoadError('$e'),
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: Color(0xFF8E9AC5)),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () =>
                                ref.invalidate(contactsProvider),
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF111535),
                                    border: Border.all(
                                        color: const Color(0xFF222A60),
                                        width: 1.2),
                                  ),
                                  child: const Icon(
                                      Icons.contacts_outlined,
                                      color: Color(0xFF4E78FF),
                                      size: 34),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.contactsEmpty,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.contactsEmptyHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF6B76A0),
                                      fontSize: 13,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final c = items[i];
                              final initial = c.name.isEmpty
                                  ? '?'
                                  : c.name[0].toUpperCase();
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () =>
                                      showContactSheet(context, contact: c),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF101332),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF1E2760),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatar circle with initial
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF1D2B7A),
                                            border: Border.all(
                                              color: const Color(0xFF2E3E9A),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // Name + email
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                c.email,
                                                style: const TextStyle(
                                                  color: Color(0xFF6B76A0),
                                                  fontSize: 12,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Delete button
                                        GestureDetector(
                                          onTap: () =>
                                              _delete(context, ref, c),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color(0xFF1A1040),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    const Color(0xFF2A1A60),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Color(0xFF8080C0),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── FAB: Add contact ────────────────────────────────────────
          Positioned(
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () => showContactSheet(context),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A3AD0), Color(0xFF192080)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF4E78FF).withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
