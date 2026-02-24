# Blog App

A Flutter mobile application for reading and interacting with articles and image-based posts. Features include authentication, article listing/detail pages, user profiles, and a flexible comments system supporting article-level and per-image comments.

**Project status:** Prototype / Early development

**Tech stack:** Flutter, Dart, Riverpod (state management), Supabase (backend/storage adapters)

**Repository layout:** see [project_architecture](project_architecture)

**Core concepts:**
- **Feature-first layout:** Each feature (auth, blogs, comments, profiles) groups `data`, `presentation`, and `state`.
- **State management:** Riverpod with `AsyncNotifier`/`AsyncNotifierProvider` for async operations and fine-grained loading/error states.
- **Comments model:** Supports article-level and image-level comments stored as maps keyed by `articleId` or `imageId` in `CommentsState`.

**Features**
- Authentication (signup/login)
- Article list and detail views
- User profiles
- Comments with nested replies and media attachments (images/files)

**Getting started (development)**

Prerequisites:
- Install Flutter SDK (stable channel) and set up platform tooling for Android/iOS.
- Optional: Android Studio / Xcode for device emulators.

Clone and install dependencies:

```bash
git clone <repo-url>
cd blog_app
flutter pub get
```

Environment / secrets:
- The app uses Supabase (or similar) for backend services. Provide your endpoint and anon key via environment or runtime config expected by `core/services` (e.g. `.env` or build-time variables). Check `core/services` for the exact config keys used.

Run on a device/emulator:

```bash
flutter run
```

Build APK (Android):

```bash
flutter build apk --release
```

Build iOS (macOS required):

```bash
flutter build ios --release
```

Testing
- Unit & widget tests: `flutter test`

Developer notes
- The comments system lives under `lib/features/comments`.
	- Controller: `lib/features/comments/state/comments_controller.dart` (uses `AsyncNotifier<CommentsState>`)
	- Service: `lib/features/comments/data/comments_service.dart` (API calls)
- When fetching or mutating comments, the controller updates maps keyed by id so the UI can efficiently render comment lists per-article or per-image.
- Follow the existing feature pattern when adding new screens: `data/`, `presentation/`, and `state/` subfolders.

Contributing
- Fork the repo, create a feature branch, and open a pull request. Keep changes scoped and add tests for new logic.

License
- Add a license file if you'd like to open-source this project.

Questions or next steps
- If you want, I can add a CONTRIBUTING.md, example `.env` template, or CI configuration to run tests and format checks.
