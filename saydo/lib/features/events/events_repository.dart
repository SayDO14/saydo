import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'event_item.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(Supabase.instance.client),
);

/// Oldest first; the screen splits it into upcoming / past.
final eventsProvider = FutureProvider.autoDispose<List<EventItem>>(
  (ref) => ref.watch(eventsRepositoryProvider).fetch(),
);

class EventsRepository {
  EventsRepository(this._db);
  final SupabaseClient _db;

  Future<List<EventItem>> fetch() async {
    final rows = await _db
        .from('events')
        .select()
        .eq('user_id', _db.auth.currentUser!.id)
        .order('start_at', ascending: true);
    return rows.map(EventItem.fromJson).toList();
  }
}
