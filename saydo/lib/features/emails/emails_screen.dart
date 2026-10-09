import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
