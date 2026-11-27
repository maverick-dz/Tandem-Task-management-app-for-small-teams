import 'package:flutter/widgets.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/utils/digit_runs.dart';

/// A [Text] that draws digit runs with the Latin face on Arabic screens, where
/// the dot-matrix digits of Handjet are hard to read.
class AppText extends StatelessWidget {
  const AppText(this.data, {required this.style, super.key, this.textAlign, this.maxLines});

  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (!context.isArabic) {
      return Text(data, style: style, textAlign: textAlign, maxLines: maxLines);
    }
    final digits = context.type.latinDigits(style);
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final run in splitDigitRuns(data))
            TextSpan(text: run.text, style: run.isDigits ? digits : style),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
