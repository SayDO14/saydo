import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'task_item.dart';

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) => TasksRepository(Supabase.instance.client),
);

/// Tâches actives et terminées de l'utilisateur.
final tasksProvider = FutureProvider.autoDispose<List<TaskItem>>(
  (ref) => ref.watch(tasksRepositoryProvider).fetch(),
);

class TasksRepository {
  TasksRepository(this._db);
  final SupabaseClient _db;

  String get _uid => _db.auth.currentUser!.id;

  Future<List<TaskItem>> fetch() async {
    final rows = await _db
        .from('tasks')
        .select()
        .eq('user_id', _uid)
        .order('due_at', ascending: true, nullsFirst: false)
        .order('created_at', ascending: false);
    return rows.map(TaskItem.fromJson).toList();
  }

  Future<void> toggleDone(String id, bool isDone) async {
    await _db.from('tasks').update({
      'status': isDone ? 'done' : 'todo',
      'completed_at': isDone ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> update({
    required String id,
    required String title,
    String? notes,
    DateTime? dueAt,
  }) async {
    await _db.from('tasks').update({
      'title': title.trim(),
      'notes': (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      'due_at': dueAt?.toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.from('tasks').delete().eq('id', id);
  }
}
