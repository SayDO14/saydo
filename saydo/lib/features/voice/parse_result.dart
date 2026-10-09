/// Response of POST /saydo-parse.
class ParseResult {
  ParseResult({
    required this.status,
    required this.transcript,
    this.type,
    this.title,
    this.date,
    this.time,
    this.people = const [],
    this.question,
    this.toName,
    this.subject,
    this.body,
  });

  final String status; // ok | needs_info | error
  final String transcript;
  final String? type; // event | task | email
  final String? title;
  final String? date;
  final String? time;
  final List<String> people;
  final String? question;
  final String? toName;
  final String? subject;
  final String? body;

  bool get needsInfo => status == 'needs_info';
  bool get isProposal => status == 'ok' && type != null;

  factory ParseResult.fromJson(Map<String, dynamic> j) => ParseResult(
        status: j['status'] as String? ?? 'error',
        transcript: j['transcript'] as String? ?? '',
        type: j['type'] as String?,
        title: j['title'] as String?,
        date: j['date'] as String?,
        time: j['time'] as String?,
        people: (j['people'] as List? ?? []).map((e) => e.toString()).toList(),
        question: j['question'] as String?,
        toName: j['to_name'] as String?,
        subject: j['subject'] as String?,
        body: j['body'] as String?,
      );
}
