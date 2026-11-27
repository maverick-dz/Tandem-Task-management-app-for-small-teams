import 'package:flutter/painting.dart';
import 'package:tandem/core/theme/app_colors.dart';

/// Faces of the design: Schibsted Grotesk for headings, Instrument Sans for
/// text, DM Mono for dates and times. Arabic screens use Handjet for all three.
abstract final class AppFonts {
  static const String display = 'SchibstedGrotesk';
  static const String body = 'InstrumentSans';
  static const String mono = 'DMMono';
  static const String arabic = 'Handjet';
}

/// Text styles for one script. Handjet is small for its size, so Arabic uses a
/// larger scale than Latin (the same factors as the design).
class AppTypography {
  const AppTypography._({required this.isArabic});

  factory AppTypography.forLanguage(String languageCode) =>
      AppTypography._(isArabic: languageCode == 'ar');

  final bool isArabic;

  double get xs => isArabic ? 14.4 : 12;
  double get sm => isArabic ? 16.8 : 14;
  double get md => isArabic ? 19.2 : 16;
  double get lg => isArabic ? 24 : 19.2;
  double get xl => isArabic ? 28.8 : 23;
  double get xxl => isArabic ? 34.4 : 27.6;
  double get xxxl => isArabic ? 41.6 : 33.2;

  String get _display => isArabic ? AppFonts.arabic : AppFonts.display;
  String get _body => isArabic ? AppFonts.arabic : AppFonts.body;
  String get _mono => isArabic ? AppFonts.arabic : AppFonts.mono;

  /// The variable fonts take their weight from the `wght` axis.
  static List<FontVariation> _wght(double w) => <FontVariation>[FontVariation('wght', w)];

  TextStyle _style(String family, double size, double weight, Color color,
      {double height = 1.4, double letterSpacing = 0}) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
      fontVariations: _wght(weight),
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Headings: one weight, tight tracking in Latin only (Arabic letters join).
  TextStyle heading(double size, {Color color = AppColors.ink}) => _style(
        _display,
        size,
        700,
        color,
        height: 1.1,
        letterSpacing: isArabic ? 0 : -0.03 * size,
      );

  TextStyle body({double? size, Color color = AppColors.ink}) =>
      _style(_body, size ?? md, isArabic ? 500 : 400, color);

  TextStyle bodyMedium({double? size, Color color = AppColors.ink}) =>
      _style(_body, size ?? md, 500, color);

  TextStyle label({Color color = AppColors.ink2}) =>
      _style(_body, sm, 500, color, height: 1.3);

  TextStyle caption({Color color = AppColors.muted}) =>
      _style(_body, sm, isArabic ? 500 : 400, color, height: 1.3);

  /// Dates and times.
  TextStyle mono({double? size, Color color = AppColors.ink}) =>
      _style(_mono, size ?? sm, 400, color, height: 1.3);

  /// Digits drawn with the Latin text face (used inside Arabic text).
  TextStyle latinDigits(TextStyle base) =>
      base.copyWith(fontFamily: AppFonts.body, fontVariations: _wght(500));
}
