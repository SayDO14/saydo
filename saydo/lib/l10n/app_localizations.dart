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

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navEvents.
  ///
  /// In fr, this message translates to:
  /// **'Événements'**
  String get navEvents;

  /// No description provided for @navTasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches'**
  String get navTasks;

  /// No description provided for @navEmails.
  ///
  /// In fr, this message translates to:
  /// **'Emails'**
  String get navEmails;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @emailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Emails'**
  String get emailsTitle;

  /// No description provided for @emailsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos emails, rapidement'**
  String get emailsSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçus'**
  String get filterReceived;

  /// No description provided for @filterSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyés'**
  String get filterSent;

  /// No description provided for @emailsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun email pour le moment.'**
  String get emailsEmpty;

  /// No description provided for @emailsEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Dictez-en un avec le micro.'**
  String get emailsEmptyHint;

  /// No description provided for @loadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les emails.\n{error}'**
  String loadError(String error);

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @statusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get statusSent;

  /// No description provided for @statusReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get statusReceived;

  /// No description provided for @sentOn.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé le {date} · {time}'**
  String sentOn(String date, String time);

  /// No description provided for @createdOn.
  ///
  /// In fr, this message translates to:
  /// **'Créé le {date} · {time}'**
  String createdOn(String date, String time);

  /// No description provided for @messageLabel.
  ///
  /// In fr, this message translates to:
  /// **'MESSAGE'**
  String get messageLabel;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get appLanguage;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get required;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGeneric;

  /// No description provided for @errorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorWithMessage(String error);

  /// No description provided for @saveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer : {error}'**
  String saveError(String error);

  /// No description provided for @deleteError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer : {error}'**
  String deleteError(String error);

  /// No description provided for @fieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get fieldTitle;

  /// No description provided for @fieldNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldName;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldEmailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get fieldEmailAddress;

  /// No description provided for @fieldPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fieldFullName;

  /// No description provided for @fieldDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get fieldTime;

  /// No description provided for @fieldDueDateOptional.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'échéance (optionnelle)'**
  String get fieldDueDateOptional;

  /// No description provided for @fieldPeople.
  ///
  /// In fr, this message translates to:
  /// **'Personnes (séparées par des virgules)'**
  String get fieldPeople;

  /// No description provided for @fieldToName.
  ///
  /// In fr, this message translates to:
  /// **'À (nom)'**
  String get fieldToName;

  /// No description provided for @fieldSubject.
  ///
  /// In fr, this message translates to:
  /// **'Objet'**
  String get fieldSubject;

  /// No description provided for @fieldMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get fieldMessage;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un e-mail valide'**
  String get invalidEmail;

  /// No description provided for @noDate.
  ///
  /// In fr, this message translates to:
  /// **'Aucune date'**
  String get noDate;

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In fr, this message translates to:
  /// **'Passés'**
  String get past;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @showAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get showAll;

  /// No description provided for @showLess.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get showLess;

  /// No description provided for @allDay.
  ///
  /// In fr, this message translates to:
  /// **'Toute la journée'**
  String get allDay;

  /// No description provided for @continueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueLabel;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @tasksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes tâches'**
  String get tasksTitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Organisez vos priorités'**
  String get tasksSubtitle;

  /// No description provided for @tasksTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get tasksTodo;

  /// No description provided for @tasksDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get tasksDone;

  /// No description provided for @tasksFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get tasksFilterAll;

  /// No description provided for @tasksPriority.
  ///
  /// In fr, this message translates to:
  /// **'Prioritaire'**
  String get tasksPriority;

  /// No description provided for @tasksMarkTodo.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme à faire'**
  String get tasksMarkTodo;

  /// No description provided for @tasksMarkDone.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme terminée'**
  String get tasksMarkDone;

  /// No description provided for @tasksDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la tâche ?'**
  String get tasksDeleteTitle;

  /// No description provided for @tasksDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » sera supprimée définitivement.'**
  String tasksDeleteBody(String title);

  /// No description provided for @tasksUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de mettre à jour la tâche : {error}'**
  String tasksUpdateError(String error);

  /// No description provided for @tasksLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement\n{error}'**
  String tasksLoadError(String error);

  /// No description provided for @tasksAddByVoice.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une tâche avec votre voix'**
  String get tasksAddByVoice;

  /// No description provided for @tasksEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche pour le moment'**
  String get tasksEmpty;

  /// No description provided for @tasksEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Dictez-en une avec le micro'**
  String get tasksEmptyHint;

  /// No description provided for @tasksEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la tâche'**
  String get tasksEditTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsProfileSub.
  ///
  /// In fr, this message translates to:
  /// **'Nom, photo, bio'**
  String get settingsProfileSub;

  /// No description provided for @settingsAccountSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Compte et sécurité'**
  String get settingsAccountSecurity;

  /// No description provided for @settingsAccountSecuritySub.
  ///
  /// In fr, this message translates to:
  /// **'Changer de compte, mot de passe'**
  String get settingsAccountSecuritySub;

  /// No description provided for @settingsTimezone.
  ///
  /// In fr, this message translates to:
  /// **'Fuseau horaire'**
  String get settingsTimezone;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier connecté'**
  String get settingsCalendar;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité et sécurité'**
  String get settingsPrivacy;

  /// No description provided for @settingsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get settingsHelp;

  /// No description provided for @calendarSyncedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier synchronisé'**
  String get calendarSyncedTitle;

  /// No description provided for @calendarSyncedBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos événements vocaux confirmés sont automatiquement synchronisés vers Google Calendar.'**
  String get calendarSyncedBody;

  /// No description provided for @privacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité & Sécurité'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In fr, this message translates to:
  /// **'SayDo respecte votre vie privée. Vos enregistrements audio sont transcrits puis traités de manière sécurisée sans être revendus ni partagés à des tiers.'**
  String get privacyBody;

  /// No description provided for @helpBody.
  ///
  /// In fr, this message translates to:
  /// **'SayDo comprend le français, la darija algérienne et l\'anglais.\n\nAppuyez sur le micro et parlez naturellement pour créer des réunions, des tâches ou envoyer des e-mails !'**
  String get helpBody;

  /// No description provided for @placeholderMessage.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres du compte et préférences...'**
  String get placeholderMessage;

  /// No description provided for @profileNameUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Le nom a été modifié avec succès.'**
  String get profileNameUpdated;

  /// No description provided for @profileAvatarSelected.
  ///
  /// In fr, this message translates to:
  /// **'Avatar SayDo sélectionné avec succès.'**
  String get profileAvatarSelected;

  /// No description provided for @profilePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get profilePhoto;

  /// No description provided for @profileAvatarRobot.
  ///
  /// In fr, this message translates to:
  /// **'Avatar Robot SayDo'**
  String get profileAvatarRobot;

  /// No description provided for @profileCurrentlyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Actuellement utilisé'**
  String get profileCurrentlyUsed;

  /// No description provided for @profileChooseGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get profileChooseGallery;

  /// No description provided for @profileImportImage.
  ///
  /// In fr, this message translates to:
  /// **'Importer une image personnelle'**
  String get profileImportImage;

  /// No description provided for @profileGallerySoon.
  ///
  /// In fr, this message translates to:
  /// **'Galerie photo bientôt disponible'**
  String get profileGallerySoon;

  /// No description provided for @profileYourName.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get profileYourName;

  /// No description provided for @profileBio.
  ///
  /// In fr, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileBioHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez-vous brièvement...'**
  String get profileBioHint;

  /// No description provided for @profileUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour les informations'**
  String get profileUpdate;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour !'**
  String get profileUpdated;

  /// No description provided for @securityChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get securityChangePassword;

  /// No description provided for @securityNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get securityNewPassword;

  /// No description provided for @securityMin6.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get securityMin6;

  /// No description provided for @securityRepeat.
  ///
  /// In fr, this message translates to:
  /// **'Répétez le mot de passe'**
  String get securityRepeat;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit comporter au moins 6 caractères'**
  String get passwordTooShort;

  /// No description provided for @passwordsMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsMismatch;

  /// No description provided for @securityPasswordUpdated.
  ///
  /// In fr, this message translates to:
  /// **'✅ Mot de passe mis à jour avec succès !'**
  String get securityPasswordUpdated;

  /// No description provided for @securityUpdatePassword.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour le mot de passe'**
  String get securityUpdatePassword;

  /// No description provided for @securitySwitchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer de compte ?'**
  String get securitySwitchTitle;

  /// No description provided for @securitySwitchBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez déconnecté de ce compte afin de vous connecter avec un autre compte.'**
  String get securitySwitchBody;

  /// No description provided for @securityLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get securityLogoutTitle;

  /// No description provided for @securityLogoutBody.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter de SayDo ?'**
  String get securityLogoutBody;

  /// No description provided for @logoutAction.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutAction;

  /// No description provided for @securitySwitchAccount.
  ///
  /// In fr, this message translates to:
  /// **'Changer de compte'**
  String get securitySwitchAccount;

  /// No description provided for @securitySwitchSub.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter de ce compte pour vous connecter avec un autre compte.'**
  String get securitySwitchSub;

  /// No description provided for @securityChangePasswordSub.
  ///
  /// In fr, this message translates to:
  /// **'Mettez à jour votre mot de passe pour plus de sécurité.'**
  String get securityChangePasswordSub;

  /// No description provided for @securityEmailLocked.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse e-mail ne peut pas être modifiée. Pour utiliser une autre adresse, veuillez changer de compte.'**
  String get securityEmailLocked;

  /// No description provided for @securityLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get securityLogoutButton;

  /// No description provided for @loginFillFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez renseigner votre email et mot de passe'**
  String get loginFillFields;

  /// No description provided for @signupFillFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs obligatoires'**
  String get signupFillFields;

  /// No description provided for @accountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès !'**
  String get accountCreated;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion : {error}'**
  String loginError(String error);

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authErrInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authErrInvalidCredentials;

  /// No description provided for @authErrEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first. Check your inbox.'**
  String get authErrEmailNotConfirmed;

  /// No description provided for @authErrUserExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get authErrUserExists;

  /// No description provided for @authErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get authErrNetwork;

  /// No description provided for @authErrWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get authErrWeakPassword;

  /// No description provided for @authErrRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrRateLimit;

  /// No description provided for @authErrProviderDisabled.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method isn\'t available yet.'**
  String get authErrProviderDisabled;

  /// No description provided for @authErrUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrUnknown;

  /// No description provided for @authConfirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Account created! Confirm your email, then sign in.'**
  String get authConfirmEmailSent;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get forgotPasswordHint;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link is on its way.'**
  String get forgotPasswordSent;

  /// No description provided for @signupError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'inscription : {error}'**
  String signupError(String error);

  /// No description provided for @googleError.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google échouée : {error}'**
  String googleError(String error);

  /// No description provided for @appleError.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Apple échouée : {error}'**
  String appleError(String error);

  /// No description provided for @facebookError.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Facebook échouée : {error}'**
  String facebookError(String error);

  /// No description provided for @loginSubtitleSignup.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte SayDo'**
  String get loginSubtitleSignup;

  /// No description provided for @loginSubtitleLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte SayDo'**
  String get loginSubtitleLogin;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @dividerOr.
  ///
  /// In fr, this message translates to:
  /// **'Ou'**
  String get dividerOr;

  /// No description provided for @createAccountArrow.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte →'**
  String get createAccountArrow;

  /// No description provided for @loginTab.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTab;

  /// No description provided for @signUpTab.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get signUpTab;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @onbSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onbSkip;

  /// No description provided for @onbGetStarted.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onbGetStarted;

  /// No description provided for @onbTag.
  ///
  /// In fr, this message translates to:
  /// **'ASSISTANT VOCAL IA'**
  String get onbTag;

  /// No description provided for @onbBubble.
  ///
  /// In fr, this message translates to:
  /// **'« Rappelle-moi... »'**
  String get onbBubble;

  /// No description provided for @onbTaskCreated.
  ///
  /// In fr, this message translates to:
  /// **'Tâche créée'**
  String get onbTaskCreated;

  /// No description provided for @onbHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Dites-le. Faites-le.'**
  String get onbHeadline;

  /// No description provided for @onbDesc1.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant personnel intelligent.\nParlez naturellement, SayDo\ntransforme chaque mot en action.'**
  String get onbDesc1;

  /// No description provided for @onbWelcome.
  ///
  /// In fr, this message translates to:
  /// **'BIENVENUE'**
  String get onbWelcome;

  /// No description provided for @onbDesc2.
  ///
  /// In fr, this message translates to:
  /// **'Dites-le à voix haute,\nSayDo gère votre emploi du temps.'**
  String get onbDesc2;

  /// No description provided for @onbAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get onbAgenda;

  /// No description provided for @onbSmart.
  ///
  /// In fr, this message translates to:
  /// **'COMPRÉHENSION\nINTELLIGENTE'**
  String get onbSmart;

  /// No description provided for @onbDesc3.
  ///
  /// In fr, this message translates to:
  /// **'Mélangez darija, français et anglais naturellement.\nSayDo extrait dates, tâches et personnes sans effort.'**
  String get onbDesc3;

  /// No description provided for @eventsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos rendez-vous et tâches à venir'**
  String get eventsSubtitle;

  /// No description provided for @eventsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les événements.\n{error}'**
  String eventsLoadError(String error);

  /// No description provided for @eventsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement pour l\'instant.'**
  String get eventsEmpty;

  /// No description provided for @eventsEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le micro pour en dicter un.'**
  String get eventsEmptyHint;

  /// No description provided for @eventsAllUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Tous les événements à venir'**
  String get eventsAllUpcoming;

  /// No description provided for @eventSynced.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé avec Google Agenda'**
  String get eventSynced;

  /// No description provided for @eventPendingSync.
  ///
  /// In fr, this message translates to:
  /// **'En attente de synchronisation'**
  String get eventPendingSync;

  /// No description provided for @homeSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré. La synchronisation avec Google va démarrer.'**
  String get homeSaved;

  /// No description provided for @homeSpeakTo.
  ///
  /// In fr, this message translates to:
  /// **'Parlez à '**
  String get homeSpeakTo;

  /// No description provided for @homeListening.
  ///
  /// In fr, this message translates to:
  /// **'En écoute... appuyez pour envoyer'**
  String get homeListening;

  /// No description provided for @homeProcessing.
  ///
  /// In fr, this message translates to:
  /// **'Traitement en cours...'**
  String get homeProcessing;

  /// No description provided for @homeTapRetry.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour recommencer'**
  String get homeTapRetry;

  /// No description provided for @homeDefaultHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez un événement ou une tâche\nsimplement avec votre voix.'**
  String get homeDefaultHint;

  /// No description provided for @contactsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le contact ?'**
  String get contactsDeleteTitle;

  /// No description provided for @contactsDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({email}) sera supprimé. Les emails passés ne sont pas affectés.'**
  String contactsDeleteBody(String name, String email);

  /// No description provided for @contactsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les contacts.\n{error}'**
  String contactsLoadError(String error);

  /// No description provided for @contactsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour l\'instant.'**
  String get contactsEmpty;

  /// No description provided for @contactsEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez-en un ici, ou ils sont\nsauvegardés automatiquement\nlorsque vous envoyez un email.'**
  String get contactsEmptyHint;

  /// No description provided for @contactDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un contact avec ce nom.'**
  String get contactDuplicate;

  /// No description provided for @contactEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le contact'**
  String get contactEdit;

  /// No description provided for @contactNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau contact'**
  String get contactNew;

  /// No description provided for @proposalNewEvent.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel événement'**
  String get proposalNewEvent;

  /// No description provided for @proposalNewEmail.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email'**
  String get proposalNewEmail;

  /// No description provided for @proposalNewTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get proposalNewTask;

  /// No description provided for @voiceSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré avec succès ! 🎉'**
  String get voiceSaved;

  /// No description provided for @voiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'SayDo Vocal'**
  String get voiceTitle;

  /// No description provided for @voiceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez une tâche ou un rendez-vous'**
  String get voiceSubtitle;

  /// No description provided for @voiceListening.
  ///
  /// In fr, this message translates to:
  /// **'En écoute... Appuyez pour valider'**
  String get voiceListening;

  /// No description provided for @voiceProcessing.
  ///
  /// In fr, this message translates to:
  /// **'Traitement en cours par SayDo...'**
  String get voiceProcessing;

  /// No description provided for @voiceDone.
  ///
  /// In fr, this message translates to:
  /// **'Analyse terminée'**
  String get voiceDone;

  /// No description provided for @voiceTapToSpeak.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour parler'**
  String get voiceTapToSpeak;

  /// No description provided for @voiceSpeakNaturally.
  ///
  /// In fr, this message translates to:
  /// **'Parlez naturellement, SayDo s\'occupe du reste.'**
  String get voiceSpeakNaturally;

  /// No description provided for @voiceRecognizing.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance vocale & extraction des détails...'**
  String get voiceRecognizing;

  /// No description provided for @voiceExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex : « Rendez-vous demain à 14h avec Sophie » ou « Acheter du lait »'**
  String get voiceExample;

  /// No description provided for @gotIt.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get gotIt;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @great.
  ///
  /// In fr, this message translates to:
  /// **'Super !'**
  String get great;

  /// No description provided for @emailsTapToCreate.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour créer un email avec la voix'**
  String get emailsTapToCreate;

  /// No description provided for @previewSaid.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez dit : {text}'**
  String previewSaid(String text);

  /// No description provided for @previewAgentAsks.
  ///
  /// In fr, this message translates to:
  /// **'L\'agent demande : {question}'**
  String previewAgentAsks(String question);

  /// No description provided for @previewType.
  ///
  /// In fr, this message translates to:
  /// **'Type : {type}'**
  String previewType(String type);

  /// No description provided for @previewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre : {title}'**
  String previewTitle(String title);

  /// No description provided for @previewDate.
  ///
  /// In fr, this message translates to:
  /// **'Date : {date}'**
  String previewDate(String date);

  /// No description provided for @previewTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure : {time}'**
  String previewTime(String time);

  /// No description provided for @previewPeople.
  ///
  /// In fr, this message translates to:
  /// **'Personnes : {people}'**
  String previewPeople(String people);
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
