// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تنظيم';

  @override
  String common_appIconLabel(String appName) {
    return 'شعار $appName';
  }

  @override
  String get common_back => 'رجوع';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_couldNotSave => 'تعذّر الحفظ. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get common_getStarted => 'ابدأ';

  @override
  String get common_loadFailed => 'تعذّر تحميل البيانات.';

  @override
  String get common_loading => 'جارٍ التحميل';

  @override
  String get common_monthsShort => 'يناير|فبراير|مارس|أبريل|مايو|يونيو|يوليو|أغسطس|سبتمبر|أكتوبر|نوفمبر|ديسمبر';

  @override
  String get common_navHome => 'الرئيسية';

  @override
  String get common_navProgress => 'التقدم';

  @override
  String get common_navTasks => 'المهام';

  @override
  String get common_navTeam => 'الفريق';

  @override
  String get common_offlineBanner => 'لا يوجد اتصال. يمكنك قراءة المهام التي جرى تحميلها. التعديل يحتاج إلى اتصال.';

  @override
  String get common_retry => 'حاول مرة أخرى';

  @override
  String get common_skip => 'تخطي';

  @override
  String get common_tagline => 'من يفعل ماذا، ومتى.';

  @override
  String get common_weekdaysShort => 'الاثنين|الثلاثاء|الأربعاء|الخميس|الجمعة|السبت|الأحد';

  @override
  String get errors_emailTaken => 'هذا البريد مستخدم بالفعل.';

  @override
  String get errors_forbidden => 'لا تملك صلاحية القيام بذلك.';

  @override
  String get errors_invalidCredentials => 'البريد أو كلمة المرور غير صحيحين. حاول مرة أخرى أو أعد تعيين كلمة المرور.';

  @override
  String get errors_lastAdmin => 'اجعل عضوًا آخر مسؤولًا قبل أن تغادر.';

  @override
  String get errors_network => 'لا يوجد اتصال. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get errors_notAssignee => 'صاحب المهمة وحده يستطيع تغييرها.';

  @override
  String get errors_planRequired => 'هذه الميزة جزء من خطة مدفوعة.';

  @override
  String get errors_taskConflict => 'غيّر شخص آخر هذه المهمة قبلك. تم تحديثها.';

  @override
  String get errors_taskNotFound => 'هذه المهمة لم تعد موجودة.';

  @override
  String get errors_unauthenticated => 'سجّل الدخول للمتابعة.';

  @override
  String get errors_unknown => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errors_validation => 'تحقق من المعلومات وحاول مرة أخرى.';

  @override
  String get notifications_allowAction => 'السماح بالتذكيرات';

  @override
  String notifications_allowBody(String appName) {
    return 'يخبرك $appName عند إسناد مهمة إليك وقبل الموعد النهائي. يمكنك تغيير ذلك من الإعدادات.';
  }

  @override
  String get notifications_allowNotNow => 'ليس الآن';

  @override
  String get notifications_allowTitle => 'السماح بالتذكيرات؟';

  @override
  String get onboarding_body1 => 'لكل مهمة مسؤول واحد وموعد واحد، أمام أعين الفريق.';

  @override
  String get onboarding_body2 => 'تعرض اللوحة ما أُنجز وما تأخر ومن يتولى ماذا.';

  @override
  String get onboarding_body3 => 'يصلك تذكير واحد لكل مهمة قبل الموعد النهائي، لا بعده.';

  @override
  String onboarding_step(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboarding_title1 => 'الجميع يرى من المسؤول عن ماذا';

  @override
  String get onboarding_title2 => 'التقدم بنظرة واحدة';

  @override
  String get onboarding_title3 => 'تذكير قبل الموعد';

  @override
  String get settings_changePassword => 'تغيير كلمة المرور';

  @override
  String get settings_editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get settings_email => 'البريد الإلكتروني';

  @override
  String get settings_emailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get settings_feedbackAbout => 'ما موضوعها؟';

  @override
  String get settings_feedbackEmpty => 'اكتب بضع كلمات أولًا.';

  @override
  String get settings_feedbackHint => 'صفها في بضع كلمات';

  @override
  String get settings_feedbackIntro => 'أخبرنا بما يفيد فريقك. سنعلمك عند إنجازه.';

  @override
  String get settings_feedbackMessage => 'رسالتك';

  @override
  String get settings_feedbackSend => 'إرسال الملاحظات';

  @override
  String get settings_feedbackThanks => 'شكرًا. وصلتنا رسالتك.';

  @override
  String get settings_feedbackTitle => 'ملاحظات';

  @override
  String get settings_fullName => 'الاسم الكامل';

  @override
  String get settings_kindIdea => 'فكرة';

  @override
  String get settings_kindOther => 'شيء آخر';

  @override
  String get settings_kindProblem => 'مشكلة';

  @override
  String get settings_languageArabicSub => 'العربية، من اليمين إلى اليسار';

  @override
  String get settings_languageEnglishSub => 'الإنجليزية';

  @override
  String get settings_languageFrenchSub => 'الفرنسية';

  @override
  String get settings_languageNote => 'تتحول كل الشاشات إلى تخطيط من اليمين إلى اليسار عند اختيار العربية.';

  @override
  String get settings_languageTitle => 'اللغة';

  @override
  String get settings_nameRequired => 'أدخل اسمك.';

  @override
  String get settings_policyDelete => 'يمكنك طلب حذف حسابك وبياناتك في أي وقت.';

  @override
  String get settings_policyPush => 'تحمل الإشعارات الفورية نصًا عامًا ولا تذكر عنوان المهمة.';

  @override
  String get settings_policyServer => 'تُخزَّن البيانات على خادم في الجزائر.';

  @override
  String get settings_policyStored => 'البيانات المحفوظة: اسمك وبريدك وعضويتك في الفرق ومهامك.';

  @override
  String get settings_privacyAgree => 'أوافق وأتابع';

  @override
  String get settings_privacyConsent => 'أوافق على معالجة بياناتي الشخصية';

  @override
  String settings_privacyIntro(String appName) {
    return 'يحتفظ $appName بما يحتاجه فقط: اسمك وبريدك والمهام في فرقك.';
  }

  @override
  String get settings_privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get settings_privacyReadPolicy => 'اقرأ سياسة الخصوصية كاملة';

  @override
  String get settings_privacyStorage => 'بياناتك مخزنة على خادم في الجزائر. لا تعرض الإشعارات نص المهام. يمكنك أن تطلب منا حذف حسابك وبياناتك في أي وقت.';

  @override
  String get settings_privacyTitle => 'الخصوصية وبياناتك';

  @override
  String get settings_profileSaved => 'تم حفظ الملف الشخصي.';

  @override
  String get settings_saveChanges => 'حفظ التغييرات';

  @override
  String get settings_signOut => 'تسجيل الخروج';

  @override
  String get settings_signOutBody => 'ستحتاج إلى بريدك وكلمة مرورك للعودة.';

  @override
  String settings_signOutTitle(String appName) {
    return 'تسجيل الخروج من $appName؟';
  }

  @override
  String get settings_staySignedIn => 'البقاء متصلًا';

  @override
  String get settings_usePhoneLanguage => 'استخدم لغة الهاتف';

  @override
  String get tasks_backToTasks => 'العودة إلى المهام';

  @override
  String get tasks_boardTitle => 'اللوحة';

  @override
  String get tasks_cannotMoveCard => 'صاحب المهمة وحده يستطيع نقل هذه البطاقة.';

  @override
  String get tasks_changeStatus => 'تغيير الحالة';

  @override
  String tasks_doneBody(String name, int done, int total) {
    return 'شكرًا يا $name. أنجز الفريق $done من $total مهمة.';
  }

  @override
  String get tasks_doneLabel => 'منجزة';

  @override
  String tasks_doneTitle(String title) {
    return 'اكتملت مهمة $title';
  }

  @override
  String get tasks_dueTomorrowTag => 'مستحقة غدًا';

  @override
  String get tasks_emptyBodyCreator => 'تظهر هنا المهام التي تملكها مع موعدها. أضف مهمة، أو اطلب من زميل أن يسند إليك واحدة.';

  @override
  String get tasks_emptyBodyMember => 'تظهر هنا المهام التي تملكها مع موعدها. اطلب من مدير أو مسؤول أن يسند إليك واحدة.';

  @override
  String get tasks_emptyTitle => 'لا توجد مهام مسندة إليك';

  @override
  String get tasks_labelDueTomorrow => 'مستحقة غدًا';

  @override
  String get tasks_labelOverdue => 'متأخرة';

  @override
  String get tasks_loading => 'جارٍ تحميل المهام';

  @override
  String get tasks_newTask => 'مهمة جديدة';

  @override
  String get tasks_overdueTag => 'متأخرة';

  @override
  String tasks_ownerWithLabel(String name, String label) {
    return '$name، $label';
  }

  @override
  String tasks_progressCount(int done, int total) {
    return '$done من $total';
  }

  @override
  String get tasks_statusDone => 'منجزة';

  @override
  String get tasks_statusInProgress => 'قيد التنفيذ';

  @override
  String get tasks_statusTodo => 'للتنفيذ';

  @override
  String get tasks_undo => 'تراجع';
}
