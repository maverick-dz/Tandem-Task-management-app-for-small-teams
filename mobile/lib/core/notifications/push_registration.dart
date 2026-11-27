import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_client.dart';
import 'package:tandem/core/notifications/push_gateway.dart';

/// `--dart-define=PUSH_ENABLED=true` once `google-services.json` is in place.
const bool pushEnabled = bool.fromEnvironment('PUSH_ENABLED');

/// Keeps the backend's `device_tokens` table in step with this phone.
class PushRegistration {
  PushRegistration({
    required this.dio,
    required this.gateway,
    required this.platform,
  });

  final Dio dio;
  final PushGateway gateway;

  /// `android` or `ios`, as the backend expects.
  final String platform;

  String? _registered;
  StreamSubscription<String>? _refresh;

  Future<bool> requestPermission() => gateway.requestPermission();

  /// Call after sign-in. Also follows Firebase token rotation.
  Future<void> register() async {
    final token = await gateway.token();
    if (token == null) return;
    await _send(token);
    _refresh ??= gateway.onTokenRefresh.listen((t) => unawaited(_send(t)));
  }

  /// Call on sign out, while the access token still works.
  Future<void> unregister() async {
    await _refresh?.cancel();
    _refresh = null;
    final token = _registered ?? await gateway.token();
    if (token == null) return;
    await guardApi(
      () => dio.delete<void>(
        '/notifications/device-tokens',
        data: <String, String>{'token': token},
      ),
    );
    _registered = null;
  }

  Future<void> _send(String token) async {
    await guardApi(
      () => dio.put<void>(
        '/notifications/device-tokens',
        data: <String, String>{'token': token, 'platform': platform},
      ),
    );
    _registered = token;
  }
}

final pushGatewayProvider = Provider<PushGateway>(
  (ref) => pushEnabled ? FirebasePushGateway() : const NoopPushGateway(),
);

final pushRegistrationProvider = Provider<PushRegistration>(
  (ref) => PushRegistration(
    dio: ref.watch(dioProvider),
    gateway: ref.watch(pushGatewayProvider),
    platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
  ),
);
