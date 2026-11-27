import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

enum AppButtonVariant { primary, secondary }

/// The moulded button of the design: 52 points high, a rim below it.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final primary = variant == AppButtonVariant.primary;
    final enabled = onPressed != null && !isLoading;
    final foreground = primary ? AppColors.accentInk : AppColors.ink;
    final radius = BorderRadius.circular(AppRadius.input);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: primary
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[AppColors.accent, AppColors.accentDeep],
                  )
                : null,
            color: primary ? null : AppColors.light,
            border: Border.all(
              color: primary ? AppColors.accentDeep : AppColors.rule,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: primary ? AppColors.accentDeep : AppColors.rule,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                        )
                      else ...<Widget>[
                        if (icon != null) ...<Widget>[
                          Icon(icon, size: 20, color: foreground),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: type.bodyMedium(color: foreground),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An underlined text link with a 44 point tap target.
class AppLinkButton extends StatelessWidget {
  const AppLinkButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, AppSpacing.minTap),
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.accentDeep,
      ),
      child: Text(
        label,
        style: context.type.bodyMedium(color: AppColors.accentDeep).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accentDeep,
            ),
      ),
    );
  }
}
