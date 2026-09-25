import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

// Widget tests have no native video player, so every video fails to load,
// just like a missing or corrupt file on a device.

Future<void> openLesson(WidgetTester tester, String lesson) async {
  await tester.tap(find.text('مقدمة في التشريح'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(lesson));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a video that cannot load shows an error, not a red screen', (
    tester,
  ) async {
    await pumpThaheenApp(tester);
    await openLesson(tester, 'العظام');

    expect(find.text('تعذّر تشغيل هذا الفيديو'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Next lesson stays locked until this lesson is completed', (
    tester,
  ) async {
    await pumpThaheenApp(tester);
    await openLesson(tester, 'العظام');

    await tester.tap(find.textContaining('الدرس التالي'));
    await tester.pump();
    expect(
      find.text('شاهد 90% من هذا الدرس لفتح الدرس التالي'),
      findsOneWidget,
    );
  });

  testWidgets('Next lesson opens the next lesson once completed', (
    tester,
  ) async {
    await pumpThaheenApp(
      tester,
      prefs: savedProgress(
        'anatomy-101',
        'l1',
        positionMs: 19000,
        durationMs: 20000,
        completed: true,
      ),
    );
    await openLesson(tester, 'العظام');

    await tester.tap(find.textContaining('الدرس التالي'));
    await tester.pumpAndSettle();

    // The app bar now shows the second lesson.
    expect(find.text('المفاصل'), findsWidgets);
    expect(find.textContaining('أنواع العضلات'), findsOneWidget);
  });
}
