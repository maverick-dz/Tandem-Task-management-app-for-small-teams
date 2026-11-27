import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/session.dart';
import 'package:tandem/core/storage/app_language.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';
import 'package:tandem/core/widgets/app_scaffold.dart';
import 'package:tandem/features/settings/data/profile_repository.dart';

/// Screen 053: follow the phone language, or pick one of the three.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  Future<void> _select(WidgetRef ref, AppLanguage language) async {
    await ref.read(settingsProvider.notifier).selectLanguage(language.code);
    if (!ref.read(sessionProvider).signedIn) return;
    try {
      // So that push messages arrive in the same language as the app.
      await ref.read(profileRepositoryProvider).setLanguage(language.code);
    } on Object {
      // Offline: the choice is kept on the phone and still applies to the app.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final type = context.type;
    final settings = ref.watch(settingsProvider);
    final effective = settings.forcedLanguageCode ?? Localizations.localeOf(context).languageCode;
    final subtitles = <AppLanguage, String>{
      AppLanguage.arabic: l10n.settings_languageArabicSub,
      AppLanguage.french: l10n.settings_languageFrenchSub,
      AppLanguage.english: l10n.settings_languageEnglishSub,
    };

    return AppScaffold(
      title: l10n.settings_languageTitle,
      onBack: context.pop,
      body: ListView(
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(l10n.settings_usePhoneLanguage, style: type.body())),
                Switch(
                  value: settings.followPhoneLanguage,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setFollowPhoneLanguage(value: value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final language in AppLanguage.values) ...<Widget>[
            _LanguageOption(
              name: language.nativeName,
              subtitle: subtitles[language]!,
              selected: language.code == effective,
              onTap: () => _select(ref, language),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.settings_languageNote, style: type.caption()),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final radius = BorderRadius.circular(AppRadius.input);
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: '$name, $subtitle',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.light,
          borderRadius: radius,
          border: Border.all(color: selected ? AppColors.accent : AppColors.rule),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name, style: type.bodyMedium()),
                        Text(subtitle, style: type.caption()),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_rounded, size: 20, color: AppColors.accentDeep),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
