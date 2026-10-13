// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navEvents => 'Events';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navEmails => 'Emails';

  @override
  String get navSettings => 'Settings';

  @override
  String get emailsTitle => 'Emails';

  @override
  String get emailsSubtitle => 'Your emails, fast';

  @override
  String get filterAll => 'All';

  @override
  String get filterReceived => 'Received';

  @override
  String get filterSent => 'Sent';

  @override
  String get emailsEmpty => 'No emails yet.';

  @override
  String get emailsEmptyHint => 'Dictate one with the microphone.';

  @override
  String loadError(String error) {
    return 'Couldn\'t load emails.\n$error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusReceived => 'Received';

  @override
  String sentOn(String date, String time) {
    return 'Sent on $date · $time';
  }

  @override
  String createdOn(String date, String time) {
    return 'Created on $date · $time';
  }

  @override
  String get messageLabel => 'MESSAGE';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get required => 'Required';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String saveError(String error) {
    return 'Could not save: $error';
  }

  @override
  String deleteError(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldEmailAddress => 'Email address';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldDueDateOptional => 'Due date (optional)';

  @override
  String get fieldPeople => 'People (comma separated)';

  @override
  String get fieldToName => 'To (name)';

  @override
  String get fieldSubject => 'Subject';

  @override
  String get fieldMessage => 'Message';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get noDate => 'No date';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get today => 'Today';

  @override
  String get showAll => 'Show all';

  @override
  String get showLess => 'Show less';

  @override
  String get allDay => 'All day';

  @override
  String get continueLabel => 'Continue';

  @override
  String get next => 'Next';

  @override
  String get tasksTitle => 'My tasks';

  @override
  String get tasksSubtitle => 'Organize your priorities';

  @override
  String get tasksTodo => 'To do';

  @override
  String get tasksDone => 'Done';

  @override
  String get tasksFilterAll => 'All';

  @override
  String get tasksPriority => 'Priority';

  @override
  String get tasksMarkTodo => 'Mark as to do';

  @override
  String get tasksMarkDone => 'Mark as done';

  @override
  String get tasksDeleteTitle => 'Delete this task?';

  @override
  String tasksDeleteBody(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String tasksUpdateError(String error) {
    return 'Could not update the task: $error';
  }

  @override
  String tasksLoadError(String error) {
    return 'Loading error\n$error';
  }

  @override
  String get tasksAddByVoice => 'Add a task with your voice';

  @override
  String get tasksEmpty => 'No tasks yet';

  @override
  String get tasksEmptyHint => 'Dictate one with the microphone';

  @override
  String get tasksEditTitle => 'Edit task';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsProfileSub => 'Name, photo, bio';

  @override
  String get settingsAccountSecurity => 'Account and security';

  @override
  String get settingsAccountSecuritySub => 'Switch account, password';

  @override
  String get settingsTimezone => 'Time zone';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsCalendar => 'Connected calendar';

  @override
  String get settingsPrivacy => 'Privacy and security';

  @override
  String get settingsHelp => 'Help and support';

  @override
  String get calendarSyncedTitle => 'Calendar synced';

  @override
  String get calendarSyncedBody =>
      'Your confirmed voice events are automatically synced to Google Calendar.';

  @override
  String get privacyTitle => 'Privacy & Security';

  @override
  String get privacyBody =>
      'SayDo respects your privacy. Your audio recordings are transcribed and processed securely, and are never sold or shared with third parties.';

  @override
  String get helpBody =>
      'SayDo understands French, Algerian Darija and English.\n\nTap the microphone and speak naturally to create meetings, tasks or send emails!';

  @override
  String get placeholderMessage => 'Account settings and preferences...';

  @override
  String get profileNameUpdated => 'Name updated successfully.';

  @override
  String get profileAvatarSelected => 'SayDo avatar selected successfully.';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profileAvatarRobot => 'SayDo Robot avatar';

  @override
  String get profileCurrentlyUsed => 'Currently in use';

  @override
  String get profileChooseGallery => 'Choose from gallery';

  @override
  String get profileImportImage => 'Import your own image';

  @override
  String get profileGallerySoon => 'Photo gallery coming soon';

  @override
  String get profileYourName => 'Your name';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileBioHint => 'Describe yourself briefly...';

  @override
  String get profileUpdate => 'Update information';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get securityChangePassword => 'Change password';

  @override
  String get securityNewPassword => 'New password';

  @override
  String get securityMin6 => 'At least 6 characters';

  @override
  String get securityRepeat => 'Repeat the password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get securityPasswordUpdated => '✅ Password updated successfully!';

  @override
  String get securityUpdatePassword => 'Update password';

  @override
  String get securitySwitchTitle => 'Switch account?';

  @override
  String get securitySwitchBody =>
      'You will be signed out of this account so you can sign in with another one.';

  @override
  String get securityLogoutTitle => 'Sign out?';

  @override
  String get securityLogoutBody => 'Do you really want to sign out of SayDo?';

  @override
  String get logoutAction => 'Sign out';

  @override
  String get securitySwitchAccount => 'Switch account';

  @override
  String get securitySwitchSub =>
      'Sign out of this account to sign in with another one.';

  @override
  String get securityChangePasswordSub =>
      'Update your password for extra security.';

  @override
  String get securityEmailLocked =>
      'The email address cannot be changed. To use another address, please switch account.';

  @override
  String get securityLogoutButton => 'Sign out';

  @override
  String get loginFillFields => 'Please enter your email and password';

  @override
  String get signupFillFields => 'Please fill in all required fields';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String loginError(String error) {
    return 'Sign-in error: $error';
  }

  @override
  String signupError(String error) {
    return 'Sign-up error: $error';
  }

  @override
  String googleError(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String appleError(String error) {
    return 'Apple sign-in failed: $error';
  }

  @override
  String facebookError(String error) {
    return 'Facebook sign-in failed: $error';
  }

  @override
  String get loginSubtitleSignup => 'Create your SayDo account';

  @override
  String get loginSubtitleLogin => 'Connect to your SayDo account';

  @override
  String get signIn => 'Sign In';

  @override
  String get dividerOr => 'Or';

  @override
  String get createAccountArrow => 'Create account →';

  @override
  String get loginTab => 'Login';

  @override
  String get signUpTab => 'Sign up';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbGetStarted => 'Get Started';

  @override
  String get onbTag => 'AI VOICE ASSISTANT';

  @override
  String get onbBubble => '\"Remind me...\"';

  @override
  String get onbTaskCreated => 'Task created';

  @override
  String get onbHeadline => 'Say it. Do it.';

  @override
  String get onbDesc1 =>
      'Your smart personal assistant.\nSpeak naturally, SayDo\nturns every word into action.';

  @override
  String get onbWelcome => 'WELCOME';

  @override
  String get onbDesc2 => 'Just say it out loud,\nSayDo manages your schedule.';

  @override
  String get onbAgenda => 'Agenda';

  @override
  String get onbSmart => 'SMART\nUNDERSTANDING';

  @override
  String get onbDesc3 =>
      'Mix Darija, French, and English naturally.\nSayDo extracts dates, tasks, and people effortlessly.';

  @override
  String get eventsSubtitle => 'Your upcoming appointments and tasks';

  @override
  String eventsLoadError(String error) {
    return 'Couldn\'t load events.\n$error';
  }

  @override
  String get eventsEmpty => 'No events yet.';

  @override
  String get eventsEmptyHint => 'Tap the microphone to dictate one.';

  @override
  String get eventsAllUpcoming => 'All upcoming events';

  @override
  String get eventSynced => 'Synced with Google Calendar';

  @override
  String get eventPendingSync => 'Waiting to sync';

  @override
  String get homeSaved => 'Saved. It will sync to Google shortly.';

  @override
  String get homeSpeakTo => 'Talk to ';

  @override
  String get homeListening => 'Listening... tap to send';

  @override
  String get homeProcessing => 'Processing...';

  @override
  String get homeTapRetry => 'Tap to start over';

  @override
  String get homeDefaultHint =>
      'Create an event or a task\njust with your voice.';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsDeleteTitle => 'Delete this contact?';

  @override
  String contactsDeleteBody(String name, String email) {
    return '$name ($email) will be deleted. Past emails are not affected.';
  }

  @override
  String contactsLoadError(String error) {
    return 'Couldn\'t load contacts.\n$error';
  }

  @override
  String get contactsEmpty => 'No contacts yet.';

  @override
  String get contactsEmptyHint =>
      'Add one here, or they are\nsaved automatically\nwhen you send an email.';

  @override
  String get contactDuplicate => 'You already have a contact with this name.';

  @override
  String get contactEdit => 'Edit contact';

  @override
  String get contactNew => 'New contact';

  @override
  String get proposalNewEvent => 'New event';

  @override
  String get proposalNewEmail => 'New email';

  @override
  String get proposalNewTask => 'New task';

  @override
  String get voiceSaved => 'Saved successfully! 🎉';

  @override
  String get voiceTitle => 'SayDo Voice';

  @override
  String get voiceSubtitle => 'Create a task or an appointment';

  @override
  String get voiceListening => 'Listening... Tap to confirm';

  @override
  String get voiceProcessing => 'SayDo is processing...';

  @override
  String get voiceDone => 'Analysis complete';

  @override
  String get voiceTapToSpeak => 'Tap to speak';

  @override
  String get voiceSpeakNaturally =>
      'Speak naturally, SayDo takes care of the rest.';

  @override
  String get voiceRecognizing => 'Recognizing speech & extracting details...';

  @override
  String get voiceExample =>
      'e.g. \"Appointment tomorrow at 2 PM with Sophie\" or \"Buy milk\"';

  @override
  String get gotIt => 'Got it';

  @override
  String get close => 'Close';

  @override
  String get great => 'Great!';

  @override
  String get emailsTapToCreate => 'Tap to create an email with voice';

  @override
  String previewSaid(String text) {
    return 'You said: $text';
  }

  @override
  String previewAgentAsks(String question) {
    return 'The agent asks: $question';
  }

  @override
  String previewType(String type) {
    return 'Type: $type';
  }

  @override
  String previewTitle(String title) {
    return 'Title: $title';
  }

  @override
  String previewDate(String date) {
    return 'Date: $date';
  }

  @override
  String previewTime(String time) {
    return 'Time: $time';
  }

  @override
  String previewPeople(String people) {
    return 'People: $people';
  }
}
