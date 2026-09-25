import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<void> openCourse(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    find.text(title),
    300,
    scrollable: find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.ensureVisible(find.text(title));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a locked lesson shows a friendly message', (
    tester,
  ) async {
    await pumpThaheenApp(tester);
    await openCourse(tester, 'مقدمة في التشريح');

    // Only the first lesson is open on a fresh start.
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(3));

    await tester.tap(find.text('المفاصل'));
    await tester.pump();
    expect(
      find.text('هذا الدرس مقفل. أكمل الدرس السابق أولًا لفتحه.'),
      findsOneWidget,
    );
  });

  testWidgets('completing a lesson unlocks the next one', (tester) async {
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
    await openCourse(tester, 'مقدمة في التشريح');

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    expect(find.textContaining('أكملت 1 من 4'), findsOneWidget);
  });

  testWidgets('a course without lessons shows the empty state', (tester) async {
    await pumpThaheenApp(tester);
    await openCourse(tester, 'علم الأحياء الدقيقة');

    expect(find.text('لا توجد دروس في هذه الدورة بعد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
