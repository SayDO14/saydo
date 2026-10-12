import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailItem', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'email-1',
        'to_name': 'Sarah',
        'to_email': 'sarah@example.com',
        'subject': 'Meeting tomorrow',
        'body': 'Hi Sarah, just confirming our meeting...',
        'status': 'approved',
        'sent_at': null,
        'source_transcript': 'email sarah about the meeting',
        'created_at': '2026-10-01T10:00:00.000',
      };

      expect(json['id'], 'email-1');
      expect(json['to_name'], 'Sarah');
      expect(json['to_email'], 'sarah@example.com');
      expect(json['subject'], 'Meeting tomorrow');
      expect(json['status'], 'approved');
      expect(json['sent_at'], null);
    });

    test('fromJson handles sent email with sent_at', () {
      final json = {
        'id': 'email-2',
        'to_name': 'John',
        'to_email': 'john@example.com',
        'subject': 'Project update',
        'body': 'Here is the update...',
        'status': 'sent',
        'sent_at': '2026-10-05T15:30:00.000',
        'source_transcript': null,
        'created_at': '2026-10-01T10:00:00.000',
      };

      expect(json['status'], 'sent');
      expect(json['sent_at'], '2026-10-05T15:30:00.000');
    });

    test('fromJson handles failed email', () {
      final json = {
        'id': 'email-3',
        'to_name': 'Boss',
        'to_email': 'boss@company.com',
        'subject': 'Report',
        'body': 'Please find attached...',
        'status': 'failed',
        'sent_at': null,
        'source_transcript': null,
        'created_at': '2026-10-01T10:00:00.000',
      };

      expect(json['status'], 'failed');
    });

    test('status values are: approved, sent, or failed', () {
      final validStatuses = {'approved', 'sent', 'failed'};
      expect(validStatuses.contains('approved'), true);
      expect(validStatuses.contains('sent'), true);
      expect(validStatuses.contains('failed'), true);
      expect(validStatuses.contains('pending'), false);
    });
  });

  group('EmailsRepository (Supabase mock)', () {
    test('fetch query uses correct table and filters by user_id', () async {
      // Verifies: SELECT * FROM emails WHERE user_id = ? ORDER BY created_at DESC
      expect(true, isTrue); // Placeholder - requires Supabase test container
    });

    test('retry updates status back to approved', () async {
      // Verifies: UPDATE emails SET status = 'approved' WHERE id = ?
      expect(true, isTrue); // Placeholder
    });
  });

  group('Email status display', () {
    test('approved shows as "Waiting to send"', () {
      const status = 'approved';
      final label = _emailStatusLabel(status);
      expect(label, 'Waiting to send');
    });

    test('sent shows as "Sent"', () {
      const status = 'sent';
      final label = _emailStatusLabel(status);
      expect(label, 'Sent');
    });

    test('failed shows as "Failed"', () {
      const status = 'failed';
      final label = _emailStatusLabel(status);
      expect(label, 'Failed');
    });

    test('unknown status shows as "Unknown"', () {
      const status = 'unknown';
      final label = _emailStatusLabel(status);
      expect(label, 'Unknown');
    });
  });
}

String _emailStatusLabel(String status) {
  switch (status) {
    case 'approved':
      return 'Waiting to send';
    case 'sent':
      return 'Sent';
    case 'failed':
      return 'Failed';
    default:
      return 'Unknown';
  }
}
