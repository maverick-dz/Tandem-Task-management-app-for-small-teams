import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/core/network/session.dart';
import 'package:tandem/core/storage/storage_providers.dart';

/// The FastAPI base URL. `10.0.2.2` is the host computer seen from the Android
/// emulator. Override with `--dart-define=API_BASE_URL=https://...`.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api/v1',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: <String, String>{'Accept': 'application/json'},
    ),
  );
  final storage = ref.watch(tokenStorageProvider);
  dio.interceptors.add(
    AuthInterceptor(
      readToken: storage.read,
      onUnauthorized: () => unawaited(ref.read(sessionProvider.notifier).expire()),
    ),
  );
  return dio;
});

/// Adds the bearer token, and tells the session when the server says 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readToken, required this.onUnauthorized});

  final Future<String?> Function() readToken;
  final void Function() onUnauthorized;

  /// Set `extra: {AuthInterceptor.skipRedirect: true}` on sign-in calls, whose
  /// 401 means "wrong password", not "session expired".
  static const String skipRedirect = 'skipAuthRedirect';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final expired = err.response?.statusCode == 401 &&
        err.requestOptions.extra[skipRedirect] != true;
    if (expired) onUnauthorized();
    handler.next(err);
  }
}

ApiError apiErrorFromDio(DioException error) {
  final response = error.response;
  if (response == null) return const ApiError.network(); // offline, timeout
  return ApiError.fromResponse(response.statusCode, response.data);
}

/// Runs a request and turns every Dio failure into an [ApiError].
Future<T> guardApi<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (error) {
    throw apiErrorFromDio(error);
  }
}
