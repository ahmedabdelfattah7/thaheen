import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('lists courses in Arabic with lesson count and progress', (
    tester,
  ) async {
    await pumpThaheenApp(tester);

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('مقدمة في التشريح'), findsOneWidget);
    expect(find.textContaining('4 دروس'), findsOneWidget);
    expect(find.textContaining('مكتمل'), findsWidgets);
    // Nothing started yet, so no "Continue watching" card.
    expect(find.text('تابع المشاهدة'), findsNothing);
  });

  testWidgets('shows a continue-watching card for an unfinished lesson', (
    tester,
  ) async {
    await pumpThaheenApp(
      tester,
      prefs: savedProgress(
        'anatomy-101',
        'l1',
        positionMs: 8000,
        durationMs: 20000,
      ),
    );

    expect(find.text('تابع المشاهدة'), findsOneWidget);
    expect(find.text('العظام'), findsOneWidget);
  });

  testWidgets('search filters courses and explains an empty result', (
    tester,
  ) async {
    await pumpThaheenApp(tester);

    await tester.enterText(find.byType(TextField), 'الأدوية');
    await tester.pumpAndSettle();
    expect(find.text('أساسيات علم الأدوية'), findsOneWidget);
    expect(find.text('مقدمة في التشريح'), findsNothing);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets('a corrupt catalog shows an error with retry, not a crash', (
    tester,
  ) async {
    await pumpThaheenApp(tester, bundle: FakeBundle('{"courses": ['));

    expect(find.text('تعذّر تحميل الدورات'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English flips the layout to LTR and translates courses', (
    tester,
  ) async {
    await pumpThaheenApp(tester);
    expect(
      Directionality.of(tester.element(find.text('دوراتي'))),
      TextDirection.rtl,
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('My courses'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('My courses'))),
      TextDirection.ltr,
    );
    // Course content is translated too.
    expect(find.text('Introduction to Anatomy'), findsOneWidget);
    expect(find.text('مقدمة في التشريح'), findsNothing);

    await tester.enterText(find.byType(TextField), 'pharma');
    await tester.pumpAndSettle();
    expect(find.text('Pharmacology Basics'), findsOneWidget);
    expect(find.text('Introduction to Anatomy'), findsNothing);
  });
}
