class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.notes,
    this.dueAt,
    this.dueHasTime = false,
    this.priority = 0,
    this.status = 'todo',
    this.completedAt,
    this.people = const [],
    this.transcript,
    this.syncedAt,
  });

  final String id;
  final String title;
  final String? notes;
  final DateTime? dueAt; // converti vers l'heure locale de l'appareil
  final bool dueHasTime;
  final int priority;
  final String status; // 'todo' | 'done' | 'cancelled'
  final DateTime? completedAt;
  final List<String> people;
  final String? transcript;
  final DateTime? syncedAt;

  bool get isDone => status == 'done';
  bool get isSynced => syncedAt != null;

  factory TaskItem.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return TaskItem(
      id: j['id'] as String,
      title: j['title'] as String,
      notes: j['notes'] as String?,
      dueAt: parse(j['due_at']),
      dueHasTime: j['due_has_time'] as bool? ?? false,
      priority: (j['priority'] as num? ?? 0).toInt(),
      status: j['status'] as String? ?? 'todo',
      completedAt: parse(j['completed_at']),
      people: (j['related_people'] as List? ?? []).map((e) => e.toString()).toList(),
      transcript: j['source_transcript'] as String?,
      syncedAt: parse(j['synced_at']),
    );
  }
}
