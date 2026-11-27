import 'package:flutter/painting.dart';

/// Spacing, radii and shadows of the design. Layout code uses
/// `EdgeInsetsDirectional` so that Arabic mirrors without extra work.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;

  /// Every tap target is at least 44 points (spec section 6).
  static const double minTap = 44;
}

abstract final class AppRadius {
  static const double card = 14;
  static const double input = 10;
  static const double pill = 999;
  static const double sheet = 28;
}

abstract final class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x14192924), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x59234A39),
      offset: Offset(0, 24),
      blurRadius: 48,
      spreadRadius: -24,
    ),
  ];
}
