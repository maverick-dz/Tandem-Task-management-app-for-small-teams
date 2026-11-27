import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// A round avatar with an initial. The tint identifies a person, never a state.
class AvatarInitial extends StatelessWidget {
  const AvatarInitial({
    required this.initial,
    required this.tint,
    super.key,
    this.size = 32,
  });

  final String initial;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: tint),
        child: Text(
          initial,
          style: context.type.heading(size * 0.44, color: AppColors.ink),
        ),
      ),
    );
  }
}
