import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';

/// Grey placeholder rows in the shape of task rows (screen 055). Still on
/// purpose: no shimmer, so that it is calm and cheap on low-end phones.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.rows = 3, this.semanticsLabel});

  final int rows;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? context.l10n.common_loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            for (var i = 0; i < rows; i++) ...<Widget>[
              SkeletonCard(widthFactor: 0.8 - i * 0.12),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

/// One skeleton row: a box, a circle and two lines.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.widthFactor = 0.7});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.rule),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            const _Block(width: 28, height: 28, radius: 8),
            const SizedBox(width: AppSpacing.sm),
            const _Block(width: 32, height: 32, radius: AppRadius.pill),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FractionallySizedBox(
                    widthFactor: widthFactor.clamp(0.2, 1.0),
                    child: const _Block(height: 10, radius: 5),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const FractionallySizedBox(
                    widthFactor: 0.35,
                    child: _Block(height: 10, radius: 5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, required this.radius, this.width});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.paper3,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
