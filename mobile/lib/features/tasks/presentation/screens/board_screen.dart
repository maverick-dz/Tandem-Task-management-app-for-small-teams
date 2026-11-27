import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/api_error.dart';
import 'package:tandem/core/network/connectivity.dart';
import 'package:tandem/core/network/current_user.dart';
import 'package:tandem/core/network/error_messages.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/utils/date_text.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/core/widgets/app_text.dart';
import 'package:tandem/core/widgets/avatar_initial.dart';
import 'package:tandem/core/widgets/info_banner.dart';
import 'package:tandem/core/widgets/loading_skeleton.dart';
import 'package:tandem/core/widgets/offline_banner.dart';
import 'package:tandem/features/tasks/data/board_repository.dart';
import 'package:tandem/features/tasks/data/models/board_models.dart';
import 'package:tandem/features/tasks/presentation/state/board_columns.dart';
import 'package:tandem/features/tasks/presentation/state/board_controller.dart';
import 'package:tandem/features/tasks/presentation/widgets/change_status_sheet.dart';
import 'package:tandem/features/tasks/presentation/widgets/task_completed_sheet.dart';

/// Screen 036 (a "should have" feature, spec F10): the same tasks as three
/// columns. Long-press and drag a card to move it, or tap it for the status sheet.
class BoardScreen extends ConsumerWidget {
  const BoardScreen({required this.teamId, super.key});

  final String teamId;

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    CurrentUser user,
    BoardCardModel card,
    TaskStatus to,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(boardControllerProvider(teamId).notifier);
    final outcome = await controller.move(cardId: card.id, to: to, currentUserId: user.id);

    switch (outcome.result) {
      case MoveResult.moved:
        final change = outcome.change;
        if (to != TaskStatus.done || change == null || !context.mounted) return;
        final progress = ref.read(boardControllerProvider(teamId)).value?.board.progress;
        final undo = await showTaskCompletedSheet(
          context,
          taskTitle: card.title,
          personName: user.fullName,
          completedAt: change.completedAt ?? DateTime.now(),
          done: progress?.done ?? 0,
          total: progress?.total ?? 0,
        );
        if (undo ?? false) {
          await controller.move(cardId: card.id, to: card.status, currentUserId: user.id);
        }
      case MoveResult.notAllowed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.tasks_cannotMoveCard)));
      case MoveResult.conflict:
      case MoveResult.failed:
        final error = outcome.error;
        messenger.showSnackBar(
          SnackBar(
            content: Text(error == null ? l10n.common_couldNotSave : apiErrorMessage(l10n, error)),
          ),
        );
    }
  }

  Future<void> _openStatusSheet(
    BuildContext context,
    WidgetRef ref,
    CurrentUser user,
    BoardCardModel card,
  ) async {
    final chosen = await showChangeStatusSheet(context, current: card.status);
    if (chosen == null || chosen == card.status || !context.mounted) return;
    await _move(context, ref, user, card, chosen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    final board = ref.watch(boardControllerProvider(teamId));
    final offline = ref.watch(isOnlineProvider).value == false;

    Widget failure(Object error) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InfoBanner(
              text: error is ApiError ? apiErrorMessage(l10n, error) : l10n.common_loadFailed,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.common_retry,
              variant: AppButtonVariant.secondary,
              onPressed: () => ref.read(boardControllerProvider(teamId).notifier).refresh(),
            ),
          ],
        );

    return AppScaffold(
      title: l10n.tasks_boardTitle,
      onBack: context.canPop() ? context.pop : null,
      body: user.when(
        loading: () => const LoadingSkeleton(),
        error: (error, _) => failure(error),
        data: (me) => board.when(
          loading: () => const LoadingSkeleton(),
          error: (error, _) => failure(error),
          data: (load) => _BoardBody(
            load: load,
            offline: offline,
            currentUserId: me.id,
            onDrop: (card, to) => _move(context, ref, me, card, to),
            onTapCard: (card) => _openStatusSheet(context, ref, me, card),
          ),
        ),
      ),
    );
  }
}

