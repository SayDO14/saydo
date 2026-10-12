// Date / time formatting helpers, translated into the app language.
// The current language is set by LocaleNotifier (core/locale.dart).

String currentLanguageCode = 'fr';

const _months = {
  'fr': ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'],
  'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  'ar': ['جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان', 'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
};

// Index 0 = Monday (DateTime.weekday - 1).
const _days = {
  'fr': ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'],
  'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
  'ar': ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
};

const _relative = {
  'fr': {'today': "Aujourd'hui", 'tomorrow': 'Demain', 'yesterday': 'Hier'},
  'en': {'today': 'Today', 'tomorrow': 'Tomorrow', 'yesterday': 'Yesterday'},
  'ar': {'today': 'اليوم', 'tomorrow': 'غدًا', 'yesterday': 'أمس'},
};

String get _lang => _months.containsKey(currentLanguageCode) ? currentLanguageCode : 'fr';

/// "Today", "Tomorrow", or "Monday, Mar 15" for other dates (translated).
String formatDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(date.year, date.month, date.day);
  final diff = that.difference(today).inDays;

  final words = _relative[_lang]!;
  if (diff == 0) return words['today']!;
  if (diff == 1) return words['tomorrow']!;
  if (diff == -1) return words['yesterday']!;

  final dayName = _days[_lang]![date.weekday - 1];
  final month = _months[_lang]![date.month - 1];
  if (_lang == 'en') return '$dayName, $month ${date.day}';
  return '$dayName ${date.day} $month';
}

/// French: "14:05". English: "2:05 PM". Arabic: "2:05 م".
String formatClock(DateTime time) {
  final h = time.hour;
  final m = time.minute.toString().padLeft(2, '0');

  if (_lang == 'fr') return '${h.toString().padLeft(2, '0')}:$m';

  final am = _lang == 'ar' ? 'ص' : 'AM';
  final pm = _lang == 'ar' ? 'م' : 'PM';
  if (h == 0) return '12:$m $am';
  if (h < 12) return '$h:$m $am';
  if (h == 12) return '12:$m $pm';
  return '${h - 12}:$m $pm';
}

/// Short month name in the app language.
String monthShort(DateTime date) => _months[_lang]![date.month - 1];
