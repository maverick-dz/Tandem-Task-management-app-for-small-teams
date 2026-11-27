import 'package:shared_preferences/shared_preferences.dart';
import 'package:tandem/core/storage/app_settings.dart';

abstract interface class SettingsStore {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  static const String _language = 'settings.language';
  static const String _followPhone = 'settings.followPhoneLanguage';
  static const String _onboarding = 'settings.onboardingSeen';
  static const String _consent = 'settings.privacyConsent';
  static const String _reminders = 'settings.reminderPromptSeen';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      languageCode: prefs.getString(_language),
      followPhoneLanguage: prefs.getBool(_followPhone) ?? true,
      onboardingSeen: prefs.getBool(_onboarding) ?? false,
      privacyConsent: prefs.getBool(_consent) ?? false,
      reminderPromptSeen: prefs.getBool(_reminders) ?? false,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final language = settings.languageCode;
    if (language == null) {
      await prefs.remove(_language);
    } else {
      await prefs.setString(_language, language);
    }
    await prefs.setBool(_followPhone, settings.followPhoneLanguage);
    await prefs.setBool(_onboarding, settings.onboardingSeen);
    await prefs.setBool(_consent, settings.privacyConsent);
    await prefs.setBool(_reminders, settings.reminderPromptSeen);
  }
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([this.settings = const AppSettings()]);

  AppSettings settings;
  int saveCount = 0;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    this.settings = settings;
    saveCount++;
  }
}
