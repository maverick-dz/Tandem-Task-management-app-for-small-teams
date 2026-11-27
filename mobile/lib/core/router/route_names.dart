/// Route names are the contract between features: a feature navigates with
/// these constants and never imports another feature's screens.
///
/// Created by M for the screens M builds. R owns this folder and extends it.
abstract final class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String privacy = '/privacy';
  static const String privacyPolicy = '/privacy/policy';
  static const String allowReminders = '/allow-reminders';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String newTask = '/tasks/new';
  static const String language = '/settings/language';
  static const String editProfile = '/settings/profile';
  static const String changePassword = '/settings/password';
  static const String feedback = '/settings/feedback';

  /// `/teams/:teamId/board`
  static const String boardPattern = '/teams/:teamId/board';

  static String board(String teamId) => '/teams/$teamId/board';
}
