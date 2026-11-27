import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_text.dart';

/// The double-ringed "Done" stamp of the design: turned two degrees, with the
/// time written under the word.
class DateStamp extends StatelessWidget {
  const DateStamp({required this.lines, super.key});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final style = context.type.mono(size: context.type.xs, color: AppColors.accentDeep);
    return Semantics(
      label: lines.join(' '),
      excludeSemantics: true,
      child: Transform.rotate(
        angle: 2 * math.pi / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: AppColors.light, spreadRadius: 3),
              BoxShadow(color: AppColors.accent, spreadRadius: 4.5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final line in lines) AppText(line, style: style, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
