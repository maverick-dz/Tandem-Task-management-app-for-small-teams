import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/core/widgets/progress_bar.dart';
import 'package:tandem/features/onboarding/presentation/state/onboarding_controller.dart';
import 'package:tandem/features/onboarding/presentation/widgets/onboarding_page.dart';

/// Screen 002: three steps, "Skip" at any time, the main button at the bottom.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).markOnboardingSeen();
    if (mounted) context.go(RouteNames.privacy);
  }

  Future<void> _next() async {
    final flow = ref.read(onboardingProvider);
    if (flow.isLast) {
      await _finish();
      return;
    }
    ref.read(onboardingProvider.notifier).next();
    await _pages.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final flow = ref.watch(onboardingProvider);
    return AppScaffold(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  label: l10n.onboarding_step(flow.index + 1, flow.steps),
                  child: AppProgressBar(fraction: flow.progress),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppLinkButton(label: l10n.common_skip, onPressed: _finish),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: flow.steps,
              onPageChanged: ref.read(onboardingProvider.notifier).jumpTo,
              itemBuilder: (context, index) => OnboardingPage(index: index),
            ),
          ),
          AppButton(
            label: flow.isLast ? l10n.common_getStarted : l10n.common_continue,
            onPressed: _next,
          ),
        ],
      ),
    );
  }
}
