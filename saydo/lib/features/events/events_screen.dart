import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import '../../core/widgets.dart';
import 'event_item.dart';
import 'events_repository.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Could not load your events.\n$e',
          onRetry: () => ref.invalidate(eventsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(eventsProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.event_outlined,
                  message: 'No events yet.\nTap the mic and say one.',
                )
              : _EventsList(items: items),
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.items});
  final List<EventItem> items;

  @override
  Widget build(BuildContext context) {
    final todayStart = DateUtils.dateOnly(DateTime.now());
    final upcoming = items.where((e) => !e.startAt.isBefore(todayStart)).toList();
    final past = items.where((e) => e.startAt.isBefore(todayStart)).toList().reversed.toList();

    // Section titles (String) and events in one flat list.
    final rows = <Object>[
      if (upcoming.isNotEmpty) 'Upcoming',
      ...upcoming,
      if (past.isNotEmpty) 'Past',
      ...past,
    ];

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) return _SectionHeader(row);
        final event = row as EventItem;
        return _EventTile(
          event: event,
          isPast: event.startAt.isBefore(todayStart),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.isPast});
  final EventItem event;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = isPast ? theme.colorScheme.outline : null;
    final when = event.allDay
        ? formatDayLabel(event.startAt)
        : '${formatDayLabel(event.startAt)} · ${formatClock(event.startAt)}';

    return ListTile(
      onTap: () => _showDetails(context, event),
      leading: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: isPast ? 0.4 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${event.startAt.day}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(monthShort(event.startAt).toUpperCase(), style: theme.textTheme.labelSmall),
          ],
        ),
      ),
      title: Text(event.title, style: TextStyle(color: dim)),
      subtitle: Text(
        event.people.isEmpty ? when : '$when · ${event.people.join(', ')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Tooltip(
        message: event.isSynced ? 'In Google Calendar' : 'Not synced yet',
        child: Icon(
          event.isSynced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
          size: 20,
          color: event.isSynced ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, EventItem e) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        Widget row(IconData icon, String text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text)),
                ],
              ),
            );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                row(
                  Icons.schedule,
                  e.allDay
                      ? formatDayLabel(e.startAt)
                      : '${formatDayLabel(e.startAt)} · ${formatClock(e.startAt)}'
                          '${e.endAt == null ? '' : ' – ${formatClock(e.endAt!)}'}',
                ),
                if (e.location != null && e.location!.isNotEmpty)
                  row(Icons.place_outlined, e.location!),
                if (e.people.isNotEmpty) row(Icons.group_outlined, e.people.join(', ')),
                if (e.description != null && e.description!.isNotEmpty)
                  row(Icons.notes, e.description!),
                row(
                  e.isSynced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                  e.isSynced ? 'Synced to Google Calendar' : 'Waiting to sync to Google Calendar',
                ),
                if (e.transcript != null && e.transcript!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    '"${e.transcript}"',
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
