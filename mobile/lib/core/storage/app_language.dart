/// The languages of the app (spec F9). Names are written in their own script
/// on purpose, so that a person can find their language in any language.
enum AppLanguage {
  arabic('ar', 'العربية'),
  french('fr', 'Français'),
  english('en', 'English');

  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  bool get isRightToLeft => this == AppLanguage.arabic;

  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}
