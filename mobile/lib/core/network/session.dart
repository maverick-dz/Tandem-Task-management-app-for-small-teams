import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/notifications/push_registration.dart';
import 'package:tandem/core/storage/storage_providers.dart';

class SessionState {
  const SessionState({this.restored = false, this.signedIn = false});

  /// False until the stored token has been looked up at launch.
  final bool restored;
  final bool signedIn;
}

/// Who is signed in. The sign-in screens (R) call [signIn] with the token the
/// API returns; the sign-out dialog (M) calls [signOut].
class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Future<void> restore() async {
    final token = await ref.read(tokenStorageProvider).read();
    state = SessionState(restored: true, signedIn: token != null);
  }

  Future<void> signIn(String token) async {
    await ref.read(tokenStorageProvider).write(token);
    state = const SessionState(restored: true, signedIn: true);
  }

  /// Unregisters the phone from push first, so the next owner of the phone gets
  /// nothing meant for you, then forgets the token.
  Future<void> signOut() async {
    try {
      await ref.read(pushRegistrationProvider).unregister();
    } on Object {
      // best effort: a failed unregister must never keep someone signed in
    }
    await expire();
  }

  /// The token is no longer valid (401) or the person signed out.
  Future<void> expire() async {
    await ref.read(tokenStorageProvider).clear();
    state = const SessionState(restored: true, signedIn: false);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
