import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/session.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_button.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/features/settings/data/consent_sync.dart';

/// Screen 054: what is kept, where, and a consent the person gives before any
/// account exists (Law 18-07). The button stays off until the box is ticked.
class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  late bool _agreed = ref.read(settingsProvider).privacyConsent;
  bool _busy = false;

  Future<void> _agree() async {
    setState(() => _busy = true);
    await ref.read(settingsProvider.notifier).acceptPrivacy();
    final signedIn = ref.read(sessionProvider).signedIn;
    if (signedIn) {
      try {
        await ref.read(consentSyncProvider).syncAfterSignIn();
      } on Object {
        // It is synced again after the next sign in.
      }
    }
    if (!mounted) return;
    if (signedIn) {
      context.pop();
    } else {
      context.go(RouteNames.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = context.type;
    return AppScaffold(
      title: l10n.settings_privacyTitle,
      onBack: context.canPop() ? context.pop : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Text(l10n.settings_privacyIntro(l10n.appName), style: type.body()),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.settings_privacyStorage, style: type.caption()),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppLinkButton(
                    label: l10n.settings_privacyReadPolicy,
                    onPressed: () => context.push(RouteNames.privacyPolicy),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ConsentRow(
                  label: l10n.settings_privacyConsent,
                  value: _agreed,
                  onChanged: (value) => setState(() => _agreed = value),
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.settings_privacyAgree,
            onPressed: _agreed ? _agree : null,
            isLoading: _busy,
          ),
        ],
      ),
    );
  }
}

/// A 44 point tick box with its sentence.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: value ? AppColors.accentSoft : AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: value ? AppColors.accent : AppColors.muted,
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.accentDeep)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: context.type.body())),
            ],
          ),
        ),
      ),
    );
  }
}
