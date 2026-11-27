import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The position in the three onboarding steps. Immutable, so it is easy to test.
class OnboardingFlow {
  const OnboardingFlow({this.index = 0, this.steps = 3});

  final int index;
  final int steps;

  bool get isLast => index == steps - 1;

  /// From 1/steps on the first page to 1 on the last.
  double get progress => (index + 1) / steps;

  OnboardingFlow next() => isLast ? this : OnboardingFlow(index: index + 1, steps: steps);

  /// Follows the page view when the person swipes.
  OnboardingFlow jumpTo(int page) =>
      OnboardingFlow(index: page.clamp(0, steps - 1), steps: steps);
}

class OnboardingNotifier extends Notifier<OnboardingFlow> {
  @override
  OnboardingFlow build() => const OnboardingFlow();

  void next() => state = state.next();

  void jumpTo(int page) => state = state.jumpTo(page);
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingFlow>(
  OnboardingNotifier.new,
);
