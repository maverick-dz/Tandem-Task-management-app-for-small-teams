import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/session.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/progress_bar.dart';
import 'package:tandem/features/onboarding/presentation/state/splash_decision.dart';
import 'package:tandem/features/onboarding/presentation/widgets/app_icon_tile.dart';

/// Screen 001. Shows the icon while the stored sign-in is looked up, then goes
/// on to the right first screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.minimumDuration = const Duration(milliseconds: 1200)});

  /// The splash stays at least this long, so that it never flashes.
  final Duration minimumDuration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.minimumDuration,
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final restore = ref.read(sessionProvider.notifier).restore();
    await Future.wait<void>(<Future<void>>[restore, _progress.forward()]);
    if (!mounted) return;
    final route = nextRouteAfterSplash(
      settings: ref.read(settingsProvider),
      signedIn: ref.read(sessionProvider).signedIn,
    );
    context.go(route);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const AppIconTile(),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.appName, style: type.heading(type.xxxl)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.common_tagline, style: type.caption()),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => AppProgressBar(fraction: _progress.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
