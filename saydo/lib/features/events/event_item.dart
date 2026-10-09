class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.startAt,
    this.endAt,
    this.allDay = false,
    this.location,
    this.description,
    this.people = const [],
    this.transcript,
    this.syncedAt,
  });

  final String id;
  final String title;
  final DateTime startAt; // already converted to the device's local time
  final DateTime? endAt;
  final bool allDay;
  final String? location;
  final String? description;
  final List<String> people;
  final String? transcript;
  final DateTime? syncedAt;

  /// n8n writes synced_at once the event exists in Google Calendar.
  bool get isSynced => syncedAt != null;

  factory EventItem.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return EventItem(
      id: j['id'] as String,
      title: j['title'] as String,
      startAt: parse(j['start_at'])!,
      endAt: parse(j['end_at']),
      allDay: j['all_day'] as bool? ?? false,
      location: j['location'] as String?,
      description: j['description'] as String?,
      people: (j['related_people'] as List? ?? []).map((e) => e.toString()).toList(),
      transcript: j['source_transcript'] as String?,
      syncedAt: parse(j['synced_at']),
    );
  }
}
