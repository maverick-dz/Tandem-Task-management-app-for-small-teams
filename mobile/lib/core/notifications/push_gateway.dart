import 'package:firebase_messaging/firebase_messaging.dart';

/// The operating system side of push. The app only depends on this interface,
/// so that tests and developers without Firebase files still run.
abstract interface class PushGateway {
  /// Asks for the notification permission (Android 13+, iOS). True if allowed.
  Future<bool> requestPermission();

  Future<String?> token();

  Stream<String> get onTokenRefresh;
}

/// Used when push is not configured (`PUSH_ENABLED` is not set).
class NoopPushGateway implements PushGateway {
  const NoopPushGateway();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();
}

class FirebasePushGateway implements PushGateway {
  FirebasePushGateway([FirebaseMessaging? messaging])
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
