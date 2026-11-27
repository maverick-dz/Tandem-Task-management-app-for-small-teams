import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// A neutral grey note. Grey, never red: the design reserves colour for state
/// that is good (mint) and keeps trouble calm.
class InfoBanner extends StatelessWidget {
  const InfoBanner({required this.text, super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.late,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: AppColors.lateInk),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(text, style: context.type.caption(color: AppColors.lateInk)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
