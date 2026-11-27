import 'package:flutter/widgets.dart';
import 'package:tandem/core/theme/app_typography.dart';

extension TypographyContext on BuildContext {
  /// Text styles for the language of the screen (Arabic uses a larger scale).
  AppTypography get type =>
      AppTypography.forLanguage(Localizations.localeOf(this).languageCode);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
