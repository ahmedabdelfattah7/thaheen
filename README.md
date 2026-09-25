Thaheen — Mini Offline LMS

An Arabic-first, fully offline Flutter LMS built for the Thaheen screening task.

Students can browse courses, open lessons, watch videos, save notes, and resume their progress after restarting the app.

Courses	Course Details	Player	English + Dark	Video Error
				

Run

Flutter 3.47 stable / Dart 3.13

flutter pub get
flutter run
flutter test
flutter build apk --release

Demo videos and thumbnails are bundled with the app.

Features

* Course list with progress and Continue Watching
* Course sections and sequential lesson unlocking
* Video playback with:
    * Play / pause
    * Seek bar
    * Playback speed: 1x–2x
    * Resume from saved position
    * Fullscreen + orientation support
* Automatic completion at 90%
* Persistent progress, notes, settings, language and playback speed
* Arabic-first RTL UI with bundled Tajawal font
* Arabic / English course content
* Light / dark mode
* Course search
* Loading, empty and error states
* Fully offline — no network calls

Architecture

lib/
├── core/           # Theme, localization, router, shared UI
├── domain/         # Models + learning rules
├── data/           # JSON catalog + SharedPreferences
└── presentation/   # Screens, Cubits and widgets

Flow:

Presentation → Data → Domain

State Management

Using Cubit (flutter_bloc):

Cubit	Responsibility
SettingsCubit	Theme and language
CoursesCubit	Catalog, progress and search
PlayerCubit	Playback, progress, speed and fullscreen
NotesCubit	Lesson notes

Screens are kept as StatelessWidget where possible. UI state and business logic live in Cubits.

The main learning rules are centralized in the pure:

domain/progress_rules.dart

It handles completion, unlocking, course progress, resume position, continue watching and next lesson logic.

Dependency Injection

Uses RepositoryProvider with repositories created once in main.dart.

No service locator and no unnecessary use-case classes.

Persistence

Uses SharedPreferences for:

* Lesson progress
* Completion state
* Notes
* Theme
* Language
* Playback speed

Progress is stored as a versioned JSON map.

Corrupt local data is handled gracefully by starting with clean state instead of crashing.

Learning Rules

* A lesson is completed at ≥90% of the real video duration.
* Completed lessons remain completed even when rewatched.
* Lessons unlock sequentially, including across sections.
* Course progress = completed lessons / total lessons.
* Resume starts from the saved position.
* Progress is saved every 5 seconds, on pause, when leaving the lesson, and immediately on completion.

Arabic & RTL

* Arabic is the default language.
* Full RTL layout using directional Flutter APIs.
* Tajawal is bundled for Arabic and Latin text.
* Arabic/English course content.
* Direction-aware navigation icons.
* ICU Arabic pluralization.
* Unicode isolates for mixed Arabic/English text.

Error Handling

The app handles:

* Missing/corrupt catalog
* Empty courses
* No search results
* Missing thumbnails
* Missing/corrupt/unsupported videos
* Video loading timeout
* Corrupt local storage

Unexpected Flutter build errors also use a custom fallback instead of showing a red screen.

Tests

37 tests covering:

* ProgressRules
* Unlock and completion rules
* Course progress
* Resume behavior
* Continue Watching
* Repository persistence
* Corrupt storage/catalog
* Arabic/English UI
* Search
* Locked lessons
* Empty states
* Video errors
* Next-lesson gating

Demo Edge Cases

The demo includes:

* A course with no lessons → empty state
* A course without a thumbnail → placeholder
* An intentionally corrupt final video → video error state

The videos are short, silent H.264 clips generated specifically for the demo.

Trade-offs

* Completion is position-based, so seeking past 90% completes a lesson.
* Search does not normalize Arabic characters such as أ / إ / آ.
* No wakelock during playback.
* Demo videos are silent.
* Integration and golden tests are not included yet.
* go_router is pinned to 17.x due to compatibility with the current Material setup.

With More Time

* Watched-segment completion instead of position-based completion
* Arabic search normalization
* Wakelock during playback
* Captions and ±10 second seeking
* Integration tests and RTL golden tests
* CI with analyze + test

Time Spent

About X hours.
