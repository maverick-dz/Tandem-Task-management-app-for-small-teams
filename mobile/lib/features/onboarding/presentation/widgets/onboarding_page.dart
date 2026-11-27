import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_text.dart';
import 'package:tandem/core/widgets/avatar_initial.dart';
import 'package:tandem/core/widgets/progress_bar.dart';

/// One onboarding step: a small picture of the product, a title, a sentence.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    final (title, body) = switch (index) {
      0 => (l10n.onboarding_title1, l10n.onboarding_body1),
      1 => (l10n.onboarding_title2, l10n.onboarding_body2),
      _ => (l10n.onboarding_title3, l10n.onboarding_body3),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Center(
            child: switch (index) {
              0 => const _OwnerPreview(),
              1 => const _ProgressPreview(),
              _ => const _ReminderPreview(),
            },
          ),
        ),
        Semantics(header: true, child: Text(title, style: type.heading(type.xxl))),
        const SizedBox(height: AppSpacing.md),
        Text(body, style: type.body(color: AppColors.ink2)),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.rule),
        ),
        child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
      ),
    );
  }
}

/// Three rows, each with one owner and one date.
class _OwnerPreview extends StatelessWidget {
  const _OwnerPreview();

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    Widget row(String initial, Color tint, String title, String date) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _PreviewCard(
            child: Row(
              children: <Widget>[
                AvatarInitial(initial: initial, tint: tint),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(title, style: type.bodyMedium())),
                AppText(date, style: type.mono()),
              ],
            ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row('L', AppColors.tintRose, 'Book the room', 'Mon 26'),
        row('S', AppColors.tintSand, 'Draft survey', 'Fri 30'),
        row('Y', AppColors.tintLilac, 'Budget sheet', 'Wed 28'),
      ],
    );
  }
}

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview();

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final l10n = context.l10n;
    return _PreviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.tasks_statusDone, style: type.label()),
          const SizedBox(height: AppSpacing.xs),
          AppText(l10n.tasks_progressCount(12, 20), style: type.heading(type.xl)),
          const SizedBox(height: AppSpacing.sm),
          const AppProgressBar(fraction: 0.6),
        ],
      ),
    );
  }
}

class _ReminderPreview extends StatelessWidget {
  const _ReminderPreview();

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return _PreviewCard(
      child: Row(
        children: <Widget>[
          const Icon(Icons.notifications_none_rounded, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(context.l10n.onboarding_title3, style: type.bodyMedium()),
          ),
        ],
      ),
    );
  }
}
