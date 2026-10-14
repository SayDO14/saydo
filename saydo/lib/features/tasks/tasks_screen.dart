import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/date_format.dart';
import '../voice/voice_sheet.dart';
import 'task_edit_sheet.dart';
import 'task_item.dart';
import 'tasks_repository.dart';
import 'package:saydo/l10n/app_localizations.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _bg          = Color(0xFF070818);
const _cardColor   = Color(0xFF0F1230);
const _cardBorder  = Color(0xFF1E2455);
const _accent      = Color(0xFF4E78FF);
const _textPrimary = Colors.white;
const _textSec     = Color(0xFF8B9CC7);
const _doneColor   = Color(0xFF10B981);

// ── Filter enum ───────────────────────────────────────────────────────────────
enum _Filter { all, today, upcoming }

// ── Screen ────────────────────────────────────────────────────────────────────
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _Filter _filter = _Filter.all;

  Future<void> _toggleDone(TaskItem task, bool isDone) async {
    try {
      await ref.read(tasksRepositoryProvider).toggleDone(task.id, isDone);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.tasksUpdateError('$e'));
    }
  }

  Future<void> _delete(TaskItem task) async {
    final ok = await _confirmDelete(task);
    if (ok != true) return;
    try {
      await ref.read(tasksRepositoryProvider).delete(task.id);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.deleteError('$e'));
    }
  }

  Future<bool?> _confirmDelete(TaskItem task) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF111535),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _cardBorder, width: 1.2),
          ),
          title: Text(AppLocalizations.of(context)!.tasksDeleteTitle,
              style: TextStyle(
                  color: _textPrimary, fontWeight: FontWeight.bold)),
          content: Text(AppLocalizations.of(context)!.tasksDeleteBody(task.title),
              style: const TextStyle(color: _textSec)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: _textSec)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        ),
      );

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

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
            child: tasks.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _accent)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: _textSec, size: 48),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.tasksLoadError('$e'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _textSec)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(tasksProvider),
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ),
              data: (items) => _TasksBody(
                items: items,
                filter: _filter,
                onFilterChange: (f) => setState(() => _filter = f),
                onToggle: _toggleDone,
                onDelete: _delete,
                onAdd: () => showTaskEditSheet(
                    context, const TaskItem(id: '', title: '', status: 'todo')),
                onVoiceAdd: () => showVoiceAssistant(context, ref),
                onRefresh: () => ref.refresh(tasksProvider.future),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tasks body ────────────────────────────────────────────────────────────────
class _TasksBody extends StatelessWidget {
  const _TasksBody({
    required this.items,
    required this.filter,
    required this.onFilterChange,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
    required this.onVoiceAdd,
    required this.onRefresh,
  });

  final List<TaskItem> items;
  final _Filter filter;
  final ValueChanged<_Filter> onFilterChange;
  final void Function(TaskItem, bool) onToggle;
  final void Function(TaskItem) onDelete;
  final VoidCallback onAdd;
  final VoidCallback onVoiceAdd;
  final Future<void> Function() onRefresh;

  List<TaskItem> get _todo => items.where((t) => !t.isDone).toList();
  List<TaskItem> get _done => items.where((t) => t.isDone).toList();

  List<TaskItem> _filtered() {
    final now = DateTime.now();
    final todayStart = DateUtils.dateOnly(now);
    final todayEnd = todayStart.add(const Duration(days: 1));
    switch (filter) {
      case _Filter.all:
        return items.where((t) => !t.isDone).toList();
      case _Filter.today:
        return items.where((t) {
          if (t.isDone) return false;
          if (t.dueAt == null) return false;
          return t.dueAt!.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
              t.dueAt!.isBefore(todayEnd);
        }).toList();
      case _Filter.upcoming:
        return items.where((t) {
          if (t.isDone) return false;
          if (t.dueAt == null) return false;
          return t.dueAt!.isAfter(
              DateUtils.dateOnly(now).add(const Duration(days: 1)));
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SayDo',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.tasksTitle,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.tasksSubtitle,
                    style: TextStyle(color: _textSec, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              // Profile button + robot
              Column(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111535),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF222A60), width: 1.1),
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          color: Colors.white70, size: 20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onVoiceAdd,
                    child: SizedBox(
                      width: 70,
                      child: Image.asset(
                        'assets/images/robot_avatar_head.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/robot_standing.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(height: 60),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Stats cards ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_box_outline_blank_rounded,
                  label: AppLocalizations.of(context)!.tasksTodo,
                  count: _todo.length,
                  color: _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: AppLocalizations.of(context)!.tasksDone,
                  count: _done.length,
                  color: _doneColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Filter tabs ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _cardBorder, width: 1.1),
            ),
            child: Row(
              children: [
                _FilterTab(
                    label: AppLocalizations.of(context)!.tasksFilterAll,
                    active: filter == _Filter.all,
                    onTap: () => onFilterChange(_Filter.all)),
                _FilterTab(
                    label: AppLocalizations.of(context)!.today,
                    active: filter == _Filter.today,
                    onTap: () => onFilterChange(_Filter.today)),
                _FilterTab(
                    label: AppLocalizations.of(context)!.upcoming,
                    active: filter == _Filter.upcoming,
                    onTap: () => onFilterChange(_Filter.upcoming)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Task list ────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: _accent,
            onRefresh: onRefresh,
            child: filtered.isEmpty
                ? _EmptyState(onAdd: onAdd, onVoiceAdd: onVoiceAdd)
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      // Section header
                      _SectionHeader(
                        label: filter == _Filter.today
                            ? AppLocalizations.of(context)!.today
                            : filter == _Filter.upcoming
                                ? AppLocalizations.of(context)!.upcoming
                                : AppLocalizations.of(context)!.today,
                        count: filtered.length,
                      ),
                      const SizedBox(height: 10),
                      // Task cards
                      ...filtered.map((t) => _TaskCard(
                            task: t,
                            onToggle: (v) => onToggle(t, v),
                            onDelete: () => onDelete(t),
                            onTap: () {},
                          )),
                      const SizedBox(height: 14),
                      // Voice add bar
                      _VoiceAddBar(onTap: onVoiceAdd),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _textSec, fontSize: 12)),
                Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: _textSec, size: 20),
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
              color: active ? Colors.white : _textSec,
              fontSize: 12,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2460),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text('$count',
              style: const TextStyle(
                  color: _accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ── Task card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });
  final TaskItem task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone;
    final hasPriority = task.priority > 1;

    String dateLabel = '';
    if (task.dueAt != null) {
      dateLabel = formatDayLabel(task.dueAt!);
      if (task.dueHasTime) {
        dateLabel += ' - ${formatClock(task.dueAt!)}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? _doneColor.withValues(alpha: 0.3)
              : _cardBorder,
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Square checkbox
                GestureDetector(
                  onTap: () => onToggle(!isDone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isDone
                          ? _doneColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: isDone ? _doneColor : _textSec,
                        width: 1.8,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: _doneColor)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: isDone ? _textSec : _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: _textSec,
                        ),
                      ),
                      if (dateLabel.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 11, color: _textSec),
                            const SizedBox(width: 4),
                            Text(dateLabel,
                                style: const TextStyle(
                                    color: _textSec, fontSize: 12)),
                          ],
                        ),
                      ],
                      if (hasPriority) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E78FF)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_rounded,
                                  size: 11, color: _accent),
                              SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.tasksPriority,
                                  style: TextStyle(
                                      color: _accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Three-dot menu
                GestureDetector(
                  onTap: () => _showMenu(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert_rounded,
                        color: _textSec, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111535),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: _cardBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded,
                  color: _doneColor),
              title: Text(
                task.isDone ? AppLocalizations.of(context)!.tasksMarkTodo : AppLocalizations.of(context)!.tasksMarkDone,
                style: const TextStyle(color: _textPrimary),
              ),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                onToggle(!task.isDone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              title: Text(AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Voice add bar ─────────────────────────────────────────────────────────────
class _VoiceAddBar extends StatelessWidget {
  const _VoiceAddBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.15),
                border: Border.all(
                    color: _accent.withValues(alpha: 0.4), width: 1.2),
              ),
              child: const Icon(Icons.mic_rounded,
                  color: _accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.tasksAddByVoice,
                style: TextStyle(color: _textSec, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _textSec, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, required this.onVoiceAdd});
  final VoidCallback onAdd;
  final VoidCallback onVoiceAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onVoiceAdd,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF111535),
                    border: Border.all(
                        color: const Color(0xFF222A60), width: 1.2),
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: _accent, size: 34),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.tasksEmpty,
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onVoiceAdd,
                child: Text(
                  AppLocalizations.of(context)!.tasksEmptyHint,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _VoiceAddBar(onTap: onVoiceAdd),
      ],
    );
  }
}
