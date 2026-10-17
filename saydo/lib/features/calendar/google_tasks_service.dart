import 'package:flutter/foundation.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'google_token_store.dart';

/// Creates tasks in the user's own Google Tasks (default list).
class GoogleTasksService {
  /// Returns the Google task id, or null if it couldn't be synced
  /// (no/expired Google token, scope not granted, network...).
  Future<String?> createTask({
    required String title,
    String? notes,
    DateTime? dueDate, // calendar day only (time is ignored by Google Tasks)
  }) async {
    http.Client? base;
    try {
      final saved = await GoogleTokenStore.read();
      if (saved == null) {
        debugPrint('[GoogleTasks] No valid Google token — user must sign in again');
        return null;
      }

      base = http.Client();
      final authClient = authenticatedClient(
        base,
        AccessCredentials(
          AccessToken('Bearer', saved.token, saved.expiry.toUtc()),
          null,
          [TasksApi.tasksScope],
        ),
      );

      final task = Task()
        ..title = title
        ..notes = (notes == null || notes.isEmpty) ? null : notes;
      if (dueDate != null) {
        // Same calendar day for everyone: build the date at 00:00 UTC.
        task.due = DateTime.utc(dueDate.year, dueDate.month, dueDate.day)
            .toIso8601String();
      }

      final created = await TasksApi(authClient).tasks.insert(task, '@default');
      debugPrint('[GoogleTasks] Created task: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[GoogleTasks] Failed to create task: $e');
      return null;
    } finally {
      base?.close();
    }
  }
}
