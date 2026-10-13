import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saydo/l10n/app_localizations.dart';

import '../../core/date_format.dart';
import '../voice/voice_sheet.dart';
import 'email_item.dart';
import 'emails_repository.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bg            = Color(0xFF070818);
const _cardColor     = Color(0xFF0F1230);
const _cardBorder    = Color(0xFF1E2760);
const _accent        = Color(0xFF4E78FF);
const _textPrimary   = Colors.white;
const _textSecondary = Color(0xFF8E9AC5);
const _avatarBg      = Color(0xFF1E2B7A);

enum _EmailFilter { all, received, sent }

class EmailsScreen extends ConsumerStatefulWidget {
  const EmailsScreen({super.key});

  @override
  ConsumerState<EmailsScreen> createState() => _EmailsScreenState();
}

class _EmailsScreenState extends ConsumerState<EmailsScreen> {
  _EmailFilter _filter = _EmailFilter.all;

  @override
  Widget build(BuildContext context) {
    final emailsAsync = ref.watch(emailsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Opacity(
              opacity: 0.50,
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
                // ── Top branding "SayDo" ───────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    'SayDo',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Title Section with Icon Card ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111535),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF222A60),
                            width: 1.1,
                          ),
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFF8E9AC5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.emailsTitle,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.emailsSubtitle,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Filter tabs ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF1E2455), width: 1.1),
                    ),
                    child: Row(
                      children: [
                        _FilterTab(
                          label: AppLocalizations.of(context)!.filterAll,
                          active: _filter == _EmailFilter.all,
                          onTap: () => setState(() => _filter = _EmailFilter.all),
                        ),
                        _FilterTab(
                          label: AppLocalizations.of(context)!.filterReceived,
                          active: _filter == _EmailFilter.received,
                          onTap: () => setState(() => _filter = _EmailFilter.received),
                        ),
                        _FilterTab(
                          label: AppLocalizations.of(context)!.filterSent,
                          active: _filter == _EmailFilter.sent,
                          onTap: () => setState(() => _filter = _EmailFilter.sent),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Emails list ────────────────────────────────────────
                Expanded(
                  child: emailsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _accent),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: _textSecondary, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.loadError('$e'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _textSecondary),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.invalidate(emailsProvider),
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    ),
                    data: (items) {
                      final sourceList = items;

                      final filtered = sourceList.where((email) {
                        switch (_filter) {
                          case _EmailFilter.all:
                            return true;
                          case _EmailFilter.received:
                            return !email.isSent;
                          case _EmailFilter.sent:
                            return email.isSent;
                        }
                      }).toList();

                      return RefreshIndicator(
                        color: _accent,
                        onRefresh: () => ref.refresh(emailsProvider.future),
                        child: filtered.isEmpty
                            ? _EmptyEmailView(onVoice: () => showVoiceAssistant(context, ref))
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final email = filtered[i];
                                  return _EmailCard(
                                    email: email,
                                    onTap: () => _showEmailDetails(context, email),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Floating Voice Button ────────────────────────────────────
          Positioned(
            bottom: 95,
            right: 20,
            child: GestureDetector(
              onTap: () => showVoiceAssistant(context, ref),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3855D6), Color(0xFF1E2F8A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3855D6).withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF4E78FF).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDetails(BuildContext context, EmailItem email) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1230),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: _cardBorder, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3270),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          email.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: email.isSent
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFF4E78FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: email.isSent
                                ? const Color(0xFF10B981)
                                : const Color(0xFF4E78FF),
                          ),
                        ),
                        child: Text(
                          email.isSent
                              ? AppLocalizations.of(context)!.statusSent
                              : AppLocalizations.of(context)!.statusReceived,
                          style: TextStyle(
                            color: email.isSent
                                ? const Color(0xFF10B981)
                                : const Color(0xFF4E78FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.person_outline_rounded,
                    email.toName?.isNotEmpty == true
                        ? '${email.toName} (${email.toEmail})'
                        : email.toEmail,
                  ),
                  _detailRow(
                    Icons.schedule_rounded,
                    email.isSent && email.sentAt != null
                        ? AppLocalizations.of(context)!.sentOn(formatDayLabel(email.sentAt!), formatClock(email.sentAt!))
                        : AppLocalizations.of(context)!.createdOn(formatDayLabel(email.createdAt), formatClock(email.createdAt)),
                  ),
                  const Divider(color: _cardBorder, height: 24),
                  Text(
                    AppLocalizations.of(context)!.messageLabel,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07091B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Text(
                      email.body,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter tab ────────────────────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF4E78FF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Email Card ────────────────────────────────────────────────────────────────
class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email, required this.onTap});

  final EmailItem email;
  final VoidCallback onTap;

  String _formatDisplayTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final senderName = email.toName?.isNotEmpty == true
        ? email.toName!
        : (email.toEmail.contains('@') ? email.toEmail.split('@').first : email.toEmail);

    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'M';
    final timeStr = email.isSent && email.sentAt != null
        ? _formatDisplayTime(email.sentAt!)
        : _formatDisplayTime(email.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Circle Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _avatarBg,
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

            // Middle Column (Sender, Subject, Body snippet)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.body,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right Column (Time, Status icon, Chevron)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      email.isSent
                          ? Icons.near_me_outlined
                          : Icons.mail_outline_rounded,
                      color: _textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyEmailView extends StatelessWidget {
  const _EmptyEmailView({required this.onVoice});
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onVoice,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF111535),
                border: Border.all(color: const Color(0xFF222A60), width: 1.2),
              ),
              child: const Icon(Icons.mail_outline_rounded, color: _accent, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.emailsEmpty,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onVoice,
            child: Text(
              AppLocalizations.of(context)!.emailsTapToCreate,
              style: const TextStyle(
                color: _accent,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import '../../core/date_format.dart';
import '../../core/widgets.dart';
import 'contact_item.dart';
import 'emails_repository.dart';

class EmailsScreen extends ConsumerWidget {
  const EmailsScreen({super.key});

  Future<void> _retry(WidgetRef ref, EmailItem email) async {
    try {
      await ref.read(emailsRepositoryProvider).retry(email.id);
      ref.invalidate(emailsProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emails = ref.watch(emailsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emails')),
      body: emails.when(
        loading: () => const _LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Could not load your emails.\n$e',
          onRetry: () => ref.invalidate(emailsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(emailsProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.email_outlined,
                  message: 'No emails yet.\nTap the mic and dictate one.',
                )
              : _EmailsList(
                  items: items,
                  onRetry: (e) => _retry(ref, e),
                ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading emails...'),
        ],
      ),
    );
  }
}

class _EmailsList extends StatelessWidget {
  const _EmailsList({required this.items, required this.onRetry});

  final List<EmailItem> items;
  final void Function(EmailItem) onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group by status: failed first, then approved, then sent
    final failed = items.where((e) => e.isFailed).toList();
    final approved = items.where((e) => e.isApproved).toList();
    final sent = items.where((e) => e.isSent).toList();

    final sections = <String, List<EmailItem>>{
      if (failed.isNotEmpty) 'Failed': failed,
      if (approved.isNotEmpty) 'Waiting to send': approved,
      if (sent.isNotEmpty) 'Sent': sent,
    };

    final rows = <Object>[];
    sections.forEach((title, emails) {
      rows.add(title);
      rows.addAll(emails);
    });

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              row.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: row == 'Failed' ? theme.colorScheme.error : theme.colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          );
        }
        final email = row as EmailItem;
        return _EmailTile(email: email, onRetry: () => onRetry(email));
      },
    );
  }
}

class _EmailTile extends StatelessWidget {
  const _EmailTile({required this.email, required this.onRetry});

  final EmailItem email;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    switch (email.status) {
      case 'failed':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error_outline;
      case 'sent':
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle_outline;
      default:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.schedule_outlined;
    }

    final subtitle = email.createdAt != null
        ? '${formatDayLabel(email.createdAt!)} · ${formatClock(email.createdAt!)}'
        : null;

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text(email.subject),
      subtitle: Text('${email.recipientLabel}\n${email.statusLabel}${subtitle != null ? ' · $subtitle' : ''}'),
      isThreeLine: true,
      trailing: email.isFailed
          ? IconButton(
              tooltip: 'Retry',
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
            )
          : null,
      onTap: () => _showDetails(context),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email.subject, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'To: ${email.recipientLabel}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(email.body),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatusChip(label: email.statusLabel),
                    if (email.sentAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Sent ${formatDayLabel(email.sentAt!)} · ${formatClock(email.sentAt!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                if (email.transcript != null && email.transcript!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    '"${email.transcript}"',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = label == 'Failed'
        ? theme.colorScheme.error
        : label == 'Sent'
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
