import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_settings.dart';
import '../../core/date_format.dart';
import '../voice/parse_result.dart';
import 'proposal_data.dart';

final saveServiceProvider = Provider<SaveService>(
  (ref) => SaveService(Supabase.instance.client, () => ref.read(timezoneProvider)),
);

class SaveService {
  SaveService(this._db, this._timezone);
  final SupabaseClient _db;

  /// Current timezone chosen in Settings (read at save time, not cached).
  final String Function() _timezone;

  String get _uid => _db.auth.currentUser!.id;

  /// Signed-in user's address (from the Google login).
  String get _senderEmail => _db.auth.currentUser!.email ?? '';

  /// Signed-in user's display name (Google full name, else the email prefix).
  String get _senderName {
    final user = _db.auth.currentUser!;
    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;
    final email = user.email ?? '';
    return email.contains('@') ? email.split('@').first : email;
  }

  /// Email address of a saved contact, matched by spoken name (case-insensitive).
  Future<String?> findContactEmail(String name) async {
    if (name.trim().isEmpty) return null;
    try {
      final row = await _db
          .from('contacts')
          .select('email')
          .eq('user_id', _uid)
          .ilike('name', name.trim())
          .maybeSingle();
      return row?['email'] as String?;
    } catch (_) {
      return null; // prefill is a convenience, never block the user
    }
  }

  /// Saves the capture and the event / task / email it produced.
  /// n8n picks the new row up through the database webhook.
  Future<void> confirm(ParseResult parsed, ProposalData data) async {
    final original = ProposalData.fromResult(parsed).toJson();
    final edited = !mapEquals(
      original.map((k, v) => MapEntry(k, v is List ? v.join('|') : v)),
      data.toJson().map((k, v) => MapEntry(k, v is List ? v.join('|') : v)),
    );

    final capture = await _db
        .from('voice_captures')
        .insert({
          'user_id': _uid,
          'raw_transcript': parsed.transcript,
          'parsed_json': parsed.raw,
          'final_json': {...data.toJson(), 'to_email': data.toEmail.trim()},
          'intent': data.type,
          'stt_model': 'gemini',
          'status': 'pending',
        })
        .select('id')
        .single();
    final captureId = capture['id'] as String;

    try {
      switch (data.type) {
        case 'event':
          await _insertEvent(data, parsed.transcript, captureId);
        case 'email':
          await _insertEmail(data, parsed.transcript, captureId);
        default:
          await _insertTask(data, parsed.transcript, captureId);
      }
    } catch (e) {
      await _db
          .from('voice_captures')
          .update({'status': 'failed', 'error_message': e.toString()})
          .eq('id', captureId);
      rethrow;
    }

    await _db
        .from('voice_captures')
        .update({'status': edited ? 'edited' : 'confirmed'})
        .eq('id', captureId);
  }

  /// Keeps the capture (useful later as test data) without creating anything.
  Future<void> reject(ParseResult parsed) async {
    try {
      await _db.from('voice_captures').insert({
        'user_id': _uid,
        'raw_transcript': parsed.transcript,
        'parsed_json': parsed.raw,
        'intent': parsed.type ?? 'unknown',
        'stt_model': 'gemini',
        'status': 'rejected',
      });
    } catch (_) {}
  }

  Future<void> _insertEvent(ProposalData d, String transcript, String captureId) {
    final start = DateTime(d.date!.year, d.date!.month, d.date!.day, d.time!.hour, d.time!.minute);
    return _db.from('events').insert({
      'user_id': _uid,
      'title': d.title.trim(),
      'start_at': isoWithOffset(start),
      'timezone': _timezone(),
      'related_people': d.people,
      'source_transcript': transcript,
      'capture_id': captureId,
    });
  }

  Future<void> _insertTask(ProposalData d, String transcript, String captureId) {
    // Date-only deadline: noon keeps the same calendar day in any timezone.
    final due = d.date == null ? null : DateTime(d.date!.year, d.date!.month, d.date!.day, 12);
    return _db.from('tasks').insert({
      'user_id': _uid,
      'title': d.title.trim(),
      'due_at': due == null ? null : isoWithOffset(due),
      'due_has_time': false,
      'related_people': d.people,
      'source_transcript': transcript,
      'capture_id': captureId,
    });
  }

  Future<void> _insertEmail(ProposalData d, String transcript, String captureId) async {
    // 'approved' -> the n8n workflow picks the row up and sends the email.
    await _db.from('emails').insert({
      'user_id': _uid,
      'to_name': d.toName.trim().isEmpty ? null : d.toName.trim(),
      'to_email': d.toEmail.trim(),
      'subject': d.subject.trim(),
      'body': d.body.trim(),
      'sender_name': _senderName,
      'sender_email': _senderEmail,
      'status': 'approved',
      'source_transcript': transcript,
      'capture_id': captureId,
    });

    // Remember the address so next time "email Sarah" is one tap.
    if (d.toName.trim().isNotEmpty) {
      try {
        await _db.from('contacts').upsert(
          {'user_id': _uid, 'name': d.toName.trim(), 'email': d.toEmail.trim()},
          onConflict: 'user_id,name',
        );
      } catch (_) {}
    }
  }
}