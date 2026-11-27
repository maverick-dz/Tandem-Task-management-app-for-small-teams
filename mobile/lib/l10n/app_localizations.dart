import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Tandem'**
  String get appName;

  /// No description provided for @common_appIconLabel.
  ///
  /// In en, this message translates to:
  /// **'{appName} logo'**
  String common_appIconLabel(String appName);

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your connection and try again.'**
  String get common_couldNotSave;

  /// No description provided for @common_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get common_getStarted;

  /// No description provided for @common_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the data.'**
  String get common_loadFailed;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get common_loading;

  /// No description provided for @common_monthsShort.
  ///
  /// In en, this message translates to:
  /// **'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'**
  String get common_monthsShort;

  /// No description provided for @common_navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get common_navHome;

  /// No description provided for @common_navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get common_navProgress;

  /// No description provided for @common_navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get common_navTasks;

  /// No description provided for @common_navTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get common_navTeam;

  /// No description provided for @common_offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection. You can read the tasks already loaded. Editing needs a connection.'**
  String get common_offlineBanner;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_retry;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_tagline.
  ///
  /// In en, this message translates to:
  /// **'Who does what, by when.'**
  String get common_tagline;

  /// No description provided for @common_weekdaysShort.
  ///
  /// In en, this message translates to:
  /// **'Mon|Tue|Wed|Thu|Fri|Sat|Sun'**
  String get common_weekdaysShort;

  /// No description provided for @errors_emailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email is already used.'**
  String get errors_emailTaken;

  /// No description provided for @errors_forbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this.'**
  String get errors_forbidden;

  /// No description provided for @errors_invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is not right. Try again, or reset your password.'**
  String get errors_invalidCredentials;

  /// No description provided for @errors_lastAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make another member an Admin before you leave.'**
  String get errors_lastAdmin;

  /// No description provided for @errors_network.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errors_network;

  /// No description provided for @errors_notAssignee.
  ///
  /// In en, this message translates to:
  /// **'Only the assignee can change this task.'**
  String get errors_notAssignee;

  /// No description provided for @errors_planRequired.
  ///
  /// In en, this message translates to:
  /// **'This is part of a paid plan.'**
  String get errors_planRequired;

  /// No description provided for @errors_taskConflict.
  ///
  /// In en, this message translates to:
  /// **'Someone changed this task first. It has been refreshed.'**
  String get errors_taskConflict;

  /// No description provided for @errors_taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'This task no longer exists.'**
  String get errors_taskNotFound;

  /// No description provided for @errors_unauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get errors_unauthenticated;

  /// No description provided for @errors_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errors_unknown;

  /// No description provided for @errors_validation.
  ///
  /// In en, this message translates to:
  /// **'Check the information and try again.'**
  String get errors_validation;

  /// No description provided for @notifications_allowAction.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders'**
  String get notifications_allowAction;

  /// No description provided for @notifications_allowBody.
  ///
  /// In en, this message translates to:
  /// **'{appName} tells you when a task is assigned to you and before a deadline. You can change this in settings.'**
  String notifications_allowBody(String appName);

  /// No description provided for @notifications_allowNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notifications_allowNotNow;

  /// No description provided for @notifications_allowTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders?'**
  String get notifications_allowTitle;

  /// No description provided for @onboarding_body1.
  ///
  /// In en, this message translates to:
  /// **'One owner and one date for every task, in plain view of the team.'**
  String get onboarding_body1;

  /// No description provided for @onboarding_body2.
  ///
  /// In en, this message translates to:
  /// **'The dashboard shows what is done, what is late and who has what.'**
  String get onboarding_body2;

  /// No description provided for @onboarding_body3.
  ///
  /// In en, this message translates to:
  /// **'One reminder per task reaches you before the deadline, not after.'**
  String get onboarding_body3;

  /// No description provided for @onboarding_step.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboarding_step(int current, int total);

  /// No description provided for @onboarding_title1.
  ///
  /// In en, this message translates to:
  /// **'Everyone sees who owns what'**
  String get onboarding_title1;

  /// No description provided for @onboarding_title2.
  ///
  /// In en, this message translates to:
  /// **'Progress at a glance'**
  String get onboarding_title2;

  /// No description provided for @onboarding_title3.
  ///
  /// In en, this message translates to:
  /// **'Reminded before it is due'**
  String get onboarding_title3;

  /// No description provided for @settings_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settings_changePassword;

  /// No description provided for @settings_editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settings_editProfileTitle;

  /// No description provided for @settings_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settings_email;

  /// No description provided for @settings_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get settings_emailInvalid;

  /// No description provided for @settings_feedbackAbout.
  ///
  /// In en, this message translates to:
  /// **'What is it about?'**
  String get settings_feedbackAbout;

  /// No description provided for @settings_feedbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write a few words first.'**
  String get settings_feedbackEmpty;

  /// No description provided for @settings_feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe it in a few words'**
  String get settings_feedbackHint;

  /// No description provided for @settings_feedbackIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what would help your team. We tell you when it is built.'**
  String get settings_feedbackIntro;

  /// No description provided for @settings_feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get settings_feedbackMessage;

  /// No description provided for @settings_feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settings_feedbackSend;

  /// No description provided for @settings_feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you. We have your message.'**
  String get settings_feedbackThanks;

  /// No description provided for @settings_feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settings_feedbackTitle;

  /// No description provided for @settings_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get settings_fullName;

  /// No description provided for @settings_kindIdea.
  ///
  /// In en, this message translates to:
  /// **'An idea'**
  String get settings_kindIdea;

  /// No description provided for @settings_kindOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get settings_kindOther;

  /// No description provided for @settings_kindProblem.
  ///
  /// In en, this message translates to:
  /// **'A problem'**
  String get settings_kindProblem;

  /// No description provided for @settings_languageArabicSub.
  ///
  /// In en, this message translates to:
  /// **'Arabic, right to left'**
  String get settings_languageArabicSub;

  /// No description provided for @settings_languageEnglishSub.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEnglishSub;

  /// No description provided for @settings_languageFrenchSub.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get settings_languageFrenchSub;

  /// No description provided for @settings_languageNote.
  ///
  /// In en, this message translates to:
  /// **'Arabic switches every screen to a right-to-left layout.'**
  String get settings_languageNote;

  /// No description provided for @settings_languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_languageTitle;

  /// No description provided for @settings_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get settings_nameRequired;

  /// No description provided for @settings_policyDelete.
  ///
  /// In en, this message translates to:
  /// **'You can ask us to delete your account and data at any time.'**
  String get settings_policyDelete;

  /// No description provided for @settings_policyPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications carry generic text, never a task title.'**
  String get settings_policyPush;

  /// No description provided for @settings_policyServer.
  ///
  /// In en, this message translates to:
  /// **'The data is stored on a server in Algeria.'**
  String get settings_policyServer;

  /// No description provided for @settings_policyStored.
  ///
  /// In en, this message translates to:
  /// **'Data we store: your name, your email, your team membership and your tasks.'**
  String get settings_policyStored;

  /// No description provided for @settings_privacyAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get settings_privacyAgree;

  /// No description provided for @settings_privacyConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to the processing of my personal data'**
  String get settings_privacyConsent;

  /// No description provided for @settings_privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'{appName} keeps only what it needs: your name, your email and the tasks in your teams.'**
  String settings_privacyIntro(String appName);

  /// No description provided for @settings_privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settings_privacyPolicyTitle;

  /// No description provided for @settings_privacyReadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read the full privacy policy'**
  String get settings_privacyReadPolicy;

  /// No description provided for @settings_privacyStorage.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on a server in Algeria. Notifications never show task text. You can ask us to delete your account and data at any time.'**
  String get settings_privacyStorage;

  /// No description provided for @settings_privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and your data'**
  String get settings_privacyTitle;

  /// No description provided for @settings_profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get settings_profileSaved;

  /// No description provided for @settings_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settings_saveChanges;

  /// No description provided for @settings_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settings_signOut;

  /// No description provided for @settings_signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need your email and password to come back.'**
  String get settings_signOutBody;

  /// No description provided for @settings_signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {appName}?'**
  String settings_signOutTitle(String appName);

  /// No description provided for @settings_staySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in'**
  String get settings_staySignedIn;

  /// No description provided for @settings_usePhoneLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use the phone language'**
  String get settings_usePhoneLanguage;

  /// No description provided for @tasks_backToTasks.
  ///
  /// In en, this message translates to:
  /// **'Back to tasks'**
  String get tasks_backToTasks;

  /// No description provided for @tasks_boardTitle.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get tasks_boardTitle;

  /// No description provided for @tasks_cannotMoveCard.
  ///
  /// In en, this message translates to:
  /// **'Only the assignee can move this card.'**
  String get tasks_cannotMoveCard;

  /// No description provided for @tasks_changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get tasks_changeStatus;

  /// No description provided for @tasks_doneBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you, {name}. The team is at {done} of {total} tasks.'**
  String tasks_doneBody(String name, int done, int total);

  /// No description provided for @tasks_doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasks_doneLabel;

  /// No description provided for @tasks_doneTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} is done'**
  String tasks_doneTitle(String title);

  /// No description provided for @tasks_dueTomorrowTag.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get tasks_dueTomorrowTag;

  /// No description provided for @tasks_emptyBodyCreator.
  ///
  /// In en, this message translates to:
  /// **'Tasks you own appear here with a date. Add one, or ask a teammate to assign you one.'**
  String get tasks_emptyBodyCreator;

  /// No description provided for @tasks_emptyBodyMember.
  ///
  /// In en, this message translates to:
  /// **'Tasks you own appear here with a date. Ask a Manager or an Admin to assign you one.'**
  String get tasks_emptyBodyMember;

  /// No description provided for @tasks_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned to you'**
  String get tasks_emptyTitle;

  /// No description provided for @tasks_labelDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'due tomorrow'**
  String get tasks_labelDueTomorrow;

  /// No description provided for @tasks_labelOverdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get tasks_labelOverdue;

  /// No description provided for @tasks_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading tasks'**
  String get tasks_loading;

  /// No description provided for @tasks_newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasks_newTask;

  /// No description provided for @tasks_overdueTag.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasks_overdueTag;

  /// No description provided for @tasks_ownerWithLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {label}'**
  String tasks_ownerWithLabel(String name, String label);

  /// No description provided for @tasks_progressCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String tasks_progressCount(int done, int total);

  /// No description provided for @tasks_statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasks_statusDone;

  /// No description provided for @tasks_statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get tasks_statusInProgress;

  /// No description provided for @tasks_statusTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get tasks_statusTodo;

  /// No description provided for @tasks_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get tasks_undo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
