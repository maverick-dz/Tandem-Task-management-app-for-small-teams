// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tandem';

  @override
  String common_appIconLabel(String appName) {
    return '$appName logo';
  }

  @override
  String get common_back => 'Back';

  @override
  String get common_close => 'Close';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_couldNotSave => 'Could not save. Check your connection and try again.';

  @override
  String get common_getStarted => 'Get started';

  @override
  String get common_loadFailed => 'Could not load the data.';

  @override
  String get common_loading => 'Loading';

  @override
  String get common_monthsShort => 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec';

  @override
  String get common_navHome => 'Home';

  @override
  String get common_navProgress => 'Progress';

  @override
  String get common_navTasks => 'Tasks';

  @override
  String get common_navTeam => 'Team';

  @override
  String get common_offlineBanner => 'No connection. You can read the tasks already loaded. Editing needs a connection.';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_tagline => 'Who does what, by when.';

  @override
  String get common_weekdaysShort => 'Mon|Tue|Wed|Thu|Fri|Sat|Sun';

  @override
  String get errors_emailTaken => 'This email is already used.';

  @override
  String get errors_forbidden => 'You are not allowed to do this.';

  @override
  String get errors_invalidCredentials => 'The email or password is not right. Try again, or reset your password.';

  @override
  String get errors_lastAdmin => 'Make another member an Admin before you leave.';

  @override
  String get errors_network => 'No connection. Check your network and try again.';

  @override
  String get errors_notAssignee => 'Only the assignee can change this task.';

  @override
  String get errors_planRequired => 'This is part of a paid plan.';

  @override
  String get errors_taskConflict => 'Someone changed this task first. It has been refreshed.';

  @override
  String get errors_taskNotFound => 'This task no longer exists.';

  @override
  String get errors_unauthenticated => 'Sign in to continue.';

  @override
  String get errors_unknown => 'Something went wrong. Try again.';

  @override
  String get errors_validation => 'Check the information and try again.';

  @override
  String get notifications_allowAction => 'Allow reminders';

  @override
  String notifications_allowBody(String appName) {
    return '$appName tells you when a task is assigned to you and before a deadline. You can change this in settings.';
  }

  @override
  String get notifications_allowNotNow => 'Not now';

  @override
  String get notifications_allowTitle => 'Allow reminders?';

  @override
  String get onboarding_body1 => 'One owner and one date for every task, in plain view of the team.';

  @override
  String get onboarding_body2 => 'The dashboard shows what is done, what is late and who has what.';

  @override
  String get onboarding_body3 => 'One reminder per task reaches you before the deadline, not after.';

  @override
  String onboarding_step(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboarding_title1 => 'Everyone sees who owns what';

  @override
  String get onboarding_title2 => 'Progress at a glance';

  @override
  String get onboarding_title3 => 'Reminded before it is due';

  @override
  String get settings_changePassword => 'Change password';

  @override
  String get settings_editProfileTitle => 'Edit profile';

  @override
  String get settings_email => 'Email';

  @override
  String get settings_emailInvalid => 'Enter a valid email address.';

  @override
  String get settings_feedbackAbout => 'What is it about?';

  @override
  String get settings_feedbackEmpty => 'Write a few words first.';

  @override
  String get settings_feedbackHint => 'Describe it in a few words';

  @override
  String get settings_feedbackIntro => 'Tell us what would help your team. We tell you when it is built.';

  @override
  String get settings_feedbackMessage => 'Your message';

  @override
  String get settings_feedbackSend => 'Send feedback';

  @override
  String get settings_feedbackThanks => 'Thank you. We have your message.';

  @override
  String get settings_feedbackTitle => 'Feedback';

  @override
  String get settings_fullName => 'Full name';

  @override
  String get settings_kindIdea => 'An idea';

  @override
  String get settings_kindOther => 'Something else';

  @override
  String get settings_kindProblem => 'A problem';

  @override
  String get settings_languageArabicSub => 'Arabic, right to left';

  @override
  String get settings_languageEnglishSub => 'English';

  @override
  String get settings_languageFrenchSub => 'French';

  @override
  String get settings_languageNote => 'Arabic switches every screen to a right-to-left layout.';

  @override
  String get settings_languageTitle => 'Language';

  @override
  String get settings_nameRequired => 'Enter your name.';

  @override
  String get settings_policyDelete => 'You can ask us to delete your account and data at any time.';

  @override
  String get settings_policyPush => 'Push notifications carry generic text, never a task title.';

  @override
  String get settings_policyServer => 'The data is stored on a server in Algeria.';

  @override
  String get settings_policyStored => 'Data we store: your name, your email, your team membership and your tasks.';

  @override
  String get settings_privacyAgree => 'Agree and continue';

  @override
  String get settings_privacyConsent => 'I agree to the processing of my personal data';

  @override
  String settings_privacyIntro(String appName) {
    return '$appName keeps only what it needs: your name, your email and the tasks in your teams.';
  }

  @override
  String get settings_privacyPolicyTitle => 'Privacy policy';

  @override
  String get settings_privacyReadPolicy => 'Read the full privacy policy';

  @override
  String get settings_privacyStorage => 'Your data is stored on a server in Algeria. Notifications never show task text. You can ask us to delete your account and data at any time.';

  @override
  String get settings_privacyTitle => 'Privacy and your data';

  @override
  String get settings_profileSaved => 'Profile saved.';

  @override
  String get settings_saveChanges => 'Save changes';

  @override
  String get settings_signOut => 'Sign out';

  @override
  String get settings_signOutBody => 'You will need your email and password to come back.';

  @override
  String settings_signOutTitle(String appName) {
    return 'Sign out of $appName?';
  }

  @override
  String get settings_staySignedIn => 'Stay signed in';

  @override
  String get settings_usePhoneLanguage => 'Use the phone language';

  @override
  String get tasks_backToTasks => 'Back to tasks';

  @override
  String get tasks_boardTitle => 'Board';

  @override
  String get tasks_cannotMoveCard => 'Only the assignee can move this card.';

  @override
  String get tasks_changeStatus => 'Change status';

  @override
  String tasks_doneBody(String name, int done, int total) {
    return 'Thank you, $name. The team is at $done of $total tasks.';
  }

  @override
  String get tasks_doneLabel => 'Done';

  @override
  String tasks_doneTitle(String title) {
    return '$title is done';
  }

  @override
  String get tasks_dueTomorrowTag => 'Due tomorrow';

  @override
  String get tasks_emptyBodyCreator => 'Tasks you own appear here with a date. Add one, or ask a teammate to assign you one.';

  @override
  String get tasks_emptyBodyMember => 'Tasks you own appear here with a date. Ask a Manager or an Admin to assign you one.';

  @override
  String get tasks_emptyTitle => 'Nothing assigned to you';

  @override
  String get tasks_labelDueTomorrow => 'due tomorrow';

  @override
  String get tasks_labelOverdue => 'overdue';

  @override
  String get tasks_loading => 'Loading tasks';

  @override
  String get tasks_newTask => 'New task';

  @override
  String get tasks_overdueTag => 'Overdue';

  @override
  String tasks_ownerWithLabel(String name, String label) {
    return '$name, $label';
  }

  @override
  String tasks_progressCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String get tasks_statusDone => 'Done';

  @override
  String get tasks_statusInProgress => 'In progress';

  @override
  String get tasks_statusTodo => 'To do';

  @override
  String get tasks_undo => 'Undo';
}
