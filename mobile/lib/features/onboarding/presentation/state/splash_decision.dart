import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/core/storage/app_settings.dart';

/// Where the app goes once the splash is over (screen 001).
///
/// First launch: onboarding, then privacy consent, then sign in. After that the
/// first screen after sign in asks about reminders once, then the home screen.
String nextRouteAfterSplash({
  required AppSettings settings,
  required bool signedIn,
}) {
  if (!settings.onboardingSeen) return RouteNames.onboarding;
  if (!settings.privacyConsent) return RouteNames.privacy;
  if (!signedIn) return RouteNames.signIn;
  if (!settings.reminderPromptSeen) return RouteNames.allowReminders;
  return RouteNames.home;
}
