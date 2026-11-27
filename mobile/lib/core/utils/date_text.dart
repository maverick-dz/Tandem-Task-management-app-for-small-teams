/// Formats dates with names taken from the ARB files, so that weekdays and
/// months follow the app language and numerals stay Latin in every language.
class DateText {
  const DateText({required this.weekdays, required this.months});

  /// Builds the formatter from the two `|`-separated ARB strings
  /// (`common_weekdaysShort` starts on Monday, `common_monthsShort` on January).
  factory DateText.fromArb({
    required String weekdaysShort,
    required String monthsShort,
  }) {
    final weekdays = weekdaysShort.split('|');
    final months = monthsShort.split('|');
    assert(weekdays.length == 7, 'common_weekdaysShort needs 7 names');
    assert(months.length == 12, 'common_monthsShort needs 12 names');
    return DateText(weekdays: weekdays, months: months);
  }

  final List<String> weekdays;
  final List<String> months;

  /// `Sat 24 Oct`
  String short(DateTime d) => '${weekday(d)} ${d.day} ${months[d.month - 1]}';

  /// `Mon 26` (the tear-off stub of a task row)
  String stub(DateTime d) => '${weekday(d)} ${d.day}';

  String weekday(DateTime d) => weekdays[d.weekday - 1];

  /// `17:40`
  String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  static String _two(int v) => v.toString().padLeft(2, '0');
}
