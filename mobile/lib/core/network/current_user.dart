import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_client.dart';

/// The signed-in person, from `GET /users/me`.
class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.language,
    this.consentVersion,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    final consent = json['consent'];
    return CurrentUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      language: json['language'] as String,
      consentVersion:
          consent is Map<String, dynamic> ? consent['policy_version'] as String? : null,
    );
  }

  final String id;
  final String email;
  final String fullName;
  final String language;

  /// Version of the privacy policy the person accepted, or null.
  final String? consentVersion;

  String get initial =>
      fullName.trim().isEmpty ? '?' : String.fromCharCode(fullName.trim().runes.first);
}

final currentUserProvider = FutureProvider<CurrentUser>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final response = await guardApi(() => dio.get<Map<String, dynamic>>('/users/me'));
  return CurrentUser.fromJson(response.data!);
});
