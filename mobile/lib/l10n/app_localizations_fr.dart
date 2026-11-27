// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Tandem';

  @override
  String common_appIconLabel(String appName) {
    return 'Logo $appName';
  }

  @override
  String get common_back => 'Retour';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_couldNotSave => 'Enregistrement impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get common_getStarted => 'Commencer';

  @override
  String get common_loadFailed => 'Impossible de charger les données.';

  @override
  String get common_loading => 'Chargement';

  @override
  String get common_monthsShort => 'janv.|févr.|mars|avr.|mai|juin|juil.|août|sept.|oct.|nov.|déc.';

  @override
  String get common_navHome => 'Accueil';

  @override
  String get common_navProgress => 'Progression';

  @override
  String get common_navTasks => 'Tâches';

  @override
  String get common_navTeam => 'Équipe';

  @override
  String get common_offlineBanner => 'Pas de connexion. Vous pouvez lire les tâches déjà chargées. La modification nécessite une connexion.';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_skip => 'Passer';

  @override
  String get common_tagline => 'Qui fait quoi, pour quand.';

  @override
  String get common_weekdaysShort => 'lun.|mar.|mer.|jeu.|ven.|sam.|dim.';

  @override
  String get errors_emailTaken => 'Cette adresse e-mail est déjà utilisée.';

  @override
  String get errors_forbidden => 'Vous n’avez pas le droit de faire cela.';

  @override
  String get errors_invalidCredentials => 'L’e-mail ou le mot de passe est incorrect. Réessayez ou réinitialisez votre mot de passe.';

  @override
  String get errors_lastAdmin => 'Nommez un autre administrateur avant de partir.';

  @override
  String get errors_network => 'Pas de connexion. Vérifiez votre réseau et réessayez.';

  @override
  String get errors_notAssignee => 'Seule la personne assignée peut modifier cette tâche.';

  @override
  String get errors_planRequired => 'Cette fonction fait partie d’un plan payant.';

  @override
  String get errors_taskConflict => 'Quelqu’un a modifié cette tâche avant vous. Elle a été actualisée.';

  @override
  String get errors_taskNotFound => 'Cette tâche n’existe plus.';

  @override
  String get errors_unauthenticated => 'Connectez-vous pour continuer.';

  @override
  String get errors_unknown => 'Une erreur s’est produite. Réessayez.';

  @override
  String get errors_validation => 'Vérifiez les informations et réessayez.';

  @override
  String get notifications_allowAction => 'Autoriser les rappels';

  @override
  String notifications_allowBody(String appName) {
    return '$appName vous prévient lorsqu’une tâche vous est assignée et avant une échéance. Vous pouvez modifier cela dans les paramètres.';
  }

  @override
  String get notifications_allowNotNow => 'Pas maintenant';

  @override
  String get notifications_allowTitle => 'Autoriser les rappels ?';

  @override
  String get onboarding_body1 => 'Un responsable et une date pour chaque tâche, sous les yeux de toute l’équipe.';

  @override
  String get onboarding_body2 => 'Le tableau de bord montre ce qui est fait, ce qui est en retard et qui a quoi.';

  @override
  String get onboarding_body3 => 'Un rappel par tâche vous parvient avant l’échéance, pas après.';

  @override
  String onboarding_step(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboarding_title1 => 'Chacun voit qui est responsable de quoi';

  @override
  String get onboarding_title2 => 'La progression en un coup d’œil';

  @override
  String get onboarding_title3 => 'Un rappel avant l’échéance';

  @override
  String get settings_changePassword => 'Changer le mot de passe';

  @override
  String get settings_editProfileTitle => 'Modifier le profil';

  @override
  String get settings_email => 'E-mail';

  @override
  String get settings_emailInvalid => 'Saisissez une adresse e-mail valide.';

  @override
  String get settings_feedbackAbout => 'De quoi s’agit-il ?';

  @override
  String get settings_feedbackEmpty => 'Écrivez d’abord quelques mots.';

  @override
  String get settings_feedbackHint => 'Décrivez-le en quelques mots';

  @override
  String get settings_feedbackIntro => 'Dites-nous ce qui aiderait votre équipe. Nous vous prévenons quand c’est fait.';

  @override
  String get settings_feedbackMessage => 'Votre message';

  @override
  String get settings_feedbackSend => 'Envoyer l’avis';

  @override
  String get settings_feedbackThanks => 'Merci. Nous avons bien reçu votre message.';

  @override
  String get settings_feedbackTitle => 'Avis';

  @override
  String get settings_fullName => 'Nom complet';

  @override
  String get settings_kindIdea => 'Une idée';

  @override
  String get settings_kindOther => 'Autre chose';

  @override
  String get settings_kindProblem => 'Un problème';

  @override
  String get settings_languageArabicSub => 'Arabe, de droite à gauche';

  @override
  String get settings_languageEnglishSub => 'Anglais';

  @override
  String get settings_languageFrenchSub => 'Français';

  @override
  String get settings_languageNote => 'L’arabe affiche tous les écrans de droite à gauche.';

  @override
  String get settings_languageTitle => 'Langue';

  @override
  String get settings_nameRequired => 'Saisissez votre nom.';

  @override
  String get settings_policyDelete => 'Vous pouvez demander la suppression de votre compte et de vos données à tout moment.';

  @override
  String get settings_policyPush => 'Les notifications push contiennent un texte générique, jamais le titre d’une tâche.';

  @override
  String get settings_policyServer => 'Les données sont stockées sur un serveur en Algérie.';

  @override
  String get settings_policyStored => 'Données conservées : votre nom, votre e-mail, votre appartenance aux équipes et vos tâches.';

  @override
  String get settings_privacyAgree => 'Accepter et continuer';

  @override
  String get settings_privacyConsent => 'J’accepte le traitement de mes données personnelles';

  @override
  String settings_privacyIntro(String appName) {
    return '$appName ne conserve que le nécessaire : votre nom, votre e-mail et les tâches de vos équipes.';
  }

  @override
  String get settings_privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get settings_privacyReadPolicy => 'Lire la politique de confidentialité complète';

  @override
  String get settings_privacyStorage => 'Vos données sont stockées sur un serveur en Algérie. Les notifications n’affichent jamais le texte des tâches. Vous pouvez demander à tout moment la suppression de votre compte et de vos données.';

  @override
  String get settings_privacyTitle => 'Confidentialité et vos données';

  @override
  String get settings_profileSaved => 'Profil enregistré.';

  @override
  String get settings_saveChanges => 'Enregistrer les modifications';

  @override
  String get settings_signOut => 'Se déconnecter';

  @override
  String get settings_signOutBody => 'Vous aurez besoin de votre e-mail et de votre mot de passe pour revenir.';

  @override
  String settings_signOutTitle(String appName) {
    return 'Se déconnecter de $appName ?';
  }

  @override
  String get settings_staySignedIn => 'Rester connecté';

  @override
  String get settings_usePhoneLanguage => 'Utiliser la langue du téléphone';

  @override
  String get tasks_backToTasks => 'Retour aux tâches';

  @override
  String get tasks_boardTitle => 'Tableau';

  @override
  String get tasks_cannotMoveCard => 'Seule la personne assignée peut déplacer cette carte.';

  @override
  String get tasks_changeStatus => 'Changer le statut';

  @override
  String tasks_doneBody(String name, int done, int total) {
    return 'Merci, $name. L’équipe en est à $done tâches sur $total.';
  }

  @override
  String get tasks_doneLabel => 'Terminée';

  @override
  String tasks_doneTitle(String title) {
    return '$title est terminée';
  }

  @override
  String get tasks_dueTomorrowTag => 'Pour demain';

  @override
  String get tasks_emptyBodyCreator => 'Les tâches dont vous êtes responsable apparaissent ici avec une date. Ajoutez-en une, ou demandez à un coéquipier de vous en assigner une.';

  @override
  String get tasks_emptyBodyMember => 'Les tâches dont vous êtes responsable apparaissent ici avec une date. Demandez à un responsable ou à un administrateur de vous en assigner une.';

  @override
  String get tasks_emptyTitle => 'Aucune tâche ne vous est assignée';

  @override
  String get tasks_labelDueTomorrow => 'à rendre demain';

  @override
  String get tasks_labelOverdue => 'en retard';

  @override
  String get tasks_loading => 'Chargement des tâches';

  @override
  String get tasks_newTask => 'Nouvelle tâche';

  @override
  String get tasks_overdueTag => 'En retard';

  @override
  String tasks_ownerWithLabel(String name, String label) {
    return '$name, $label';
  }

  @override
  String tasks_progressCount(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get tasks_statusDone => 'Terminée';

  @override
  String get tasks_statusInProgress => 'En cours';

  @override
  String get tasks_statusTodo => 'À faire';

  @override
  String get tasks_undo => 'Annuler';
}
