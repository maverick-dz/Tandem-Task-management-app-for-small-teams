import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/network/session.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/widgets/app_dialog.dart';

/// Screen 059. Asks first; "Stay signed in" is the primary button, so the safe
/// answer is the easy one. Returns true when the person signed out.
Future<bool> confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final confirmed = await showConfirmSheet(
    context: context,
    title: l10n.settings_signOutTitle(l10n.appName),
    body: l10n.settings_signOutBody,
    safeLabel: l10n.settings_staySignedIn,
    confirmLabel: l10n.settings_signOut,
  );
  if (confirmed != true) return false;
  await ref.read(sessionProvider.notifier).signOut();
  if (context.mounted) context.go(RouteNames.signIn);
  return true;
}
