import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_bottom_sheet.dart';
import 'package:tandem/features/tasks/data/models/board_models.dart';

/// Screen 026: three statuses, one tap on the one you want. Returns the chosen
/// status, or null when the sheet is dismissed.
Future<TaskStatus?> showChangeStatusSheet(
  BuildContext context, {
  required TaskStatus current,
}) {
  return showAppSheet<TaskStatus>(
    context: context,
    builder: (sheetContext) => ChangeStatusContent(
      current: current,
      onSelect: (status) => Navigator.of(sheetContext).pop(status),
    ),
  );
}

class ChangeStatusContent extends StatelessWidget {
  const ChangeStatusContent({required this.current, required this.onSelect, super.key});

  final TaskStatus current;
  final ValueChanged<TaskStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    final labels = <TaskStatus, String>{
      TaskStatus.todo: l10n.tasks_statusTodo,
      TaskStatus.inProgress: l10n.tasks_statusInProgress,
      TaskStatus.done: l10n.tasks_statusDone,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(header: true, child: Text(l10n.tasks_changeStatus, style: type.heading(type.lg))),
        const SizedBox(height: AppSpacing.sm),
        for (final status in TaskStatus.values) ...<Widget>[
          _StatusOption(
            label: labels[status]!,
            selected: status == current,
            onTap: () => onSelect(status),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.input);
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.light,
          borderRadius: radius,
          border: Border.all(color: selected ? AppColors.accent : AppColors.rule),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(label, style: context.type.bodyMedium())),
                  if (selected)
                    const Icon(Icons.check_rounded, size: 20, color: AppColors.accentDeep),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
