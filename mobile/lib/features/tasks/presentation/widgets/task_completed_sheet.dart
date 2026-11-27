import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/utils/date_text.dart';
import 'package:tandem/core/widgets/app_bottom_sheet.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_text.dart';
import 'package:tandem/core/widgets/date_stamp.dart';
import 'package:tandem/core/widgets/progress_bar.dart';

/// Screen 027: a calm confirmation with the "done" stamp, the new team
/// progress, and "Undo". Returns true when the person chose Undo.
Future<bool?> showTaskCompletedSheet(
  BuildContext context, {
  required String taskTitle,
  required String personName,
  required DateTime completedAt,
  required int done,
  required int total,
}) {
  return showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => TaskCompletedContent(
      taskTitle: taskTitle,
      personName: personName,
      completedAt: completedAt,
      done: done,
      total: total,
      onBack: () => Navigator.of(sheetContext).pop(false),
      onUndo: () => Navigator.of(sheetContext).pop(true),
    ),
  );
}

class TaskCompletedContent extends StatelessWidget {
  const TaskCompletedContent({
    required this.taskTitle,
    required this.personName,
    required this.completedAt,
    required this.done,
    required this.total,
    required this.onBack,
    required this.onUndo,
    super.key,
  });

  final String taskTitle;
  final String personName;
  final DateTime completedAt;
  final int done;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    final dates = DateText.fromArb(
      weekdaysShort: l10n.common_weekdaysShort,
      monthsShort: l10n.common_monthsShort,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: DateStamp(
              lines: <String>[l10n.tasks_doneLabel, dates.time(completedAt.toLocal())],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(l10n.tasks_doneTitle(taskTitle), style: type.heading(type.lg)),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(l10n.tasks_doneBody(personName, done, total), style: type.caption()),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(fraction: total == 0 ? 0 : done / total),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: l10n.tasks_backToTasks, onPressed: onBack),
        Center(child: AppLinkButton(label: l10n.tasks_undo, onPressed: onUndo)),
      ],
    );
  }
}
