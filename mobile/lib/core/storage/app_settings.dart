/// Preferences kept on the device (not on the server).
class AppSettings {
  const AppSettings({
    this.languageCode,
    this.followPhoneLanguage = true,
    this.onboardingSeen = false,
    this.privacyConsent = false,
    this.reminderPromptSeen = false,
  });

  /// `ar`, `fr` or `en`; null until the person picks one.
  final String? languageCode;

  /// When true the app language follows the phone setting (spec F9).
  final bool followPhoneLanguage;
  final bool onboardingSeen;
  final bool privacyConsent;
  final bool reminderPromptSeen;

  /// The language to force, or null to follow the phone.
  String? get forcedLanguageCode => followPhoneLanguage ? null : languageCode;

  AppSettings copyWith({
    String? languageCode,
    bool? followPhoneLanguage,
    bool? onboardingSeen,
    bool? privacyConsent,
    bool? reminderPromptSeen,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      followPhoneLanguage: followPhoneLanguage ?? this.followPhoneLanguage,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      privacyConsent: privacyConsent ?? this.privacyConsent,
      reminderPromptSeen: reminderPromptSeen ?? this.reminderPromptSeen,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.languageCode == languageCode &&
      other.followPhoneLanguage == followPhoneLanguage &&
      other.onboardingSeen == onboardingSeen &&
      other.privacyConsent == privacyConsent &&
      other.reminderPromptSeen == reminderPromptSeen;

  @override
  int get hashCode => Object.hash(
        languageCode,
        followPhoneLanguage,
        onboardingSeen,
        privacyConsent,
        reminderPromptSeen,
      );
}
