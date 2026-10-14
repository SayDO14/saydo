// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navEvents => 'Événements';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navEmails => 'Emails';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get emailsTitle => 'Emails';

  @override
  String get emailsSubtitle => 'Vos emails, rapidement';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterReceived => 'Reçus';

  @override
  String get filterSent => 'Envoyés';

  @override
  String get emailsEmpty => 'Aucun email pour le moment.';

  @override
  String get emailsEmptyHint => 'Dictez-en un avec le micro.';

  @override
  String loadError(String error) {
    return 'Impossible de charger les emails.\n$error';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get statusSent => 'Envoyé';

  @override
  String get statusReceived => 'Reçu';

  @override
  String sentOn(String date, String time) {
    return 'Envoyé le $date · $time';
  }

  @override
  String createdOn(String date, String time) {
    return 'Créé le $date · $time';
  }

  @override
  String get messageLabel => 'MESSAGE';

  @override
  String get language => 'Langue';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get required => 'Requis';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String errorWithMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String saveError(String error) {
    return 'Impossible d\'enregistrer : $error';
  }

  @override
  String deleteError(String error) {
    return 'Impossible de supprimer : $error';
  }

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldEmailAddress => 'Adresse e-mail';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get fieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Heure';

  @override
  String get fieldDueDateOptional => 'Date d\'échéance (optionnelle)';

  @override
  String get fieldPeople => 'Personnes (séparées par des virgules)';

  @override
  String get fieldToName => 'À (nom)';

  @override
  String get fieldSubject => 'Objet';

  @override
  String get fieldMessage => 'Message';

  @override
  String get invalidEmail => 'Saisissez un e-mail valide';

  @override
  String get noDate => 'Aucune date';

  @override
  String get upcoming => 'À venir';

  @override
  String get past => 'Passés';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get showAll => 'Voir tout';

  @override
  String get showLess => 'Réduire';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get next => 'Suivant';

  @override
  String get tasksTitle => 'Mes tâches';

  @override
  String get tasksSubtitle => 'Organisez vos priorités';

  @override
  String get tasksTodo => 'À faire';

  @override
  String get tasksDone => 'Terminées';

  @override
  String get tasksFilterAll => 'Toutes';

  @override
  String get tasksPriority => 'Prioritaire';

  @override
  String get tasksMarkTodo => 'Marquer comme à faire';

  @override
  String get tasksMarkDone => 'Marquer comme terminée';

  @override
  String get tasksDeleteTitle => 'Supprimer la tâche ?';

  @override
  String tasksDeleteBody(String title) {
    return '« $title » sera supprimée définitivement.';
  }

  @override
  String tasksUpdateError(String error) {
    return 'Impossible de mettre à jour la tâche : $error';
  }

  @override
  String tasksLoadError(String error) {
    return 'Erreur de chargement\n$error';
  }

  @override
  String get tasksAddByVoice => 'Ajoutez une tâche avec votre voix';

  @override
  String get tasksEmpty => 'Aucune tâche pour le moment';

  @override
  String get tasksEmptyHint => 'Dictez-en une avec le micro';

  @override
  String get tasksEditTitle => 'Modifier la tâche';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsProfileSub => 'Nom, photo, bio';

  @override
  String get settingsAccountSecurity => 'Compte et sécurité';

  @override
  String get settingsAccountSecuritySub => 'Changer de compte, mot de passe';

  @override
  String get settingsTimezone => 'Fuseau horaire';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsCalendar => 'Calendrier connecté';

  @override
  String get settingsPrivacy => 'Confidentialité et sécurité';

  @override
  String get settingsHelp => 'Aide et support';

  @override
  String get calendarSyncedTitle => 'Calendrier synchronisé';

  @override
  String get calendarSyncedBody =>
      'Vos événements vocaux confirmés sont automatiquement synchronisés vers Google Calendar.';

  @override
  String get privacyTitle => 'Confidentialité & Sécurité';

  @override
  String get privacyBody =>
      'SayDo respecte votre vie privée. Vos enregistrements audio sont transcrits puis traités de manière sécurisée sans être revendus ni partagés à des tiers.';

  @override
  String get helpBody =>
      'SayDo comprend le français, la darija algérienne et l\'anglais.\n\nAppuyez sur le micro et parlez naturellement pour créer des réunions, des tâches ou envoyer des e-mails !';

  @override
  String get placeholderMessage => 'Paramètres du compte et préférences...';

  @override
  String get profileNameUpdated => 'Le nom a été modifié avec succès.';

  @override
  String get profileAvatarSelected => 'Avatar SayDo sélectionné avec succès.';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get profileAvatarRobot => 'Avatar Robot SayDo';

  @override
  String get profileCurrentlyUsed => 'Actuellement utilisé';

  @override
  String get profileChooseGallery => 'Choisir dans la galerie';

  @override
  String get profileImportImage => 'Importer une image personnelle';

  @override
  String get profileGallerySoon => 'Galerie photo bientôt disponible';

  @override
  String get profileYourName => 'Votre nom';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileBioHint => 'Décrivez-vous brièvement...';

  @override
  String get profileUpdate => 'Mettre à jour les informations';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String get securityChangePassword => 'Changer le mot de passe';

  @override
  String get securityNewPassword => 'Nouveau mot de passe';

  @override
  String get securityMin6 => 'Minimum 6 caractères';

  @override
  String get securityRepeat => 'Répétez le mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get passwordsMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get securityPasswordUpdated =>
      '✅ Mot de passe mis à jour avec succès !';

  @override
  String get securityUpdatePassword => 'Mettre à jour le mot de passe';

  @override
  String get securitySwitchTitle => 'Changer de compte ?';

  @override
  String get securitySwitchBody =>
      'Vous serez déconnecté de ce compte afin de vous connecter avec un autre compte.';

  @override
  String get securityLogoutTitle => 'Se déconnecter ?';

  @override
  String get securityLogoutBody =>
      'Voulez-vous vraiment vous déconnecter de SayDo ?';

  @override
  String get logoutAction => 'Déconnexion';

  @override
  String get securitySwitchAccount => 'Changer de compte';

  @override
  String get securitySwitchSub =>
      'Se déconnecter de ce compte pour vous connecter avec un autre compte.';

  @override
  String get securityChangePasswordSub =>
      'Mettez à jour votre mot de passe pour plus de sécurité.';

  @override
  String get securityEmailLocked =>
      'L\'adresse e-mail ne peut pas être modifiée. Pour utiliser une autre adresse, veuillez changer de compte.';

  @override
  String get securityLogoutButton => 'Se déconnecter';

  @override
  String get loginFillFields =>
      'Veuillez renseigner votre email et mot de passe';

  @override
  String get signupFillFields =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String get accountCreated => 'Compte créé avec succès !';

  @override
  String loginError(String error) {
    return 'Erreur de connexion : $error';
  }

  @override
  String signupError(String error) {
    return 'Erreur d\'inscription : $error';
  }

  @override
  String googleError(String error) {
    return 'Connexion Google échouée : $error';
  }

  @override
  String appleError(String error) {
    return 'Connexion Apple échouée : $error';
  }

  @override
  String facebookError(String error) {
    return 'Connexion Facebook échouée : $error';
  }

  @override
  String get loginSubtitleSignup => 'Créez votre compte SayDo';

  @override
  String get loginSubtitleLogin => 'Connectez-vous à votre compte SayDo';

  @override
  String get signIn => 'Se connecter';

  @override
  String get dividerOr => 'Ou';

  @override
  String get createAccountArrow => 'Créer un compte →';

  @override
  String get loginTab => 'Connexion';

  @override
  String get signUpTab => 'Inscription';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get onbSkip => 'Passer';

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbTag => 'ASSISTANT VOCAL IA';

  @override
  String get onbBubble => '« Rappelle-moi... »';

  @override
  String get onbTaskCreated => 'Tâche créée';

  @override
  String get onbHeadline => 'Dites-le. Faites-le.';

  @override
  String get onbDesc1 =>
      'Votre assistant personnel intelligent.\nParlez naturellement, SayDo\ntransforme chaque mot en action.';

  @override
  String get onbWelcome => 'BIENVENUE';

  @override
  String get onbDesc2 =>
      'Dites-le à voix haute,\nSayDo gère votre emploi du temps.';

  @override
  String get onbAgenda => 'Agenda';

  @override
  String get onbSmart => 'COMPRÉHENSION\nINTELLIGENTE';

  @override
  String get onbDesc3 =>
      'Mélangez darija, français et anglais naturellement.\nSayDo extrait dates, tâches et personnes sans effort.';

  @override
  String get eventsSubtitle => 'Vos rendez-vous et tâches à venir';

  @override
  String eventsLoadError(String error) {
    return 'Impossible de charger les événements.\n$error';
  }

  @override
  String get eventsEmpty => 'Aucun événement pour l\'instant.';

  @override
  String get eventsEmptyHint => 'Appuyez sur le micro pour en dicter un.';

  @override
  String get eventsAllUpcoming => 'Tous les événements à venir';

  @override
  String get eventSynced => 'Synchronisé avec Google Agenda';

  @override
  String get eventPendingSync => 'En attente de synchronisation';

  @override
  String get homeSaved =>
      'Enregistré. La synchronisation avec Google va démarrer.';

  @override
  String get homeSpeakTo => 'Parlez à ';

  @override
  String get homeListening => 'En écoute... appuyez pour envoyer';

  @override
  String get homeProcessing => 'Traitement en cours...';

  @override
  String get homeTapRetry => 'Appuyez pour recommencer';

  @override
  String get homeDefaultHint =>
      'Créez un événement ou une tâche\nsimplement avec votre voix.';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsDeleteTitle => 'Supprimer le contact ?';

  @override
  String contactsDeleteBody(String name, String email) {
    return '$name ($email) sera supprimé. Les emails passés ne sont pas affectés.';
  }

  @override
  String contactsLoadError(String error) {
    return 'Impossible de charger les contacts.\n$error';
  }

  @override
  String get contactsEmpty => 'Aucun contact pour l\'instant.';

  @override
  String get contactsEmptyHint =>
      'Ajoutez-en un ici, ou ils sont\nsauvegardés automatiquement\nlorsque vous envoyez un email.';

  @override
  String get contactDuplicate => 'Vous avez déjà un contact avec ce nom.';

  @override
  String get contactEdit => 'Modifier le contact';

  @override
  String get contactNew => 'Nouveau contact';

  @override
  String get proposalNewEvent => 'Nouvel événement';

  @override
  String get proposalNewEmail => 'Nouvel email';

  @override
  String get proposalNewTask => 'Nouvelle tâche';

  @override
  String get voiceSaved => 'Enregistré avec succès ! 🎉';

  @override
  String get voiceTitle => 'SayDo Vocal';

  @override
  String get voiceSubtitle => 'Créez une tâche ou un rendez-vous';

  @override
  String get voiceListening => 'En écoute... Appuyez pour valider';

  @override
  String get voiceProcessing => 'Traitement en cours par SayDo...';

  @override
  String get voiceDone => 'Analyse terminée';

  @override
  String get voiceTapToSpeak => 'Appuyez pour parler';

  @override
  String get voiceSpeakNaturally =>
      'Parlez naturellement, SayDo s\'occupe du reste.';

  @override
  String get voiceRecognizing =>
      'Reconnaissance vocale & extraction des détails...';

  @override
  String get voiceExample =>
      'Ex : « Rendez-vous demain à 14h avec Sophie » ou « Acheter du lait »';

  @override
  String get gotIt => 'Compris';

  @override
  String get close => 'Fermer';

  @override
  String get great => 'Super !';

  @override
  String get emailsTapToCreate => 'Appuyez pour créer un email avec la voix';

  @override
  String previewSaid(String text) {
    return 'Vous avez dit : $text';
  }

  @override
  String previewAgentAsks(String question) {
    return 'L\'agent demande : $question';
  }

  @override
  String previewType(String type) {
    return 'Type : $type';
  }

  @override
  String previewTitle(String title) {
    return 'Titre : $title';
  }

  @override
  String previewDate(String date) {
    return 'Date : $date';
  }

  @override
  String previewTime(String time) {
    return 'Heure : $time';
  }

  @override
  String previewPeople(String people) {
    return 'Personnes : $people';
  }

  @override
  String get authInvalidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get authErrInvalidCredentials =>
      'E-mail ou mot de passe incorrect. Réessayez.';

  @override
  String get authErrEmailNotConfirmed =>
      'Confirmez d\'abord votre e-mail : vérifiez votre boîte de réception.';

  @override
  String get authErrUserExists =>
      'Un compte existe déjà avec cet e-mail. Essayez de vous connecter.';

  @override
  String get authErrNetwork =>
      'Pas de connexion. Vérifiez votre internet et réessayez.';

  @override
  String get authErrWeakPassword =>
      'Mot de passe trop faible. Utilisez au moins 6 caractères.';

  @override
  String get authErrRateLimit =>
      'Trop de tentatives. Patientez un instant puis réessayez.';

  @override
  String get authErrProviderDisabled =>
      'Cette méthode de connexion n\'est pas encore disponible.';

  @override
  String get authErrUnknown => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get authConfirmEmailSent =>
      'Compte créé ! Confirmez votre e-mail, puis connectez-vous.';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordHint =>
      'Saisissez votre e-mail et nous vous enverrons un lien de réinitialisation.';

  @override
  String get forgotPasswordSend => 'Envoyer le lien';

  @override
  String get forgotPasswordSent =>
      'Si un compte existe pour cet e-mail, un lien de réinitialisation vient d\'être envoyé.';
}
