import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/data/course_repository.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the bundled catalog', () async {
    final courses = await CourseRepository().getCourses();

    expect(courses, hasLength(3));
    final anatomy = courses.first;
    expect(anatomy.title.of('ar'), 'مقدمة في التشريح');
    expect(anatomy.title.of('en'), 'Introduction to Anatomy');
    expect(anatomy.lessons.first.title.of('en'), 'Bones');
    expect(anatomy.sections, hasLength(2));
    expect(anatomy.lessons.map((l) => l.id), ['l1', 'l2', 'l3', 'l4']);
    expect(anatomy.lessons.first.duration, const Duration(seconds: 20));
    // The "coming soon" course has no lessons (empty state demo).
    expect(courses.last.lessons, isEmpty);
  });

  test(
    'a plain-string title is Arabic only; English falls back to it',
    () async {
      final repository = CourseRepository(
        bundle: FakeBundle(
          '{"courses": [{"id": "c", "title": "عنوان", "sections": []}]}',
        ),
      );
      final course = (await repository.getCourses()).single;
      expect(course.title.of('ar'), 'عنوان');
      expect(course.title.of('en'), 'عنوان');
    },
  );

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
