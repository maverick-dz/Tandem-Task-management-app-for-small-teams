# Tandem

**Who does what, by when.** Tandem (Arabic: تنظيم) is a team task app where every task has one owner and one date, visible to the whole team.

- **Mobile app:** Flutter (English, French, Arabic with right-to-left layout)
- **Backend:** FastAPI
- **Database:** PostgreSQL
- **Hosting:** all user data is stored on a server in Algeria (see [Data location](#data-location))

This README explains how the repository is organised and why. Read it before adding a new file or folder.

---

## Repository layout

```
tandem/
├── mobile/              # Flutter app
├── backend/             # FastAPI service
├── docker-compose.yml   # postgres + api + redis + worker for local development
└── README.md
```

---

## About the design: 113 frames, about 64 real screens

The design PDF has 113 numbered frames, but they are not 113 pages of code:

- Frames **065 to 113** are the Arabic right-to-left versions of earlier frames. They are produced by localization (`l10n/app_ar.arb`) and Flutter's automatic layout mirroring, not by separate files.
- Many frames are **states of one screen**: offline, loading, empty, save failed, sign-in error, Member view. These live inside the same screen file.
- Dialogs and bottom sheets (delete task, sign out, change role, date picker) are **widgets**, not routes.

Frame numbers are referenced below as `(001)`, `(014)`, and so on, so you can match code to the design.

---

## Mobile (`mobile/`)

```
mobile/
├── lib/
│   ├── main.dart                 # runApp only
│   ├── app.dart                  # MaterialApp.router, theme, locale, RTL
│   ├── core/                     # shared, feature-independent code
│   ├── l10n/                     # translations
│   └── features/                 # one folder per product feature
├── test/                         # mirrors lib/; includes Arabic golden tests
├── assets/
└── pubspec.yaml
```

### `core/`

Code that works even if every feature is deleted. Nothing in `core/` may import from `features/`.

```
core/
├── theme/            # colors (green palette), typography, spacing, radii
├── router/           # app_router.dart, guards (signed in, has team, role)
├── network/          # dio client, auth interceptor, error-code mapping
│   └── generated/    # OpenAPI client, generated, never edited by hand
├── storage/          # secure token storage, local database
├── sync/             # offline queue (061) and conflict merge (041)
├── permissions/      # Role enum and can(Permission.x) checks (021, 057, 058)
├── entitlements/     # Free / Pro / Business feature gating (033)
├── notifications/    # push registration and local reminder scheduling (031, 056)
├── utils/            # date formatting, validators, extensions
└── widgets/          # shared design system (below)
```

### Shared design system (`core/widgets/`)

Any widget used on three or more screens belongs here.

| Widget | Used for |
|---|---|
| `app_button` | primary (green), secondary, text/link buttons |
| `app_text_field` | label, field and error text |
| `app_chip` | selectable pills (Create a team / Join with a code) |
| `segmented_filter` | Mine / Everyone, List / Board / Calendar |
| `avatar_initial` | colored circle with the member's initial |
| `date_stamp` | the dashed date box ("Fri 30", "Done Thu 14:20") |
| `progress_bar` | splash, team progress, per-person progress |
| `app_bottom_nav` | Home, Tasks, Progress, Team |
| `app_bottom_sheet`, `app_dialog` | confirmations and pickers |
| `info_banner` | offline notice, "only Sara can change this task" |
| `empty_state`, `loading_skeleton` | empty (010, 028) and loading (055) states |
| `app_scaffold` | common page frame |

### `l10n/`

```
l10n/
├── app_en.arb
├── app_fr.arb
└── app_ar.arb
```

Rules:

- Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end`, never `left`/`right`, so Arabic mirrors correctly.
- The backend returns **error codes** (`INVALID_CREDENTIALS`, `LAST_ADMIN`, `TASK_CONFLICT`). The app turns each code into text from the `.arb` files.

### `features/`

Each feature owns its screens, widgets, data and state. A feature must not import another feature's internals. If two features need the same thing, move it to `core/`.

```
features/
├── onboarding/      # splash (001), onboarding (002)
├── auth/            # sign up (003), sign in (004, 043), reset password (016),
│                    # check email (017), new password (042), sign-out dialog (044)
├── teams/           # team setup (005), join (018), joined (045), invite (019),
│                    # switcher (020), team and roles (013), team settings (046),
│                    # roles info (021), change role (014), remove member (051),
│                    # last-Admin guard (047)
├── dashboard/       # team dashboard (006, 052), project finished (039)
├── tasks/           # list (007, 010, 022, 029, 057), detail (009, 023, 058, 059),
│                    # form: create/edit/repeat/multi-assignee (008, 024, 036, 037,
│                    # 048, 060), board (027), calendar (034), timeline (035),
│                    # delete (025), done sheet (026), date picker (049), conflicts (041)
├── progress/        # progress (011), weekly summary (038),
│                    # workload report (063), export (062)
├── notifications/   # alerts (012, 028), allow reminders (031)
├── settings/        # profile and settings (015), edit profile (053),
│                    # language (030), feedback (032), privacy and consent (054)
├── billing/         # plans (033), organisation account (064)         [after v1]
└── integrations/    # calendar sync, chat apps, import (040)          [after v1]
```

Layout inside a feature:

```
features/tasks/
├── data/
│   ├── task_repository.dart      # wraps the generated API client + local DB
│   └── models/                   # task, checklist item, comment, attachment
└── presentation/
    ├── screens/                  # full pages, named *_screen.dart
    ├── widgets/                  # widgets used only by this feature
    └── state/                    # providers / blocs / controllers
```

Dependencies point one way: `presentation → data`. Screens never call the network directly.

---

## Backend (`backend/`)

```
backend/
├── app/
│   ├── main.py             # FastAPI app, routers, middleware
│   ├── core/
│   │   ├── config.py       # settings from environment variables
│   │   ├── security.py     # password hashing, JWT access and refresh tokens
│   │   ├── deps.py         # get_db, get_current_user, require_permission(...)
│   │   ├── errors.py       # error codes (not translated text)
│   │   └── permissions.py  # Role and Permission matrix, single source of truth
│   ├── db/                 # async SQLAlchemy engine and session
│   ├── models/             # SQLAlchemy tables
│   ├── schemas/            # Pydantic request and response models
│   ├── api/v1/             # thin routers
│   ├── services/           # business logic
│   └── workers/            # background jobs
├── alembic/                # database migrations
├── tests/
└── pyproject.toml
```

### Routers (`api/v1/`)

| File | Responsibility |
|---|---|
| `auth.py` | sign up, sign in, refresh token, reset password |
| `users.py` | profile, language, delete account |
| `teams.py` | create, join by code or link, invite, switch, settings |
| `members.py` | list members, change role, remove |
| `tasks.py` | create, edit, delete, status, checklist, comments |
| `attachments.py` | upload and download task files |
| `progress.py` | dashboard, progress, weekly summary, workload |
| `notifications.py` | alerts list, mark read, device tokens |
| `sync.py` | batch replay of the offline queue |
| `billing.py` | plans and organisation accounts (after v1) |
| `feedback.py` | feedback messages |

**Routers stay thin.** They validate input, call a service and return the result. Rules live in `services/`:

- `team_service.py`: the last-Admin guard (047)
- `task_service.py`: assignee rules, versioning, conflict detection
- `notification_service.py`: push notifications with generic text only
- `entitlement_service.py`: Free / Pro / Business gating

### Background workers (`workers/`)

Run through a task queue (ARQ or Celery with Redis):

- deadline reminders (on the day, 1 day before, 1 hour before)
- overdue alerts
- weekly summary
- creating copies of repeating tasks

---

## Database (PostgreSQL)

| Table | Purpose |
|---|---|
| `users` | email (unique), password hash, full name, language |
| `consents` | user, policy version, accepted at (003, 054) |
| `teams` | name, purpose, invite code (unique), optional organisation |
| `team_members` | team, user, role (`admin`, `manager`, `member`), unique per pair |
| `tasks` | team, title, notes, deadline, status, reminder offset, `version`, `deleted_at` |
| `task_assignees` | task, user, per-person status (several assignees, 037) |
| `task_dependencies` | task waits for another task (timeline, 035) |
| `task_recurrences` | frequency, weekdays, assignee, time (036) |
| `checklist_items` | task, text, done, position |
| `comments` | task, user, body |
| `attachments` | task, filename, storage key, size |
| `notifications` | user, type, payload, read at |
| `device_tokens` | user, push token, platform |
| `organisations`, `subscriptions` | plan (free, pro, business), period |
| `feedback` | user, kind, message |

Rules:

- All timestamps are `timestamptz`, stored in UTC. The app formats them per locale.
- Tasks are **soft deleted** (`deleted_at`) so offline clients can learn about the deletion.
- A team can never lose its last Admin (047). Enforce it in a transaction.
- A task must have at least one assignee (048).
- Every task edit carries the `version` the client last saw.

---

## How the pieces work together

### Roles and permissions

There are three roles: **Admin** (manages members and roles), **Manager** (creates and assigns tasks) and **Member** (updates the status of their own tasks).

- The server is the authority. Every endpoint uses `require_permission(...)`.
- The app only hides buttons, using `core/permissions`.
- Both permission tables must stay identical. Keep a test that compares them.

### Offline and conflicts (029, 041, 061)

1. The app reads tasks from the local database and writes changes to an offline queue (`core/sync`).
2. Each queued change has a client-generated UUID, so retries are idempotent.
3. The queue replays through `POST /sync` when the connection returns.
4. If the task's `version` on the server is newer, the API answers **409 Conflict** with the current copy. The app then shows the merge screen (041).

### Plans (033)

The server decides what each team may use. Pro features (calendar, timeline, workload report, export) return **403 `PLAN_REQUIRED`** on the Free plan. The app's `core/entitlements` reads the plan to show or lock screens.

### Push notifications (031, 056)

Sent through Firebase Cloud Messaging by a worker. Payloads carry **generic text only** ("New task for you"), never a task title. The app loads the real content after it opens.

### Invite links

`tandem.example/join/QX47MP` must open the app through Android App Links and iOS Universal Links, with a web fallback page. The backend serves `assetlinks.json` and `apple-app-site-association`.

### API client

FastAPI publishes `/openapi.json`. The Dart client in `mobile/lib/core/network/generated/` is generated from it. Never edit generated files; change the backend schema and regenerate.

---

## Data location

The privacy screen (054) promises that data is stored on a server in Algeria. Therefore:

- PostgreSQL, backups and attachment storage must all be hosted there.
- Use self-hosted S3-compatible storage (such as MinIO) for attachments.
- Firebase Cloud Messaging is the only external service that touches user devices, which is why push messages never contain task text.

---

## Getting started

> Adjust commands to your actual setup. These show the intended workflow.

**Backend**

```bash
docker compose up -d db redis
cd backend
pip install -e .
alembic upgrade head
uvicorn app.main:app --reload
```

The API docs open at `http://localhost:8000/docs`.

**Regenerate the Dart API client**

```bash
# with the backend running
cd mobile
# run your OpenAPI generator against http://localhost:8000/openapi.json
```

**Mobile**

```bash
cd mobile
flutter pub get
flutter run
```

---

## Conventions

- **Files:** `lowercase_with_underscores.dart`; screens end in `_screen.dart`, repositories in `_repository.dart`, models in `_model.dart`.
- **Classes:** `UpperCamelCase`. Prefix feature-specific widgets so names cannot clash (`OrderStatusChip`, not `StatusChip`).
- **One widget per file** when it is more than a few lines.
- **No text in code:** every visible string comes from the `.arb` files.
- **Tests:** mirror `lib/` under `test/`; add golden tests for shared widgets in English and Arabic.

---

## Build order

1. Backend skeleton, PostgreSQL, Alembic, auth endpoints, OpenAPI client generation
2. Flutter `core/` (theme, widgets, l10n, network) and the `auth` feature, end to end
3. `teams` and roles, including the last-Admin rule on both sides
4. `tasks`, `dashboard` and `progress`, with the `version` field and offline queue designed in from the start
5. Background workers and push notifications
6. `settings` and `notifications`
7. After v1: `billing`, `integrations`, calendar, timeline, export, workload report
