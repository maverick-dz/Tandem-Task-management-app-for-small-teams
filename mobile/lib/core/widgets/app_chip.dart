import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// A choice "key" (a small moulded button). Mint means selected.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.input);
    final edge = selected ? AppColors.accent : AppColors.rule;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: selected ? AppColors.accentSoft : AppColors.light,
          border: Border.all(color: edge),
          boxShadow: <BoxShadow>[BoxShadow(color: edge, offset: const Offset(0, 2))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(label, style: context.type.bodyMedium()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
