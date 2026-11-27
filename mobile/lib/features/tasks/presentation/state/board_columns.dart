import 'package:tandem/features/tasks/data/models/board_models.dart';

/// Moving a card changes its status, under the same permissions as a status
/// change from the list (spec F10 and F4): only the assignee may do it.
bool canMoveCard(BoardCardModel card, String currentUserId) =>
    card.assignee?.id == currentUserId;

/// The board after [cardId] moved to [to]. Cards in a column stay sorted by
/// deadline. Unknown ids leave the board unchanged.
BoardModel moveCard(BoardModel board, String cardId, TaskStatus to) {
  final card = board.cardById(cardId);
  if (card == null || card.status == to) return board;

  List<BoardCardModel> without(List<BoardCardModel> list) =>
      <BoardCardModel>[for (final c in list) if (c.id != cardId) c];

  List<BoardCardModel> withMoved(List<BoardCardModel> list) {
    final next = <BoardCardModel>[...list, card.copyWith(status: to)]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return next;
  }

  List<BoardCardModel> column(TaskStatus status, List<BoardCardModel> list) {
    final cleaned = without(list);
    return status == to ? withMoved(cleaned) : cleaned;
  }

  return BoardModel(
    todo: column(TaskStatus.todo, board.todo),
    inProgress: column(TaskStatus.inProgress, board.inProgress),
    done: column(TaskStatus.done, board.done),
  );
}

/// Takes the server's answer into the board: the new version, and the flags
/// (a Done task is never overdue).
BoardModel applyResult(BoardModel board, StatusChangeResult result) {
  BoardCardModel update(BoardCardModel c) => c.id == result.id
      ? c.copyWith(
          status: result.status,
          version: result.version,
          isOverdue: result.isOverdue,
          dueTomorrow: result.dueTomorrow,
        )
      : c;
  return BoardModel(
    todo: <BoardCardModel>[for (final c in board.todo) update(c)],
    inProgress: <BoardCardModel>[for (final c in board.inProgress) update(c)],
    done: <BoardCardModel>[for (final c in board.done) update(c)],
  );
}
