class EmailItem {
  const EmailItem({
    required this.id,
    this.toName,
    required this.toEmail,
    required this.subject,
    required this.body,
    required this.status,
    this.sentAt,
    this.transcript,
    this.createdAt,
  });

  final String id;
  final String? toName;
  final String toEmail;
  final String subject;
  final String body;

  /// 'approved' | 'sent' | 'failed'
  final String status;

  final DateTime? sentAt;
  final String? transcript;
  final DateTime? createdAt;

  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';
  bool get isApproved => status == 'approved';

  String get statusLabel => switch (status) {
        'approved' => 'Waiting to send',
        'sent' => 'Sent',
        'failed' => 'Failed',
        _ => 'Unknown',
      };

  String get recipientLabel {
    if (toName != null && toName!.isNotEmpty) return '$toName · $toEmail';
    return toEmail;
  }

  factory EmailItem.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return EmailItem(
      id: j['id'] as String,
      toName: j['to_name'] as String?,
      toEmail: j['to_email'] as String,
      subject: j['subject'] as String,
      body: j['body'] as String,
      status: j['status'] as String? ?? 'approved',
      sentAt: parse(j['sent_at']),
      transcript: j['source_transcript'] as String?,
      createdAt: parse(j['created_at']),
    );
  }
}
