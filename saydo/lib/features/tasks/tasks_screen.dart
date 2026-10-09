import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import '../../core/widgets.dart';
import 'task_item.dart';
import 'tasks_repository.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _toggleDone(WidgetRef ref, TaskItem task) async {
    try {
      await ref.read(tasksRepositoryProvider).toggleDone(task.id, !task.done);
      ref.invalidate(tasksProvider);
    } catch (e) {
      // Error handling done by the provider's error state
    }
  }

  Future<void> _editTitle(BuildContext context, WidgetRef ref, TaskItem task) async {
    final controller = TextEditingController(text: task.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == task.title) return;
    try {
      await ref.read(tasksRepositoryProvider).updateTitle(task.id, newTitle);
      ref.invalidate(tasksProvider);
    } catch (_) {}
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TaskItem task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(tasksRepositoryProvider).delete(task.id);
      ref.invalidate(tasksProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasks.when(
        loading: () => const _LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Could not load your tasks.\n$e',
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(tasksProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.checklist_outlined,
                  message: 'No tasks yet.\nTap the mic and say one.',
                )
              : _TasksList(
                  items: items,
                  onToggle: (t) => _toggleDone(ref, t),
                  onEdit: (t) => _editTitle(context, ref, t),
                  onDelete: (t) => _delete(context, ref, t),
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
          Text('Loading tasks...'),
        ],
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TaskItem> items;
  final void Function(TaskItem) onToggle;
  final void Function(TaskItem) onEdit;
  final void Function(TaskItem) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Overdue first, then today, then upcoming, then done
    final overdue = items.where((t) => !t.done && t.dueAt != null && t.dueAt!.isBefore(today)).toList();
    final dueToday = items.where((t) {
      if (t.done || t.dueAt == null) return false;
      final due = DateTime(t.dueAt!.year, t.dueAt!.month, t.dueAt!.day);
      return due == today;
    }).toList();
    final upcoming = items.where((t) {
      if (t.done || t.dueAt == null) return false;
      return t.dueAt!.isAfter(today);
    }).toList();
    final done = items.where((t) => t.done).toList();

    final sections = <String, List<TaskItem>>{
      if (overdue.isNotEmpty) 'Overdue': overdue,
      if (dueToday.isNotEmpty) 'Today': dueToday,
      if (upcoming.isNotEmpty) 'Upcoming': upcoming,
      if (done.isNotEmpty) 'Done': done,
    };

    final rows = <Object>[];
    sections.forEach((title, tasks) {
      rows.add(title);
      rows.addAll(tasks);
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
                color: row == 'Overdue' ? theme.colorScheme.error : theme.colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          );
        }
        final task = row as TaskItem;
        return _TaskTile(
          task: task,
          onToggle: () => onToggle(task),
          onEdit: () => onEdit(task),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = task.done ? theme.colorScheme.outline : null;

    String? subtitle;
    if (task.dueAt != null) {
      final due = task.allDay
          ? formatDayLabel(task.dueAt!)
          : '${formatDayLabel(task.dueAt!)} · ${formatClock(task.dueAt!)}';
      subtitle = task.isOverdue ? 'Overdue · $due' : due;
      if (task.people.isNotEmpty) subtitle = '$subtitle · ${task.people.join(', ')}';
    } else if (task.people.isNotEmpty) {
      subtitle = task.people.join(', ');
    }

    return ListTile(
      leading: Checkbox(
        value: task.done,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          color: dim,
          decoration: task.done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: task.isOverdue ? theme.colorScheme.error : dim,
              ),
            )
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') onEdit();
          if (v == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

extension on TaskItem {
  bool get allDay => false; // Tasks are date-only; time is always noon
}
