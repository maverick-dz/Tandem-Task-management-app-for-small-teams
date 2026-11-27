import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_client.dart';

enum FeedbackKind {
  problem('problem'),
  idea('idea'),
  other('other');

  const FeedbackKind(this.apiValue);

  final String apiValue;
}

class FeedbackRepository {
  FeedbackRepository(this._dio);

  final Dio _dio;

  Future<void> send({required FeedbackKind kind, required String message}) => guardApi(
        () => _dio.post<void>(
          '/feedback',
          data: <String, String>{'kind': kind.apiValue, 'message': message.trim()},
        ),
      );
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepository(ref.watch(dioProvider)),
);
