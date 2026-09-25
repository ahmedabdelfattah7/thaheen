import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'Thaheen'**
  String get appTitle;

  /// No description provided for @myCourses.
  ///
  /// In ar, this message translates to:
  /// **'دوراتي'**
  String get myCourses;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دورة أو مُحاضر'**
  String get searchHint;

  /// No description provided for @continueWatching.
  ///
  /// In ar, this message translates to:
  /// **'تابع المشاهدة'**
  String get continueWatching;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'استئناف'**
  String get resume;

  /// No description provided for @lessonsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد دروس} =1{درس واحد} =2{درسان} few{{count} دروس} many{{count} درسًا} other{{count} درس}}'**
  String lessonsCount(int count);

  /// No description provided for @percentComplete.
  ///
  /// In ar, this message translates to:
  /// **'{percent} مكتمل'**
  String percentComplete(String percent);

  /// No description provided for @completedOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'أكملت {completed} من {total}'**
  String completedOfTotal(int completed, int total);

  /// No description provided for @noCourses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات حاليًا'**
  String get noCourses;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لـ «{query}»'**
  String noSearchResults(String query);

  /// No description provided for @loadCoursesError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الدورات'**
  String get loadCoursesError;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @courseNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الدورة غير موجودة'**
  String get courseNotFound;

  /// No description provided for @emptyCourse.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دروس في هذه الدورة بعد'**
  String get emptyCourse;

  /// No description provided for @statusNotStarted.
  ///
  /// In ar, this message translates to:
  /// **'لم يبدأ'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد المشاهدة'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusLocked.
  ///
  /// In ar, this message translates to:
  /// **'مقفل'**
  String get statusLocked;

  /// No description provided for @lockedLessonMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا الدرس مقفل. أكمل الدرس السابق أولًا لفتحه.'**
  String get lockedLessonMessage;

  /// No description provided for @lessonNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الدرس غير موجود'**
  String get lessonNotFound;

  /// No description provided for @videoError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل هذا الفيديو'**
  String get videoError;

  /// No description provided for @videoErrorHint.
  ///
  /// In ar, this message translates to:
  /// **'قد يكون الملف مفقودًا أو تالفًا.'**
  String get videoErrorHint;

  /// No description provided for @playbackSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل'**
  String get playbackSpeed;

  /// No description provided for @play.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pause;

  /// No description provided for @enterFullscreen.
  ///
  /// In ar, this message translates to:
  /// **'ملء الشاشة'**
  String get enterFullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من ملء الشاشة'**
  String get exitFullscreen;

  /// No description provided for @nextLesson.
  ///
  /// In ar, this message translates to:
  /// **'الدرس التالي'**
  String get nextLesson;

  /// No description provided for @nextLessonLocked.
  ///
  /// In ar, this message translates to:
  /// **'شاهد 90% من هذا الدرس لفتح الدرس التالي'**
  String get nextLessonLocked;

  /// No description provided for @lessonCompleted.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! اكتمل الدرس'**
  String get lessonCompleted;

  /// No description provided for @lastLesson.
  ///
  /// In ar, this message translates to:
  /// **'هذا آخر درس في الدورة'**
  String get lastLesson;

  /// No description provided for @backToCourse.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الدورة'**
  String get backToCourse;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظاتك على هذا الدرس…'**
  String get notesHint;

  /// No description provided for @notesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get notesSaved;

  /// No description provided for @switchLanguage.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get switchLanguage;

  /// No description provided for @toggleTheme.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الوضع الليلي'**
  String get toggleTheme;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
