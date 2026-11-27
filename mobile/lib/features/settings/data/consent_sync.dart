import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/features/settings/data/profile_repository.dart';

/// The privacy consent is given before an account exists (screen 054), so it is
/// kept on the phone first. Call [syncAfterSignIn] right after sign in or sign
/// up (R's screens) to record it on the server. Safe to call every time.
class ConsentSync {
  ConsentSync(this._ref);

  final Ref _ref;

  Future<void> syncAfterSignIn() async {
    if (!_ref.read(settingsProvider).privacyConsent) return;
    final repository = _ref.read(profileRepositoryProvider);
    final version = await repository.policyVersion();
    await repository.recordConsent(version);
  }
}

final consentSyncProvider = Provider<ConsentSync>(ConsentSync.new);
