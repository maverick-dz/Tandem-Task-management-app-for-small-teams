import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandem/core/router/app_router.dart';
import 'package:tandem/core/storage/storage_providers.dart';
import 'package:tandem/core/theme/app_theme.dart';
import 'package:tandem/l10n/app_localizations.dart';

/// The app: router, theme, and the language (the phone's, or the one chosen).
class TandemApp extends ConsumerWidget {
  const TandemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(settingsProvider.select((s) => s.forcedLanguageCode));
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      locale: code == null ? null : Locale(code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: buildAppTheme(code ?? 'en'),
      // The fonts follow the language actually in use, also when it is the phone's.
      builder: (context, child) => Theme(
        data: buildAppTheme(Localizations.localeOf(context).languageCode),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
