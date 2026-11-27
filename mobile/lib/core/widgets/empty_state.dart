import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/loading_skeleton.dart';

/// An empty list: a dashed ghost row, a title, one sentence, and optionally the
/// one action that fixes it (screens 010 and 028).
class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.body, super.key, this.action});

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: CustomPaint(
                painter: _DashedRRectPainter(),
                child: const Padding(
                  padding: EdgeInsets.all(1.5),
                  child: SkeletonCard(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(title, textAlign: TextAlign.center, style: type.heading(type.lg)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(body, textAlign: TextAlign.center, style: type.caption()),
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.card)),
      );
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
