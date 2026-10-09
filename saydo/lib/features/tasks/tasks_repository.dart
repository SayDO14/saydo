import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'task_item.dart';

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) => TasksRepository(Supabase.instance.client),
);

/// Incomplete tasks first, then by due date (nulls last), then oldest first.
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
        .order('done', ascending: true)
        .order('due_at', ascending: true, nullsFirst: false)
        .order('created_at', ascending: true);
    return rows.map(TaskItem.fromJson).toList();
  }

  /// Toggle done status. Sets/clears completed_at accordingly.
  Future<void> toggleDone(String id, bool done) async {
    await _db.from('tasks').update({
      'done': done,
      'completed_at': done ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> updateTitle(String id, String title) async {
    await _db.from('tasks').update({'title': title.trim()}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.from('tasks').delete().eq('id', id);
  }
}
