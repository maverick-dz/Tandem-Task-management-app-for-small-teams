/// A piece of text, flagged when it is made of digits.
class TextRun {
  const TextRun(this.text, {required this.isDigits});

  final String text;
  final bool isDigits;

  @override
  bool operator ==(Object other) =>
      other is TextRun && other.text == text && other.isDigits == isDigits;

  @override
  int get hashCode => Object.hash(text, isDigits);

  @override
  String toString() => 'TextRun($text, digits: $isDigits)';
}

final RegExp _digits = RegExp(r'[0-9][0-9:.,%]*');

/// Splits [text] into runs of digits (with `:` `.` `,` `%` glued to them) and
/// other text. The Arabic font (Handjet) draws digits in a dot-matrix style
/// that is hard to read at small sizes, so Arabic screens draw digit runs with
/// the Latin text font.
List<TextRun> splitDigitRuns(String text) {
  final runs = <TextRun>[];
  var cursor = 0;
  for (final match in _digits.allMatches(text)) {
    if (match.start > cursor) {
      runs.add(TextRun(text.substring(cursor, match.start), isDigits: false));
    }
    runs.add(TextRun(match.group(0)!, isDigits: true));
    cursor = match.end;
  }
  if (cursor < text.length) {
    runs.add(TextRun(text.substring(cursor), isDigits: false));
  }
  return runs;
}
