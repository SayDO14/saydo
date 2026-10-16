import 'package:flutter/material.dart';

import '../voice/parse_result.dart';

/// Editable copy of what the voice agent proposed. The confirmation sheet
/// edits this, and [SaveService.confirm] writes it to the database.
class ProposalData {
  const ProposalData({
    required this.type,
    this.title = '',
    this.date,
    this.time,
    this.people = const [],
    this.toName = '',
    this.toEmail = '',
    this.subject = '',
    this.body = '',
  });

  final String type; // event | task | email
  final String title;
  final DateTime? date; // calendar day only
  final TimeOfDay? time;
  final List<String> people;
  final String toName;
  final String toEmail;
  final String subject;
  final String body;

  factory ProposalData.fromResult(ParseResult r) => ProposalData(
        type: r.type ?? 'task',
        title: r.title ?? '',
        date: _parseDate(r.date),
        time: _parseTime(r.time),
        people: List<String>.from(r.people),
        toName: r.toName ?? '',
        subject: r.subject ?? '',
        body: r.body ?? '',
      );

  ProposalData copyWith({
    String? title,
    DateTime? date,
    bool clearDate = false,
    TimeOfDay? time,
    bool clearTime = false,
    List<String>? people,
    String? toName,
    String? toEmail,
    String? subject,
    String? body,
  }) =>
      ProposalData(
        type: type,
        title: title ?? this.title,
        date: clearDate ? null : (date ?? this.date),
        time: clearTime ? null : (time ?? this.time),
        people: people ?? this.people,
        toName: toName ?? this.toName,
        toEmail: toEmail ?? this.toEmail,
        subject: subject ?? this.subject,
        body: body ?? this.body,
      );

  /// Used to detect whether the user edited the proposal.
  /// [toEmail] is left out on purpose: the agent never proposes one, so
  /// typing it must not count as an edit (SaveService stores it separately).
  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title.trim(),
        'date': date == null ? null : _fmtDate(date!),
        'time': time == null ? null : _fmtTime(time!),
        'people': people,
        'to_name': toName.trim(),
        'subject': subject.trim(),
        'body': body.trim(),
      };

  static DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    final d = DateTime.tryParse(s);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  static TimeOfDay? _parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return TimeOfDay(hour: h, minute: min);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';
}