class _BoardBody extends StatelessWidget {
  const _BoardBody({
    required this.load,
    required this.offline,
    required this.currentUserId,
    required this.onDrop,
    required this.onTapCard,
  });

  final BoardLoad load;
  final bool offline;
  final String currentUserId;
  final void Function(BoardCardModel card, TaskStatus to) onDrop;
  final ValueChanged<BoardCardModel> onTapCard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = <TaskStatus, String>{
      TaskStatus.todo: l10n.tasks_statusTodo,
      TaskStatus.inProgress: l10n.tasks_statusInProgress,
      TaskStatus.done: l10n.tasks_statusDone,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (load.fromCache || offline) ...<Widget>[
          const OfflineBanner(),
          const SizedBox(height: AppSpacing.sm),
        ],
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              for (final status in TaskStatus.values)
                _BoardColumn(
                  title: labels[status]!,
                  status: status,
                  cards: load.board.column(status),
                  currentUserId: currentUserId,
                  onDrop: onDrop,
                  onTapCard: onTapCard,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.title,
    required this.status,
    required this.cards,
    required this.currentUserId,
    required this.onDrop,
    required this.onTapCard,
  });

  final String title;
  final TaskStatus status;
  final List<BoardCardModel> cards;
  final String currentUserId;
  final void Function(BoardCardModel card, TaskStatus to) onDrop;
  final ValueChanged<BoardCardModel> onTapCard;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: SizedBox(
        width: 272,
        child: DragTarget<BoardCardModel>(
          onWillAcceptWithDetails: (details) => details.data.status != status,
          onAcceptWithDetails: (details) => onDrop(details.data, status),
          builder: (context, candidates, rejected) {
            final hovering = candidates.isNotEmpty;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.paper3,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: hovering ? AppColors.accent : AppColors.paper3,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(title, style: type.heading(type.lg)),
                          ),
                        ),
                        _Tag(text: '${cards.length}', background: AppColors.light),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) => _CardSlot(
                          card: cards[i],
                          canMove: canMoveCard(cards[i], currentUserId),
                          onTap: () => onTapCard(cards[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardSlot extends StatelessWidget {
  const _CardSlot({required this.card, required this.canMove, required this.onTap});

  final BoardCardModel card;
  final bool canMove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = _BoardCard(card: card, onTap: canMove ? onTap : null);
    if (!canMove) return tile;
    return LongPressDraggable<BoardCardModel>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 248, child: tile),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: tile,
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.card, required this.onTap});

  final BoardCardModel card;
  final VoidCallback? onTap;

  static const List<Color> _tints = <Color>[
    AppColors.tintRose,
    AppColors.tintSand,
    AppColors.tintSky,
    AppColors.tintLilac,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    final dates = DateText.fromArb(
      weekdaysShort: l10n.common_weekdaysShort,
      monthsShort: l10n.common_monthsShort,
    );
    final assignee = card.assignee;
    final tint = assignee == null
        ? AppColors.paper3
        : _tints[assignee.id.codeUnits.fold<int>(0, (a, b) => a + b) % _tints.length];

    final Widget when;
    if (card.isOverdue) {
      when = _Tag(text: l10n.tasks_overdueTag, background: AppColors.late);
    } else if (card.dueTomorrow) {
      when = _Tag(text: l10n.tasks_dueTomorrowTag, background: AppColors.paper3);
    } else {
      when = AppText(dates.stub(card.deadline.toLocal()), style: type.mono());
    }

    final radius = BorderRadius.circular(AppRadius.card);
    return Semantics(
      button: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: radius,
          border: Border.all(color: AppColors.rule),
          boxShadow: AppShadows.card,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(card.title, style: type.bodyMedium()),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    AvatarInitial(initial: _initial(assignee), tint: tint),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(assignee?.fullName ?? '', style: type.caption()),
                    ),
                    when,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _initial(BoardAssignee? assignee) {
    final name = assignee?.fullName.trim() ?? '';
    return name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.background});

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        child: AppText(
          text,
          style: context.type.bodyMedium(size: context.type.xs, color: AppColors.ink2),
        ),
      ),
    );
  }
}
