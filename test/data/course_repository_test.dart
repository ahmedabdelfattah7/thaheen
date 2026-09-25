import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/data/course_repository.dart';

/// Serves a fixed string as the catalog file.
class FakeBundle extends CachingAssetBundle {
  FakeBundle(this.catalog);

  final String catalog;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(catalog)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the bundled catalog', () async {
    final courses = await CourseRepository().getCourses();

    expect(courses, hasLength(3));
    final anatomy = courses.first;
    expect(anatomy.title, 'مقدمة في التشريح');
    expect(anatomy.sections, hasLength(2));
    expect(anatomy.lessons.map((l) => l.id), ['l1', 'l2', 'l3', 'l4']);
    expect(anatomy.lessons.first.duration, const Duration(seconds: 20));
    // The "coming soon" course has no lessons (empty state demo).
    expect(courses.last.lessons, isEmpty);
  });

  test('fails with an error (not a crash) for a corrupt catalog', () async {
    final repository = CourseRepository(bundle: FakeBundle('{"courses": ['));
    await expectLater(repository.getCourses(), throwsA(isA<FormatException>()));
  });

  test('fails when a required field is missing', () async {
    final repository = CourseRepository(
      bundle: FakeBundle('{"courses": [{"title": "No id"}]}'),
    );
    await expectLater(repository.getCourses(), throwsA(isA<TypeError>()));
  });
}
