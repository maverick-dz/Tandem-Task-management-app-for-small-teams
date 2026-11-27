import 'dart:ui' show Color;

/// Design tokens of the Dose theme (the OKLCH values of the design, as sRGB).
/// Red is never used for late or missed: lateness is the neutral grey.
abstract final class AppColors {
  static const Color paper = Color(0xFFFAF7EF);
  static const Color paper2 = Color(0xFFE9F8EF);
  static const Color paper3 = Color(0xFFD4F0E0);
  static const Color ink = Color(0xFF0C1C16);
  static const Color ink2 = Color(0xFF26342F);
  static const Color muted = Color(0xFF54655D);
  static const Color rule = Color(0xFFCBD6C9);
  static const Color accent = Color(0xFF007948);
  static const Color accentDeep = Color(0xFF005F3A);
  static const Color accentSoft = Color(0xFFA9E8C6);
  static const Color accentInk = Color(0xFFF8FDFA);
  static const Color focus = Color(0xFF006B38);
  static const Color light = Color(0xFFFFFDF1);
  static const Color late = Color(0xFFE2E1DD);
  static const Color lateInk = Color(0xFF3F3D36);
  static const Color tintRose = Color(0xFFEEC1BF);
  static const Color tintSand = Color(0xFFEEE4B4);
  static const Color tintSky = Color(0xFFB1DDE6);
  static const Color tintLilac = Color(0xFFBFCAE9);

  /// Colour of the dim layer behind a sheet.
  static const Color scrim = Color(0x730C1C16);
}
