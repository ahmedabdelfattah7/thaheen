import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen/data/progress_repository.dart';
import 'package:thaheen/domain/models/lesson_progress.dart';

LessonProgress progress({int seconds = 30, bool completed = false}) =>
    LessonProgress(
      courseId: 'anatomy-101',
      lessonId: 'l1',
      position: Duration(seconds: seconds),
      duration: const Duration(seconds: 100),
      isCompleted: completed,
      updatedAt: DateTime(2026, 9, 25, 10),
    );

/// Drops the in-memory SharedPreferences instance so the next one is read
/// back from the (mocked) platform storage, like a cold app start.
Future<ProgressRepository> restartApp() async {
  SharedPreferences.resetStatic();
  return ProgressRepository(await SharedPreferences.getInstance());
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('saved progress survives an app restart', () async {
    final repository = ProgressRepository(await SharedPreferences.getInstance());
    await repository.save(progress(seconds: 42));

    final saved = (await restartApp()).get('anatomy-101', 'l1');
    expect(saved?.position, const Duration(seconds: 42));
    expect(saved?.duration, const Duration(seconds: 100));
    expect(saved?.isCompleted, isFalse);
    expect(saved?.updatedAt, DateTime(2026, 9, 25, 10));
  });

  test('completion is sticky when a completed lesson is rewatched', () async {
    final repository = ProgressRepository(await SharedPreferences.getInstance());
    await repository.save(progress(seconds: 95, completed: true));
    await repository.save(progress(seconds: 5));

    final saved = (await restartApp()).get('anatomy-101', 'l1');
    expect(saved?.position, const Duration(seconds: 5));
    expect(saved?.isCompleted, isTrue);
  });

  test('notifies listeners when progress changes', () async {
    final repository = ProgressRepository(await SharedPreferences.getInstance());
    final next = repository.changes.first;
    await repository.save(progress());
    expect((await next).keys, ['anatomy-101/l1']);
  });

  test('starts empty instead of crashing on corrupt stored data', () async {
    SharedPreferences.setMockInitialValues({'progress.v1': '{not json'});
    final repository = await restartApp();
    expect(repository.getAll(), isEmpty);
  });
}
