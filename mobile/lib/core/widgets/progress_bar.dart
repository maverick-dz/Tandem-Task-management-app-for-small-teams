import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';

/// Tasks done out of total. It fills from the start edge, so it mirrors in Arabic.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({required this.fraction, super.key, this.height = 10});

  /// 0 to 1; values outside are clamped.
  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    final value = fraction.clamp(0.0, 1.0);
    return Semantics(
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          height: height,
          child: ColoredBox(
            color: AppColors.paper3,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: const ColoredBox(color: AppColors.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
