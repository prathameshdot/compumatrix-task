# Timer — Task Management App

A Flutter task management app built on Firebase Authentication and
Firestore, with search/filtering, a day timeline, local due-date
reminders, and a strict black/white theme (light + dark).

## Features

- **Auth** — Email/password sign in and sign up via Firebase
  Authentication, with client-side validation on every field.
- **Task dashboard** — Real-time list of tasks (title, description,
  status, due date, optional start/end time) streamed live from
  Firestore, plus at-a-glance Pending/Completed/In Progress counts.
- **Task management** — Create, edit, delete (with a confirmation
  dialog, plus swipe-to-delete), and mark complete/incomplete.
- **Search & filter** — Search by title; filter by status
  (Pending/In Progress/Completed) and by due date (today / this week /
  overdue).
- **Plan your day** — Tasks given a start/end time show up as a
  timeline on the dashboard, each with a progress bar that darkens as
  its time window elapses.
- **Calendar** — A month-grid view of tasks grouped by due date.
- **Reminders** — A local notification fires at (or before, per the
  user's preference) each task's due date/time.
- **Profile & theming** — Edit display name, switch light/dark/system
  theme (persisted across restarts), configure reminder lead time.

## Setup instructions

### Current status of this repo
Android is already wired up to a real Firebase project (**`timer-4624c`**):
`android/app/google-services.json` is in place, `applicationId` in
`android/app/build.gradle.kts` matches it (`com.timer.task`), and
`lib/firebase_options.dart`'s `android` block has real keys pulled from
that file. **You only need to do steps 2–4 below if:**
- you want to add iOS/web/macOS/Windows support (only Android is
  registered so far), or
- you want to point the app at a *different* Firebase project.

Either way, you must still enable Email/Password auth and create a
Firestore database in the console (step 4) — those are per-project
toggles that don't come from `google-services.json`.

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Create/connect your Firebase project
1. Go to the [Firebase console](https://console.firebase.google.com/) →
   **Add project** (or open `timer-4624c`, already created).
2. Install the CLIs once, if you don't have them:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
3. From the repo root, run:
   ```bash
   flutterfire configure --project=timer-4624c
   ```
   Select whichever additional platforms you need (iOS, web, ...).
   This overwrites `lib/firebase_options.dart` with real keys for every
   platform you select, and registers each native app.

4. In the Firebase console, enable:
   - **Build → Authentication → Get started → Sign-in method →
     Email/Password**.
   - **Build → Firestore Database → Create database.**

### 3. Firestore security rules & indexes
Tasks live in a top-level `tasks` collection, each scoped to its owner
via a `userId` field; user profiles live at `users/{uid}`. Deploy
`firestore.rules` and `firestore.indexes.json` (already in this repo)
with:
```bash
firebase deploy --only firestore:rules,firestore:indexes --project timer-4624c
```
This step is required — the app talks straight to Firestore with no
backend server, so if the rules/indexes were never deployed, reads and
writes against `tasks`/`users` fail (permission-denied, or a missing-index
error surfaced as a `PlatformException`/`FirebaseException` when a
query needs a composite index that hasn't been created yet). Re-run
this command any time `firestore.rules` or `firestore.indexes.json`
change. The rules enforce exactly this:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /tasks/{taskId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 4. Run
```bash
flutter run
```
On first launch, grant the notification permission prompt — this
covers the local due-date reminders. On Android 12+, also grant the
"Alarms & reminders" special permission if prompted (`SCHEDULE_EXACT_ALARM`),
otherwise scheduled due-date reminders won't fire (this doesn't affect
marking a task complete, which shows an immediate, non-scheduled
notification).

### 5. Run tests
```bash
flutter test
```

### 6. Build a release APK
```bash
flutter build apk --release --split-per-abi
```

## Architecture

Flat, type-based `lib/` structure — no nested feature folders:

```
lib/
  main.dart              # Entry point: Firebase init (shows SplashScreen while
                          # loading), then hands off to the themed, auth-gated app
  theme.dart              # Colors, sizes, text styles, light/dark ThemeData
  strings.dart            # Every user-facing string, in one place
  icons.dart              # Every icon used in the app, in one place
  firebase_options.dart

  models/                 # Plain data classes: TaskModel, TaskStatus,
                          #   TaskFilters, UserModel
  services/               # Firebase-facing repositories + their Riverpod
                          #   providers, one file per domain:
                          #   auth_service, user_service, task_service,
                          #   notification_service, push_notification_service
  providers/              # Cross-cutting providers not tied to a service (theme)
  screens/                # One file per screen: splash, login, register,
                          #   dashboard, calendar, add/edit task, profile,
                          #   firebase_error_screen, main_shell (bottom nav)
  widgets/                # Reusable UI: buttons, text fields, dialogs, task
                          #   card, status badge, skeleton loaders, timeline
  utils/                  # Validators, date helpers, error wrapper
```

Each service file owns both its Firebase-facing repository class and
the Riverpod providers built on top of it (e.g. `AuthRepository` and
`authControllerProvider` both live in `services/auth_service.dart`),
so there's one file to open per concern instead of hunting across a
`data/`/`presentation/providers/` split.

## State management

**Riverpod** (`flutter_riverpod`). Each service exposes a repository
provider (talks to Firebase), a `StreamProvider` holding live state,
and derived `Provider`s for anything computed from that stream
(filtered tasks, stats, today's timeline). Loading/error/data states
use `AsyncValue` end-to-end via `.when(...)`, backed by skeleton
loaders instead of ad hoc spinners.

## Notes / trade-offs

- **Offline support**: Firestore's built-in disk cache means the task
  list keeps working (read-only) while offline; a dedicated Hive/SQLite
  cache was left out to keep scope focused on the required features.
- **Push notifications**: the FCM plumbing (token save, foreground/
  background handlers) is wired up, but there's no server/Cloud
  Function sending pushes — reminders are local-only by design (no
  ongoing hosting cost).
- **Images**: the UI is built from vector icons/text (see
  `widgets/app_logo.dart`) rather than shipped PNGs, aside from the app
  launcher icon (`assets/icon/timer.png`).

## Screenshots

_Add screenshots or a screen recording here before submitting._
