import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/features/tasks/data/board_repository.dart';
import 'package:tandem/features/tasks/data/models/board_models.dart';
import 'package:tandem/features/tasks/presentation/state/board_columns.dart';

enum MoveResult { moved, notAllowed, conflict, failed }

/// What happened to a move, and the error behind a failure.
class MoveOutcome {
  const MoveOutcome(this.result, {this.error, this.change});

  final MoveResult result;
  final ApiError? error;

  /// The server's answer, for the "done" stamp (its time).
  final StatusChangeResult? change;
}

/// The board of one team. A move is shown at once and taken back if the
/// server refuses it.
class BoardController extends AsyncNotifier<BoardLoad> {
  BoardController(this.teamId);

  final String teamId;

  @override
  Future<BoardLoad> build() => ref.read(boardRepositoryProvider).loadBoard(teamId);

  Future<void> refresh() async {
    state = const AsyncLoading<BoardLoad>();
    state = await AsyncValue.guard(() => ref.read(boardRepositoryProvider).loadBoard(teamId));
  }

  Future<MoveOutcome> move({
    required String cardId,
    required TaskStatus to,
    required String currentUserId,
  }) async {
    final current = state.value;
    final card = current?.board.cardById(cardId);
    if (current == null || card == null) return const MoveOutcome(MoveResult.failed);
    if (!canMoveCard(card, currentUserId)) return const MoveOutcome(MoveResult.notAllowed);
    if (card.status == to) return const MoveOutcome(MoveResult.moved);

    state = AsyncData<BoardLoad>(current.copyWith(board: moveCard(current.board, cardId, to)));
    try {
      final change = await ref.read(boardRepositoryProvider).changeStatus(
            taskId: cardId,
            status: to,
            version: card.version,
          );
      final latest = state.value ?? current;
      state = AsyncData<BoardLoad>(latest.copyWith(board: applyResult(latest.board, change)));
      return MoveOutcome(MoveResult.moved, change: change);
    } on ApiError catch (error) {
      state = AsyncData<BoardLoad>(current); // take the move back
      if (error.kind == ApiErrorKind.taskConflict) {
        await refresh(); // someone else changed it first: show their version
        return MoveOutcome(MoveResult.conflict, error: error);
      }
      return MoveOutcome(MoveResult.failed, error: error);
    }
  }
}

final boardControllerProvider =
    AsyncNotifierProvider.family<BoardController, BoardLoad, String>(BoardController.new);
