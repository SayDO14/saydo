import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Contact {
  const Contact({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
      );
}

/// Thrown when (user_id, name) already exists.
class DuplicateContactException implements Exception {
  const DuplicateContactException();
}

final contactsRepositoryProvider = Provider<ContactsRepository>(
  (ref) => ContactsRepository(Supabase.instance.client),
);

final contactsProvider = FutureProvider.autoDispose<List<Contact>>(
  (ref) => ref.watch(contactsRepositoryProvider).fetch(),
);

class ContactsRepository {
  ContactsRepository(this._db);
  final SupabaseClient _db;

  String get _uid => _db.auth.currentUser!.id;

  Future<List<Contact>> fetch() async {
    final rows = await _db.from('contacts').select().eq('user_id', _uid).order('name');
    return rows.map(Contact.fromJson).toList();
  }

  /// Insert when [id] is null, update otherwise.
  Future<void> save({String? id, required String name, required String email}) async {
    final values = {'name': name.trim(), 'email': email.trim()};
    try {
      if (id == null) {
        await _db.from('contacts').insert({...values, 'user_id': _uid});
      } else {
        await _db.from('contacts').update(values).eq('id', id);
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const DuplicateContactException();
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    final deleted =
        await _db.from('contacts').delete().eq('id', id).select('id');
    // RLS blocks silently: no error, but zero rows deleted.
    if (deleted.isEmpty) {
      throw Exception('Contact not deleted (check the delete policy in Supabase)');
    }
  }
}