// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Thaheen';

  @override
  String get myCourses => 'دوراتي';

  @override
  String get searchHint => 'ابحث عن دورة أو مُحاضر';

  @override
  String get continueWatching => 'تابع المشاهدة';

  @override
  String get resume => 'استئناف';

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      many: '$count درسًا',
      few: '$count دروس',
      two: 'درسان',
      one: 'درس واحد',
      zero: 'لا توجد دروس',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(String percent) {
    return '$percent مكتمل';
  }

  @override
  String completedOfTotal(int completed, int total) {
    return 'أكملت $completed من $total';
  }

  @override
  String get noCourses => 'لا توجد دورات حاليًا';

  @override
  String noSearchResults(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get loadCoursesError => 'تعذّر تحميل الدورات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get courseNotFound => 'الدورة غير موجودة';

  @override
  String get emptyCourse => 'لا توجد دروس في هذه الدورة بعد';

  @override
  String get statusNotStarted => 'لم يبدأ';

  @override
  String get statusInProgress => 'قيد المشاهدة';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusLocked => 'مقفل';

  @override
  String get lockedLessonMessage =>
      'هذا الدرس مقفل. أكمل الدرس السابق أولًا لفتحه.';

  @override
  String get lessonNotFound => 'الدرس غير موجود';

  @override
  String get videoError => 'تعذّر تشغيل هذا الفيديو';

  @override
  String get videoErrorHint => 'قد يكون الملف مفقودًا أو تالفًا.';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get enterFullscreen => 'ملء الشاشة';

  @override
  String get exitFullscreen => 'الخروج من ملء الشاشة';

  @override
  String get nextLesson => 'الدرس التالي';

  @override
  String get nextLessonLocked => 'شاهد 90% من هذا الدرس لفتح الدرس التالي';

  @override
  String get lessonCompleted => 'أحسنت! اكتمل الدرس';

  @override
  String get lastLesson => 'هذا آخر درس في الدورة';

  @override
  String get backToCourse => 'العودة إلى الدورة';

  @override
  String get notes => 'ملاحظاتي';

  @override
  String get notesHint => 'اكتب ملاحظاتك على هذا الدرس…';

  @override
  String get notesSaved => 'تم الحفظ';

  @override
  String get switchLanguage => 'English';

  @override
  String get toggleTheme => 'تبديل الوضع الليلي';
}
