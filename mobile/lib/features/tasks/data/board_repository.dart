import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_client.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/core/storage/json_cache.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/features/tasks/data/models/board_models.dart';

/// A board, and whether it came from the phone's copy instead of the server.
class BoardLoad {
  const BoardLoad({required this.board, this.fromCache = false});

  final BoardModel board;

  /// True when the phone was offline and the last loaded board is shown.
  final bool fromCache;

  BoardLoad copyWith({BoardModel? board}) =>
      BoardLoad(board: board ?? this.board, fromCache: fromCache);
}

/// The board and status calls of the API (`task_status.py`).
class BoardRepository {
  BoardRepository({required Dio dio, required JsonCache cache})
      : _dio = dio,
        _cache = cache;

  final Dio _dio;
  final JsonCache _cache;

  static String _key(String teamId) => 'board.$teamId';

  /// Loads the board. With no connection it falls back to the last copy
  /// (spec 5.1: the list opens without a network).
  Future<BoardLoad> loadBoard(String teamId) async {
    try {
      final response = await guardApi(
        () => _dio.get<Map<String, dynamic>>('/teams/$teamId/board'),
      );
      final data = response.data!;
      await _cache.write(_key(teamId), data);
      return BoardLoad(board: BoardModel.fromJson(data));
    } on ApiError catch (error) {
      if (!error.isNetwork) rethrow;
      final cached = await _cache.read(_key(teamId));
      if (cached is Map<String, dynamic>) {
        return BoardLoad(board: BoardModel.fromJson(cached), fromCache: true);
      }
      rethrow;
    }
  }

  /// One tap or one move. [version] is the version the person saw, so that two
  /// people changing the same task do not silently overwrite each other.
  Future<StatusChangeResult> changeStatus({
    required String taskId,
    required TaskStatus status,
    int? version,
  }) async {
    final response = await guardApi(
      () => _dio.patch<Map<String, dynamic>>(
        '/tasks/$taskId/status',
        data: <String, dynamic>{
          'status': status.apiValue,
          if (version != null) 'version': version,
        },
      ),
    );
    return StatusChangeResult.fromJson(response.data!);
  }
}

final boardRepositoryProvider = Provider<BoardRepository>(
  (ref) => BoardRepository(
    dio: ref.watch(dioProvider),
    cache: ref.watch(jsonCacheProvider),
  ),
);
