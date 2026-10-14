import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import '../voice/voice_sheet.dart';
import 'event_item.dart';
import 'events_repository.dart';
import 'package:saydo/l10n/app_localizations.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _bg         = Color(0xFF070818);
const _cardColor  = Color(0xFF101332);
const _cardBorder = Color(0xFF1E2760);
const _accent     = Color(0xFF4E78FF);
const _textPrimary   = Colors.white;
const _textSecondary = Color(0xFF8E9AC5);
const _dateBg     = Color(0xFF1A2460);

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background wave
          Positioned(
            top: 0, left: 0, right: 0, height: 280,
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
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      const Text(
                        'SayDo',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: _accent,
                                    surface: Color(0xFF0F1230),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            ref.invalidate(eventsProvider);
                          }
                        },
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111535),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF222A60), width: 1.1),
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Page title ───────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 2),
                  child: Text(
                    AppLocalizations.of(context)!.navEvents,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text(
                    AppLocalizations.of(context)!.eventsSubtitle,
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Content ──────────────────────────────────────────
                Expanded(
                  child: events.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _accent),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: _textSecondary, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.eventsLoadError('$e'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _textSecondary),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.invalidate(eventsProvider),
                            child: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ],
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? _EmptyState(onVoice: () => showVoiceAssistant(context, ref))
                        : _EventsList(
                            items: items,
                            onRefresh: () =>
                                ref.refresh(eventsProvider.future),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating Voice Button (Mockup bottom right) ──────────────
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
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onVoice});
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
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF111535),
                border: Border.all(color: const Color(0xFF222A60), width: 1.2),
              ),
              child: const Icon(Icons.mic_rounded, color: _accent, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.eventsEmpty,
            style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onVoice,
            child: Text(
              AppLocalizations.of(context)!.eventsEmptyHint,
              style: TextStyle(
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

// ── Events list with "Voir tout" ──────────────────────────────────────────────
class _EventsList extends StatefulWidget {
  const _EventsList({required this.items, required this.onRefresh});
  final List<EventItem> items;
  final Future<void> Function() onRefresh;

  @override
  State<_EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<_EventsList> {
  bool _showAllUpcoming = false;

  void _openAllEventsSheet(List<EventItem> all) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3270),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.eventsAllUpcoming,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    icon: const Icon(Icons.close_rounded, color: _textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(color: _cardBorder, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: all.length,
                itemBuilder: (_, i) => _EventCard(event: all[i], isPast: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayStart = DateUtils.dateOnly(DateTime.now());
    final upcoming = widget.items
        .where((e) => !e.startAt.isBefore(todayStart))
        .toList();
    final past = widget.items
        .where((e) => e.startAt.isBefore(todayStart))
        .toList()
        .reversed
        .toList();

    // If _showAllUpcoming is false, display up to 3 upcoming cards
    final displayedUpcoming = _showAllUpcoming
        ? upcoming
        : (upcoming.length > 3 ? upcoming.take(3).toList() : upcoming);

    return RefreshIndicator(
      color: _accent,
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          if (upcoming.isNotEmpty) ...[
            _SectionHeader(
              label: AppLocalizations.of(context)!.upcoming,
              count: upcoming.length,
              actionLabel: upcoming.length > 3
                  ? (_showAllUpcoming ? AppLocalizations.of(context)!.showLess : AppLocalizations.of(context)!.showAll)
                  : AppLocalizations.of(context)!.showAll,
              onAction: () {
                if (upcoming.length > 3) {
                  setState(() => _showAllUpcoming = !_showAllUpcoming);
                } else {
                  _openAllEventsSheet(upcoming);
                }
              },
            ),
            const SizedBox(height: 10),
            ...displayedUpcoming.map((e) => _EventCard(event: e, isPast: false)),
          ],
          if (past.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(label: AppLocalizations.of(context)!.past, count: past.length),
            const SizedBox(height: 10),
            ...past.map((e) => _EventCard(event: e, isPast: true)),
          ],
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    this.actionLabel,
    this.onAction,
  });
  final String label;
  final int count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF161E50),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(color: _accent, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded,
                    color: _accent, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.isPast});
  final EventItem event;
  final bool isPast;

  IconData _iconForEvent(EventItem e) {
    if (e.people.isNotEmpty) return Icons.person_outline_rounded;
    if (e.description != null &&
        (e.description!.toLowerCase().contains('exam') ||
            e.description!.toLowerCase().contains('test'))) {
      return Icons.description_outlined;
    }
    return Icons.calendar_today_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final month = monthShort(event.startAt).toUpperCase();
    final timeStr = event.allDay
        ? AppLocalizations.of(context)!.allDay
        : formatClock(event.startAt);
    final subtitle = event.people.isEmpty
        ? timeStr
        : '$timeStr – ${event.people.first}';

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor.withValues(alpha: isPast ? 0.7 : 1.0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _cardBorder.withValues(alpha: isPast ? 0.5 : 1.0),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Date block
            Container(
              width: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isPast
                    ? const Color(0xFF111535)
                    : _dateBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${event.startAt.day}',
                    style: TextStyle(
                      color: isPast ? _textSecondary : _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      color: isPast
                          ? _textSecondary.withValues(alpha: 0.7)
                          : _textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Icon circle
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPast
                    ? const Color(0xFF151830)
                    : const Color(0xFF1D2B7A),
                border: Border.all(
                  color: isPast
                      ? const Color(0xFF1A1F45)
                      : const Color(0xFF2E3E9A),
                  width: 1.2,
                ),
              ),
              child: Icon(
                isPast
                    ? Icons.check_circle_outline_rounded
                    : _iconForEvent(event),
                color: isPast ? _textSecondary : _accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: isPast ? _textSecondary : _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color: _textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(Icons.chevron_right_rounded,
                color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }
}

// ── Event detail sheet ────────────────────────────────────────────────────────
class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event});
  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1230),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3270),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Flexible(
 child: SingleChildScrollView(
 child: SafeArea(
 top: false,
 child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow(
                  Icons.schedule_rounded,
                  event.allDay
                      ? formatDayLabel(event.startAt)
                      : '${formatDayLabel(event.startAt)} · ${formatClock(event.startAt)}'
                          '${event.endAt == null ? '' : ' – ${formatClock(event.endAt!)}'}',
                ),
                if (event.location != null && event.location!.isNotEmpty)
                  _detailRow(Icons.place_outlined, event.location!),
                if (event.people.isNotEmpty)
                  _detailRow(Icons.group_outlined, event.people.join(', ')),
                if (event.description != null && event.description!.isNotEmpty)
                  _detailRow(Icons.notes_rounded, event.description!),
                _detailRow(
                  event.isSynced
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                  event.isSynced
                      ? AppLocalizations.of(context)!.eventSynced
                      : AppLocalizations.of(context)!.eventPendingSync,
                ),
              ],
            ),
          ),
 ),
 ),
 ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
