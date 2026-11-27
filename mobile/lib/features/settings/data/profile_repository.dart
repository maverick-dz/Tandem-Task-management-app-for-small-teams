import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_client.dart';
import 'package:tandem/core/network/current_user.dart';

/// Profile calls of the API (`users.py`).
class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  /// Edit profile (screen 057). Only the fields given are changed.
  Future<CurrentUser> updateProfile({String? fullName, String? email}) async {
    final response = await guardApi(
      () => _dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: <String, String>{
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
        },
      ),
    );
    return CurrentUser.fromJson(response.data!);
  }

  /// Also the language of push messages.
  Future<void> setLanguage(String code) => guardApi(
        () => _dio.put<void>('/users/me/language', data: <String, String>{'language': code}),
      );

  /// Idempotent on the server, so it is safe to call after every sign in.
  Future<void> recordConsent(String policyVersion) => guardApi(
        () => _dio.post<void>(
          '/users/me/consent',
          data: <String, String>{'policy_version': policyVersion},
        ),
      );

  Future<String> policyVersion() async {
    final response = await guardApi(
      () => _dio.get<Map<String, dynamic>>('/users/policy-version'),
    );
    return response.data!['policy_version'] as String;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);
