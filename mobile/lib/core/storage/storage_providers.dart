import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/storage/app_settings.dart';
import 'package:tandem/core/storage/json_cache.dart';
import 'package:tandem/core/storage/settings_store.dart';
import 'package:tandem/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SharedPreferencesSettingsStore(),
);

final jsonCacheProvider = Provider<JsonCache>((ref) => SharedPreferencesJsonCache());

/// Loaded once in `main()` before the first frame, so the language is right
/// from the first screen. Tests override it.
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());

/// Preferences of the device. Every change is saved straight away.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> _update(AppSettings next) {
    state = next;
    return ref.read(settingsStoreProvider).save(next);
  }

  Future<void> selectLanguage(String code) =>
      _update(state.copyWith(languageCode: code, followPhoneLanguage: false));

  Future<void> setFollowPhoneLanguage({required bool value}) =>
      _update(state.copyWith(followPhoneLanguage: value));

  Future<void> markOnboardingSeen() =>
      _update(state.copyWith(onboardingSeen: true));

  Future<void> acceptPrivacy() => _update(state.copyWith(privacyConsent: true));

  Future<void> markReminderPromptSeen() =>
      _update(state.copyWith(reminderPromptSeen: true));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
