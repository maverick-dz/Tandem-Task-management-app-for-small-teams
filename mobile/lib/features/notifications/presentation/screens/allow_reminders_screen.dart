import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/notifications/push_registration.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';

/// Screen 056: asked once, after the first sign in, never at launch. Declining
/// is fine: deadlines stay visible in the app and the Alerts list still fills.
class AllowRemindersScreen extends ConsumerStatefulWidget {
  const AllowRemindersScreen({super.key});

  @override
  ConsumerState<AllowRemindersScreen> createState() => _AllowRemindersScreenState();
}

class _AllowRemindersScreenState extends ConsumerState<AllowRemindersScreen> {
  bool _busy = false;

  Future<void> _allow() async {
    setState(() => _busy = true);
    final push = ref.read(pushRegistrationProvider);
    try {
      final granted = await push.requestPermission();
      if (granted) await push.register();
    } on Object {
      // Push is a convenience: a failure here must not trap the person.
    }
    await _leave();
  }

  Future<void> _leave() async {
    await ref.read(settingsProvider.notifier).markReminderPromptSeen();
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentSoft,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 32,
                      color: AppColors.accentDeep,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.notifications_allowTitle,
                      textAlign: TextAlign.center,
                      style: type.heading(type.xxl),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.notifications_allowBody(l10n.appName),
                    textAlign: TextAlign.center,
                    style: type.caption(),
                  ),
                ],
              ),
            ),
          ),
          AppButton(
            label: l10n.notifications_allowAction,
            onPressed: _busy ? null : _allow,
            isLoading: _busy,
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: AppLinkButton(
              label: l10n.notifications_allowNotNow,
              onPressed: _busy ? null : _leave,
            ),
          ),
        ],
      ),
    );
  }
}
