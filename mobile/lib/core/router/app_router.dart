import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/router/route_names.dart';
import 'package:tandem/features/notifications/presentation/screens/allow_reminders_screen.dart';
import 'package:tandem/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:tandem/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:tandem/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:tandem/features/settings/presentation/screens/feedback_screen.dart';
import 'package:tandem/features/settings/presentation/screens/language_screen.dart';
import 'package:tandem/features/settings/presentation/screens/privacy_consent_screen.dart';
import 'package:tandem/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:tandem/features/tasks/presentation/screens/board_screen.dart';

/// Owner: R. Created by M with the routes of M's screens, so the app starts;
/// R adds the guards and the routes of the sign-in, teams and tasks screens.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: <RouteBase>[
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RouteNames.privacy, builder: (_, __) => const PrivacyConsentScreen()),
      GoRoute(path: RouteNames.privacyPolicy, builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(
        path: RouteNames.allowReminders,
        builder: (_, __) => const AllowRemindersScreen(),
      ),
      GoRoute(path: RouteNames.language, builder: (_, __) => const LanguageScreen()),
      GoRoute(path: RouteNames.editProfile, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: RouteNames.feedback, builder: (_, __) => const FeedbackScreen()),
      GoRoute(
        path: RouteNames.boardPattern,
        builder: (_, state) => BoardScreen(teamId: state.pathParameters['teamId']!),
      ),
      // Screens of teammates, until they land.
      for (final path in <String>[
        RouteNames.signIn,
        RouteNames.signUp,
        RouteNames.home,
        RouteNames.newTask,
        RouteNames.changePassword,
      ])
        GoRoute(path: path, builder: (_, __) => _Placeholder(path: path)),
    ],
  );
});

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('${context.l10n.appName}: $path')),
    );
  }
}
