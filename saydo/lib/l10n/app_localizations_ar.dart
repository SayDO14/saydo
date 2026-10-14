// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navEvents => 'الأحداث';

  @override
  String get navTasks => 'المهام';

  @override
  String get navEmails => 'البريد';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get emailsTitle => 'البريد الإلكتروني';

  @override
  String get emailsSubtitle => 'رسائلك بسرعة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterReceived => 'الواردة';

  @override
  String get filterSent => 'المرسلة';

  @override
  String get emailsEmpty => 'لا توجد رسائل حاليًا.';

  @override
  String get emailsEmptyHint => 'أملِ رسالة باستخدام الميكروفون.';

  @override
  String loadError(String error) {
    return 'تعذّر تحميل الرسائل.\n$error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get statusSent => 'مرسلة';

  @override
  String get statusReceived => 'واردة';

  @override
  String sentOn(String date, String time) {
    return 'أُرسلت في $date · $time';
  }

  @override
  String createdOn(String date, String time) {
    return 'أُنشئت في $date · $time';
  }

  @override
  String get messageLabel => 'الرسالة';

  @override
  String get language => 'اللغة';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get required => 'مطلوب';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String errorWithMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String saveError(String error) {
    return 'تعذّر الحفظ: $error';
  }

  @override
  String deleteError(String error) {
    return 'تعذّر الحذف: $error';
  }

  @override
  String get fieldTitle => 'العنوان';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get fieldTime => 'الوقت';

  @override
  String get fieldDueDateOptional => 'تاريخ الاستحقاق (اختياري)';

  @override
  String get fieldPeople => 'الأشخاص (مفصولة بفاصلة)';

  @override
  String get fieldToName => 'إلى (الاسم)';

  @override
  String get fieldSubject => 'الموضوع';

  @override
  String get fieldMessage => 'الرسالة';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get noDate => 'بدون تاريخ';

  @override
  String get upcoming => 'القادمة';

  @override
  String get past => 'السابقة';

  @override
  String get today => 'اليوم';

  @override
  String get showAll => 'عرض الكل';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get next => 'التالي';

  @override
  String get tasksTitle => 'مهامي';

  @override
  String get tasksSubtitle => 'نظّم أولوياتك';

  @override
  String get tasksTodo => 'للإنجاز';

  @override
  String get tasksDone => 'المكتملة';

  @override
  String get tasksFilterAll => 'الكل';

  @override
  String get tasksPriority => 'ذات أولوية';

  @override
  String get tasksMarkTodo => 'تعيين كغير منجزة';

  @override
  String get tasksMarkDone => 'تعيين كمنجزة';

  @override
  String get tasksDeleteTitle => 'حذف المهمة؟';

  @override
  String tasksDeleteBody(String title) {
    return 'سيتم حذف \"$title\" نهائيًا.';
  }

  @override
  String tasksUpdateError(String error) {
    return 'تعذّر تحديث المهمة: $error';
  }

  @override
  String tasksLoadError(String error) {
    return 'خطأ في التحميل\n$error';
  }

  @override
  String get tasksAddByVoice => 'أضف مهمة بصوتك';

  @override
  String get tasksEmpty => 'لا توجد مهام حاليًا';

  @override
  String get tasksEmptyHint => 'أملِ مهمة باستخدام الميكروفون';

  @override
  String get tasksEditTitle => 'تعديل المهمة';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsProfileSub => 'الاسم، الصورة، النبذة';

  @override
  String get settingsAccountSecurity => 'الحساب والأمان';

  @override
  String get settingsAccountSecuritySub => 'تغيير الحساب، كلمة المرور';

  @override
  String get settingsTimezone => 'المنطقة الزمنية';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsCalendar => 'التقويم المتصل';

  @override
  String get settingsPrivacy => 'الخصوصية والأمان';

  @override
  String get settingsHelp => 'المساعدة والدعم';

  @override
  String get calendarSyncedTitle => 'تمت مزامنة التقويم';

  @override
  String get calendarSyncedBody =>
      'تتم مزامنة أحداثك الصوتية المؤكدة تلقائيًا مع Google Calendar.';

  @override
  String get privacyTitle => 'الخصوصية والأمان';

  @override
  String get privacyBody =>
      'يحترم SayDo خصوصيتك. تُحوَّل تسجيلاتك الصوتية إلى نص وتُعالَج بشكل آمن دون بيعها أو مشاركتها مع أطراف ثالثة.';

  @override
  String get helpBody =>
      'يفهم SayDo الفرنسية والدارجة الجزائرية والإنجليزية.\n\nاضغط على الميكروفون وتحدّث بشكل طبيعي لإنشاء اجتماعات ومهام أو إرسال رسائل بريد إلكتروني!';

  @override
  String get placeholderMessage => 'إعدادات الحساب والتفضيلات...';

  @override
  String get profileNameUpdated => 'تم تعديل الاسم بنجاح.';

  @override
  String get profileAvatarSelected => 'تم اختيار صورة SayDo الرمزية بنجاح.';

  @override
  String get profilePhoto => 'صورة الملف الشخصي';

  @override
  String get profileAvatarRobot => 'صورة الروبوت SayDo';

  @override
  String get profileCurrentlyUsed => 'مستخدمة حاليًا';

  @override
  String get profileChooseGallery => 'اختيار من المعرض';

  @override
  String get profileImportImage => 'استيراد صورة شخصية';

  @override
  String get profileGallerySoon => 'معرض الصور قريبًا';

  @override
  String get profileYourName => 'اسمك';

  @override
  String get profileBio => 'نبذة';

  @override
  String get profileBioHint => 'عرّف بنفسك باختصار...';

  @override
  String get profileUpdate => 'تحديث المعلومات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String get securityChangePassword => 'تغيير كلمة المرور';

  @override
  String get securityNewPassword => 'كلمة المرور الجديدة';

  @override
  String get securityMin6 => '6 أحرف على الأقل';

  @override
  String get securityRepeat => 'أعد كتابة كلمة المرور';

  @override
  String get passwordTooShort =>
      'يجب أن تتكوّن كلمة المرور من 6 أحرف على الأقل';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get securityPasswordUpdated => '✅ تم تحديث كلمة المرور بنجاح!';

  @override
  String get securityUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get securitySwitchTitle => 'تغيير الحساب؟';

  @override
  String get securitySwitchBody =>
      'سيتم تسجيل خروجك من هذا الحساب لتتمكن من الدخول بحساب آخر.';

  @override
  String get securityLogoutTitle => 'تسجيل الخروج؟';

  @override
  String get securityLogoutBody => 'هل تريد فعلًا تسجيل الخروج من SayDo؟';

  @override
  String get logoutAction => 'تسجيل الخروج';

  @override
  String get securitySwitchAccount => 'تغيير الحساب';

  @override
  String get securitySwitchSub => 'سجّل الخروج من هذا الحساب للدخول بحساب آخر.';

  @override
  String get securityChangePasswordSub => 'حدّث كلمة المرور لمزيد من الأمان.';

  @override
  String get securityEmailLocked =>
      'لا يمكن تعديل عنوان البريد الإلكتروني. لاستخدام عنوان آخر، يرجى تغيير الحساب.';

  @override
  String get securityLogoutButton => 'تسجيل الخروج';

  @override
  String get loginFillFields => 'يرجى إدخال بريدك الإلكتروني وكلمة المرور';

  @override
  String get signupFillFields => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح!';

  @override
  String get authInvalidEmail =>
      'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get authErrInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get authErrEmailNotConfirmed =>
      'يرجى تأكيد بريدك الإلكتروني أولاً. تحقق من صندوق الوارد.';

  @override
  String get authErrUserExists =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. جرّب تسجيل الدخول.';

  @override
  String get authErrNetwork =>
      'لا يوجد اتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get authErrWeakPassword =>
      'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';

  @override
  String get authErrRateLimit =>
      'محاولات كثيرة. انتظر قليلاً ثم حاول مرة أخرى.';

  @override
  String get authErrProviderDisabled =>
      'طريقة تسجيل الدخول هذه غير متاحة بعد.';

  @override
  String get authErrUnknown =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get authConfirmEmailSent =>
      'تم إنشاء الحساب! أكّد بريدك الإلكتروني ثم سجّل الدخول.';

  @override
  String get forgotPassword =>
      'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle =>
      'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordHint =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.';

  @override
  String get forgotPasswordSend =>
      'إرسال الرابط';

  @override
  String get forgotPasswordSent =>
      'إذا كان هناك حساب بهذا البريد، فقد تم إرسال رابط إعادة التعيين.';

  @override
  String loginError(String error) {
    return 'خطأ في تسجيل الدخول: $error';
  }

  @override
  String signupError(String error) {
    return 'خطأ في إنشاء الحساب: $error';
  }

  @override
  String googleError(String error) {
    return 'فشل تسجيل الدخول عبر Google: $error';
  }

  @override
  String appleError(String error) {
    return 'فشل تسجيل الدخول عبر Apple: $error';
  }

  @override
  String facebookError(String error) {
    return 'فشل تسجيل الدخول عبر Facebook: $error';
  }

  @override
  String get loginSubtitleSignup => 'أنشئ حسابك على SayDo';

  @override
  String get loginSubtitleLogin => 'سجّل الدخول إلى حسابك على SayDo';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dividerOr => 'أو';

  @override
  String get createAccountArrow => 'إنشاء حساب ←';

  @override
  String get loginTab => 'دخول';

  @override
  String get signUpTab => 'حساب جديد';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get onbSkip => 'تخطّي';

  @override
  String get onbGetStarted => 'ابدأ';

  @override
  String get onbTag => 'مساعد صوتي بالذكاء الاصطناعي';

  @override
  String get onbBubble => '«ذكّرني...»';

  @override
  String get onbTaskCreated => 'تم إنشاء المهمة';

  @override
  String get onbHeadline => 'قلها. نفّذها.';

  @override
  String get onbDesc1 =>
      'مساعدك الشخصي الذكي.\nتحدّث بشكل طبيعي، ويحوّل SayDo\nكل كلمة إلى فعل.';

  @override
  String get onbWelcome => 'مرحبًا';

  @override
  String get onbDesc2 => 'قلها بصوت عالٍ،\nويدير SayDo جدولك.';

  @override
  String get onbAgenda => 'الأجندة';

  @override
  String get onbSmart => 'فهم\nذكي';

  @override
  String get onbDesc3 =>
      'امزج بين الدارجة والفرنسية والإنجليزية بشكل طبيعي.\nيستخرج SayDo التواريخ والمهام والأشخاص بسهولة.';

  @override
  String get eventsSubtitle => 'مواعيدك ومهامك القادمة';

  @override
  String eventsLoadError(String error) {
    return 'تعذّر تحميل الأحداث.\n$error';
  }

  @override
  String get eventsEmpty => 'لا توجد أحداث حاليًا.';

  @override
  String get eventsEmptyHint => 'اضغط على الميكروفون لإملاء حدث.';

  @override
  String get eventsAllUpcoming => 'كل الأحداث القادمة';

  @override
  String get eventSynced => 'تمت المزامنة مع تقويم Google';

  @override
  String get eventPendingSync => 'في انتظار المزامنة';

  @override
  String get homeSaved => 'تم الحفظ. ستتم المزامنة مع Google قريبًا.';

  @override
  String get homeSpeakTo => 'تحدّث إلى ';

  @override
  String get homeListening => 'جارٍ الاستماع... اضغط للإرسال';

  @override
  String get homeProcessing => 'جارٍ المعالجة...';

  @override
  String get homeTapRetry => 'اضغط للمحاولة مجددًا';

  @override
  String get homeDefaultHint => 'أنشئ حدثًا أو مهمة\nبصوتك فقط.';

  @override
  String get contactsTitle => 'جهات الاتصال';

  @override
  String get contactsDeleteTitle => 'حذف جهة الاتصال؟';

  @override
  String contactsDeleteBody(String name, String email) {
    return 'سيتم حذف $name ($email). لا تتأثر رسائل البريد السابقة.';
  }

  @override
  String contactsLoadError(String error) {
    return 'تعذّر تحميل جهات الاتصال.\n$error';
  }

  @override
  String get contactsEmpty => 'لا توجد جهات اتصال حاليًا.';

  @override
  String get contactsEmptyHint =>
      'أضف جهة اتصال هنا، أو تُحفظ\nتلقائيًا\nعند إرسال بريد إلكتروني.';

  @override
  String get contactDuplicate => 'لديك بالفعل جهة اتصال بهذا الاسم.';

  @override
  String get contactEdit => 'تعديل جهة الاتصال';

  @override
  String get contactNew => 'جهة اتصال جديدة';

  @override
  String get proposalNewEvent => 'حدث جديد';

  @override
  String get proposalNewEmail => 'رسالة جديدة';

  @override
  String get proposalNewTask => 'مهمة جديدة';

  @override
  String get voiceSaved => 'تم الحفظ بنجاح! 🎉';

  @override
  String get voiceTitle => 'SayDo صوتي';

  @override
  String get voiceSubtitle => 'أنشئ مهمة أو موعدًا';

  @override
  String get voiceListening => 'جارٍ الاستماع... اضغط للتأكيد';

  @override
  String get voiceProcessing => 'يعالج SayDo طلبك...';

  @override
  String get voiceDone => 'اكتمل التحليل';

  @override
  String get voiceTapToSpeak => 'اضغط للتحدّث';

  @override
  String get voiceSpeakNaturally => 'تحدّث بشكل طبيعي، وSayDo يتكفّل بالباقي.';

  @override
  String get voiceRecognizing => 'التعرّف على الصوت واستخراج التفاصيل...';

  @override
  String get voiceExample =>
      'مثال: «موعد غدًا الساعة 2 مع صوفي» أو «شراء الحليب»';

  @override
  String get voiceErrorMic => 'تم رفض الوصول إلى الميكروفون. فعّله من الإعدادات.';

  @override
  String get voiceErrorNothing => 'لم يتم تسجيل أي شيء. حاول مرة أخرى.';

  @override
  String get voiceErrorNetwork => 'تعذّر الوصول إلى الخادم. تحقق من اتصالك.';

  @override
  String get voiceErrorServer => 'واجه الخادم مشكلة. حاول مجددًا بعد قليل.';

  @override
  String get gotIt => 'فهمت';

  @override
  String get close => 'إغلاق';

  @override
  String get great => 'رائع!';

  @override
  String get emailsTapToCreate => 'اضغط لإنشاء رسالة بصوتك';

  @override
  String previewSaid(String text) {
    return 'قلتَ: $text';
  }

  @override
  String previewAgentAsks(String question) {
    return 'يسأل المساعد: $question';
  }

  @override
  String previewType(String type) {
    return 'النوع: $type';
  }

  @override
  String previewTitle(String title) {
    return 'العنوان: $title';
  }

  @override
  String previewDate(String date) {
    return 'التاريخ: $date';
  }

  @override
  String previewTime(String time) {
    return 'الوقت: $time';
  }

  @override
  String previewPeople(String people) {
    return 'الأشخاص: $people';
  }
}
