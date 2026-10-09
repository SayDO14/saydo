import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../voice/parse_result.dart';
import 'proposal_data.dart';

final saveServiceProvider = Provider<SaveService>(
  (ref) => SaveService(Supabase.instance.client),
);

class SaveService {
  SaveService(this._db);
  final SupabaseClient _db;

  String get _uid => _db.auth.currentUser!.id;

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
      'timezone': 'Africa/Algiers', // TODO: from profile (settings feature)
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
    await _db.from('emails').insert({
      'user_id': _uid,
      'to_name': d.toName.trim().isEmpty ? null : d.toName.trim(),
      'to_email': d.toEmail.trim(),
      'subject': d.subject.trim(),
      'body': d.body.trim(),
      'status': 'approved', // approved by the user; n8n sends it
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
