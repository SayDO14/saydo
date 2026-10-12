import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'email_item.dart';
import 'contact_item.dart';

final emailsRepositoryProvider = Provider<EmailsRepository>(
  (ref) => EmailsRepository(Supabase.instance.client),
);

/// Liste des emails de l'utilisateur, triée par created_at décroissant.
/// Newest first.
final emailsProvider = FutureProvider.autoDispose<List<EmailItem>>(
  (ref) => ref.watch(emailsRepositoryProvider).fetch(),
);

class EmailsRepository {
  EmailsRepository(this._db);
  final SupabaseClient _db;

  String get _uid => _db.auth.currentUser!.id;

  Future<List<EmailItem>> fetch() async {
    final rows = await _db
        .from('emails')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return rows.map(EmailItem.fromJson).toList();
  }

  /// Re-approve a failed email so n8n can retry sending it.
  Future<void> retry(String id) async {
    await _db.from('emails').update({'status': 'approved'}).eq('id', id);
  }
}
