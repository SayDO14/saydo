class EmailItem {
  const EmailItem({
    required this.id,
    this.toName,
    required this.toEmail,
    required this.subject,
    required this.body,
    required this.status, // 'approved' | 'sent' | 'failed'
    this.gmailMessageId,
    this.errorMessage,
    this.transcript,
    this.sentAt,
    required this.createdAt,
  });

  final String id;
  final String? toName;
  final String toEmail;
  final String subject;
  final String body;
  final String status;
  final String? gmailMessageId;
  final String? errorMessage;
  final String? transcript;
  final DateTime? sentAt;
  final DateTime createdAt;

  bool get isApproved => status == 'approved';
  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';

  factory EmailItem.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return EmailItem(
      id: j['id'] as String,
      toName: j['to_name'] as String?,
      toEmail: j['to_email'] as String? ?? '',
      subject: j['subject'] as String? ?? '',
      body: j['body'] as String? ?? '',
      status: j['status'] as String? ?? 'approved',
      gmailMessageId: j['gmail_message_id'] as String?,
      errorMessage: j['error_message'] as String?,
      transcript: j['source_transcript'] as String?,
      sentAt: parse(j['sent_at']),
      createdAt: parse(j['created_at']) ?? DateTime.now(),
    );
  }
}
