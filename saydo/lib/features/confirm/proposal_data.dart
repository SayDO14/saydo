import 'package:flutter/material.dart';

import '../voice/parse_result.dart';

/// The values the user can edit before confirming.
class ProposalData {
  ProposalData({
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
  String title;
  DateTime? date;
  TimeOfDay? time;
  List<String> people;
  String toName;
  String toEmail;
  String subject;
  String body;

  factory ProposalData.fromResult(ParseResult r) {
    final d = r.date == null ? null : DateTime.tryParse(r.date!);
    TimeOfDay? t;
    final parts = r.time?.split(':');
    if (parts != null && parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) t = TimeOfDay(hour: h, minute: m);
    }
    return ProposalData(
      type: r.type ?? 'task',
      title: r.title ?? '',
      date: d == null ? null : DateTime(d.year, d.month, d.day),
      time: t,
      people: r.people,
      toName: r.toName ?? '',
      subject: r.subject ?? '',
      body: r.body ?? '',
    );
  }

  /// Without toEmail: the agent never provides it, so it must not count as an edit.
  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title.trim(),
        'date': date == null ? null : formatDate(date!),
        'time': time == null ? null : formatTime(time!),
        'people': people,
        'to_name': toName.trim(),
        'subject': subject.trim(),
        'body': body.trim(),
      };
}

String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// ISO 8601 with the local UTC offset, so Postgres keeps the wall-clock time
/// the user meant (a plain local toIso8601String has no offset).
String isoWithOffset(DateTime local) {
  final off = local.timeZoneOffset;
  final sign = off.isNegative ? '-' : '+';
  final h = off.inHours.abs().toString().padLeft(2, '0');
  final m = (off.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '${local.toIso8601String()}$sign$h:$m';
}
