import 'package:flutter/widgets.dart';
import 'package:tandem/l10n/app_localizations.dart';

/// `context.l10n.settings_signOut` instead of `AppLocalizations.of(context)!`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
