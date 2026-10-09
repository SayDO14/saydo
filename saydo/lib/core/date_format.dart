// Date / time formatting helpers used across the events feature.

const _monthAbbrevs = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _dayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  'Friday', 'Saturday', 'Sunday',
];

/// "Today", "Tomorrow", or "Mon, Mar 15" for older dates.
String formatDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(date.year, date.month, date.day);
  final diff = that.difference(today).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';

  final dayName = _dayNames[date.weekday - 1];
  final month = _monthAbbrevs[date.month - 1];
  return '$dayName, $month ${date.day}';
}

/// "9:30 AM" / "14:05" style clock time.
String formatClock(DateTime time) {
  final h = time.hour;
  final m = time.minute.toString().padLeft(2, '0');
  if (h == 0) return '12:$m AM';
  if (h < 12) return '$h:$m AM';
  if (h == 12) return '12:$m PM';
  return '${h - 12}:$m PM';
}

/// "Jan", "Feb", etc.
String monthShort(DateTime date) => _monthAbbrevs[date.month - 1];
