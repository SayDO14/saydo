import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets.dart';
import 'email_item.dart';
import 'emails_repository.dart';

class EmailsScreen extends ConsumerWidget {
  const EmailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emails = ref.watch(emailsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emails')),
      body: emails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Impossible de charger vos emails.\n$e',
          onRetry: () => ref.invalidate(emailsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(emailsProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.mail_outline_rounded,
                  message: 'Aucun email pour le moment.\nDictez-en un avec le micro.',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) {
                    final email = items[i];
                    return _EmailTile(
                      email: email,
                      onTap: () => _showEmailDetails(context, email),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showEmailDetails(BuildContext context, EmailItem email) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        Widget row(IconData icon, String text, {Color? color}) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: color ?? theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text, style: color != null ? TextStyle(color: color) : null),
                  ),
                ],
              ),
            );

        final recipient = email.toName?.isNotEmpty == true
            ? '${email.toName} <${email.toEmail}>'
            : email.toEmail;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        email.subject,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: email.status),
                  ],
                ),
                const SizedBox(height: 16),
                row(Icons.person_outline, recipient),
                if (email.isSent && email.sentAt != null)
                  row(
                    Icons.schedule,
                    'Envoyé le ${formatDayLabel(email.sentAt!)} · ${formatClock(email.sentAt!)}',
                  )
                else
                  row(
                    Icons.schedule,
                    'Créé le ${formatDayLabel(email.createdAt)} · ${formatClock(email.createdAt)}',
                  ),
                if (email.isFailed && email.errorMessage != null)
                  row(
                    Icons.error_outline,
                    'Raison de l\'échec : ${email.errorMessage}',
                    color: AppColors.error,
                  ),
                const Divider(height: 24),
                Text(
                  'MESSAGE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: SelectableText(
                    email.body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
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

class _EmailTile extends StatelessWidget {
  const _EmailTile({required this.email, required this.onTap});

  final EmailItem email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = (email.toName?.isNotEmpty == true ? email.toName![0] : email.toEmail[0]).toUpperCase();

    final dateLabel = email.isSent && email.sentAt != null
        ? 'Envoyé le ${formatDayLabel(email.sentAt!)}'
        : formatDayLabel(email.createdAt);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            initial,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              email.toName?.isNotEmpty == true ? email.toName! : email.toEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: email.status),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            email.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            email.isFailed && email.errorMessage != null
                ? 'Échec : ${email.errorMessage}'
                : dateLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: email.isFailed ? AppColors.error : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'sent' => ('Envoyé', AppColors.success),
      'failed' => ('Échec', AppColors.error),
      _ => ('En attente d\'envoi', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
