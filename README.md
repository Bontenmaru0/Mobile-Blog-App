# Blog App

A Flutter app for browsing blog posts with image galleries, user profiles, and a flexible comments system (article comments + per-image comments).

## Current Scope
- Auth with Supabase (`login`, `register`, `logout`)
- Article feed with pagination and title search
- Create, update, and delete articles
- Multi-image upload for articles
- Profile creation, update, and public profile viewing
- Comments on:
  - entire articles
  - individual images inside an article
- Comment create, update, delete (with optional images)
- Pull-to-refresh on article and comment lists

## Tech Stack
- Flutter (Material)
- Dart
- Riverpod (`Notifier`, `AsyncNotifier`, `StateNotifier`)
- Supabase (Auth, Storage, RPC)
- `flutter_dotenv` for local environment config

## Project Architecture
Feature-first, vertical slices:

- `lib/core`: shared models, enums, utilities, service wrappers
- `lib/features`: app features grouped by domain (`auth`, `blogs`, `profiles`, `comments`)
- `lib/shared`: reusable theme and shared UI widgets

Each feature follows:
- `data/`: Supabase access and backend calls
- `state/`: Riverpod controllers + feature state models
- `presentation/`: screens and widgets

Detailed structure: [project_architecture](project_architecture)

## State Management Pattern
- Controllers live in `features/*/state`
- Services live in `features/*/data`
- UI reads/watches controller providers
- Mutations are handled in controllers, with loading/error state tracked per feature and, where needed, per-item (maps keyed by entity id)

### Comments State Shape (high level)
`CommentsState` stores comments in maps for efficient rendering:
- `articleComments[articleId] -> List<CommentModel>`
- `imageComments[imageId] -> List<CommentModel>`

It also tracks operation-specific loading/error states for:
- content fetch
- insert
- update per comment id
- delete per comment id

## Supabase Integration
### Environment
Create `.env` in project root:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Loaded at startup in `lib/main.dart` before `Supabase.initialize`.

### Storage Buckets Used
- `article_images`
- `comment_images`
- `profile_images`

### RPC Functions Referenced in Code
- Articles:
  - `get_articles`
  - `insert_article`
  - `update_article`
  - `delete_article`
- Comments:
  - `get_article_comments`
  - `get_images_comments`
  - `insert_comment_mobile`
  - `update_comment_mobile`
  - `delete_comment`
- Profiles:
  - `get_user_profile_mobile`
  - `get_user_profile_mobile_public`
  - `insert_profile_mobile`
  - `update_profile_mobile`

## Run Locally
```bash
flutter pub get
flutter run
```

## Test
```bash
flutter test
```

## Important Files
- App bootstrapping:
  - `lib/main.dart`
  - `lib/app.dart`
- Articles:
  - `lib/features/blogs/data/blogs_service.dart`
  - `lib/features/blogs/state/blogs_controller.dart`
- Comments:
  - `lib/features/comments/data/comments_service.dart`
  - `lib/features/comments/state/comments_controller.dart`
  - `lib/features/comments/state/comments_state.dart`
  - `lib/features/comments/state/comments_state_updater.dart`
- Profiles:
  - `lib/features/profiles/data/profiles_service.dart`
  - `lib/features/profiles/state/profiles_controller.dart`
- Auth:
  - `lib/features/auth/data/auth_service.dart`
  - `lib/features/auth/state/auth_controller.dart`