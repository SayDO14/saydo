import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import '../../core/widgets.dart';
import 'task_edit_sheet.dart';
import 'task_item.dart';
import 'tasks_repository.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Future<void> _toggleDone(BuildContext context, WidgetRef ref, TaskItem task, bool isDone) async {
    try {
      await ref.read(tasksRepositoryProvider).toggleDone(task.id, isDone);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de mettre à jour la tâche : $e')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TaskItem task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche ?'),
        content: Text('"${task.title}" sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(tasksRepositoryProvider).delete(task.id);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de supprimer : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tâches')),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Impossible de charger vos tâches.\n$e',
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(tasksProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.check_circle_outline,
                  message: 'Aucune tâche pour le moment.\nDictez-en une avec le micro.',
                )
              : _TasksList(
                  items: items,
                  onToggleDone: (task, isDone) => _toggleDone(context, ref, task, isDone),
                  onDelete: (task) => _delete(context, ref, task),
                  onEdit: (task) => showTaskEditSheet(context, task),
                ),
        ),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({
    required this.items,
    required this.onToggleDone,
    required this.onDelete,
    required this.onEdit,
  });

  final List<TaskItem> items;
  final void Function(TaskItem task, bool isDone) onToggleDone;
  final void Function(TaskItem task) onDelete;
  final void Function(TaskItem task) onEdit;

  @override
  Widget build(BuildContext context) {
    final todo = items.where((t) => !t.isDone).toList();
    final done = items.where((t) => t.isDone).toList();

    final rows = <Object>[
      if (todo.isNotEmpty) 'À faire',
      ...todo,
      if (done.isNotEmpty) 'Terminées',
      ...done,
    ];

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) return _SectionHeader(row);
        final task = row as TaskItem;
        return _TaskTile(
          task: task,
          onToggleDone: (isDone) => onToggleDone(task, isDone),
          onDelete: () => onDelete(task),
          onTap: () => onEdit(task),
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

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggleDone,
    required this.onDelete,
    required this.onTap,
  });

  final TaskItem task;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = task.isDone ? theme.colorScheme.outline : null;

    final parts = <String>[
      if (task.dueAt != null) formatDayLabel(task.dueAt!),
      if (task.people.isNotEmpty) task.people.join(', '),
      if (task.notes != null && task.notes!.isNotEmpty) task.notes!,
    ];
    final subtitle = parts.join(' · ');

    return ListTile(
      onTap: onTap,
      leading: IconButton(
        icon: Icon(
          task.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: task.isDone ? theme.colorScheme.primary : theme.colorScheme.outline,
          size: 26,
        ),
        tooltip: task.isDone ? 'Marquer comme à faire' : 'Marquer comme terminée',
        onPressed: () => onToggleDone(!task.isDone),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          color: dim,
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.isSynced)
            Tooltip(
              message: 'Synchronisé avec Google Tasks',
              child: Icon(
                Icons.cloud_done_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.outline),
            tooltip: 'Supprimer',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
