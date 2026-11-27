import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_bottom_sheet.dart';
import 'package:tandem/core/widgets/app_button.dart';

/// A question with a safe primary answer and a secondary answer, shown in a
/// bottom sheet (sign out, delete a task). The safe answer is the primary button.
Future<bool?> showConfirmSheet({
  required BuildContext context,
  required String title,
  required String body,
  required String safeLabel,
  required String confirmLabel,
}) {
  return showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => ConfirmContent(
      title: title,
      body: body,
      safeLabel: safeLabel,
      confirmLabel: confirmLabel,
      onSafe: () => Navigator.of(sheetContext).pop(false),
      onConfirm: () => Navigator.of(sheetContext).pop(true),
    ),
  );
}

class ConfirmContent extends StatelessWidget {
  const ConfirmContent({
    required this.title,
    required this.body,
    required this.safeLabel,
    required this.confirmLabel,
    required this.onSafe,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String body;
  final String safeLabel;
  final String confirmLabel;
  final VoidCallback onSafe;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: Text(title, style: type.heading(type.lg))),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: type.caption()),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: safeLabel, onPressed: onSafe),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: confirmLabel,
          onPressed: onConfirm,
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}
