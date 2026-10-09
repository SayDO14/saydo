class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.dueAt,
    this.done = false,
    this.completedAt,
    this.people = const [],
    this.transcript,
    this.createdAt,
  });

  final String id;
  final String title;
  final DateTime? dueAt;
  final bool done;
  final DateTime? completedAt;
  final List<String> people;
  final String? transcript;
  final DateTime? createdAt;

  bool get isOverdue => !done && dueAt != null && dueAt!.isBefore(DateTime.now());

  TaskItem copyWith({
    String? id,
    String? title,
    DateTime? dueAt,
    bool? done,
    DateTime? completedAt,
    List<String>? people,
    String? transcript,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
      people: people ?? this.people,
      transcript: transcript ?? this.transcript,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> j) {
    DateTime? parse(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
    return TaskItem(
      id: j['id'] as String,
      title: j['title'] as String,
      dueAt: parse(j['due_at']),
      done: j['done'] as bool? ?? false,
      completedAt: parse(j['completed_at']),
      people: (j['related_people'] as List? ?? []).map((e) => e.toString()).toList(),
      transcript: j['source_transcript'] as String?,
      createdAt: parse(j['created_at']),
    );
  }
}
