# Tandem

**Who does what, by when.** Tandem (Arabic: تنظيم) is a team task app where every task has one owner and one date, visible to the whole team.

This is an academic project built by a team of three.

- **Mobile app:** Flutter (English, French, Arabic with right-to-left layout)
- **Backend:** FastAPI (Python), managed with **uv**
- **Database:** PostgreSQL hosted on **Neon**
- **Background jobs:** **APScheduler**, running inside the FastAPI process (no Redis, no separate worker)
- **Containers:** none. Everything runs directly on each developer's machine.
- **Team:** **M** (team leader), **R** and **N** (see [Team and ownership](#team-and-ownership))

This README explains how the repository is organised, who owns what, and the rules we follow. Read it before adding a new file or folder.

---

## Contents

1. [Repository layout](#repository-layout)
2. [About the design](#about-the-design-113-frames-about-64-real-screens)
3. [Team and ownership](#team-and-ownership)
4. [Mobile structure](#mobile-mobile)
5. [Backend structure](#backend-backend)
6. [Database](#database-postgresql-on-neon)
7. [Background jobs](#background-jobs-apscheduler)
8. [How the pieces work together](#how-the-pieces-work-together)
9. [Hosting and data location](#hosting-and-data-location)
10. [Getting started](#getting-started)
11. [Conventions](#conventions)
12. [Team workflow](#team-workflow)
13. [Build order](#build-order)

---

## Repository layout

```
tandem/
├── mobile/              # Flutter app
├── backend/             # FastAPI service
├── .gitignore
└── README.md
```

There is no `docker-compose.yml` and no Redis. The database is a cloud service (Neon), configured through `backend/.env`.

---

## About the design: 113 frames, about 64 real screens

The design PDF has 113 numbered frames, but they are not 113 pages of code:

- Frames **065 to 113** are the Arabic right-to-left versions of earlier frames. They come from localization (`l10n/app_ar.arb`) and Flutter's automatic layout mirroring, not from separate files.
- Many frames are **states of one screen**: offline, loading, empty, save failed, sign-in error, Member view. These live inside the same screen file.
- Dialogs and bottom sheets (delete task, sign out, change role, date picker) are **widgets**, not routes.

Frame numbers are written below as `(001)`, `(014)` and so on, so code can be matched to the design.

---

## Team and ownership

| Person | Role | Effort share | Screens |
|---|---|---|---|
| **M** | Team leader | 23% | 14 |
| **R** | Developer | 35% | 18 |
| **N** | Developer | 42% | 16 |

Work is split by screen. To avoid merge conflicts, **every file has exactly one owner**, even when two people work in the same feature folder. Each owner builds their screens on both sides: the Flutter screen and the FastAPI endpoints behind it.

### Screens per person

**M (14):** Splash, Onboarding, Language, Privacy and consent, Allow reminders, Sign out, Offline, Loading, Empty state, Change status, Task completed, Edit profile, Send feedback, Board view (should have).

**R (18):** Sign up, Sign in, Sign in (error), Reset password, Check your email, Choose a new password, Team setup, Join a team, Joined a team, Invite members, Team switcher, Team and roles, Change a role, What each role can do, Team settings, Last Admin guard, Remove a member, Notifications (the Alerts list).

**N (16):** New task, New task (no assignee), Date picker, Save failed, Edit task, Delete a task, Task detail, My tasks, Progress view (one member), Progress, Team dashboard, Dashboard (new team), Tasks (Member view), Task detail (Member view), Profile and settings, Alerts (all caught up).

### Ownership map (`mobile/lib/`)

```
lib/
├── core/
│   ├── theme/, widgets/, l10n          [M]  design system; also empty_state (Empty state),
│   │                                        loading_skeleton (Loading), offline_banner (Offline)
│   ├── network/, sync/                 [M]  API client, offline queue
│   ├── router/, permissions/           [R]  route guards, Role and Permission checks
│   └── notifications/                  [M]  push registration
│
└── features/
    ├── onboarding/                     [M]  splash, onboarding
    │
    ├── auth/                           [R]  sign_up, sign_in (+ error state),
    │                                        reset_password, check_email, new_password
    │
    ├── teams/                          [R]  team_setup, join_team, joined_team,
    │                                        invite_members, team_switcher, team_and_roles,
    │                                        change_role_sheet, roles_info, team_settings,
    │                                        last_admin_guard_sheet, remove_member_dialog
    │
    ├── notifications/
    │   ├── alerts_screen.dart          [R]  alerts list
    │   ├── alerts_empty_view.dart      [N]  "all caught up", plugged into R's screen
    │   └── allow_reminders_screen.dart [M]
    │
    ├── dashboard/                      [N]  team_dashboard (+ new-team state)
    ├── progress/                       [N]  progress_screen
    │
    ├── tasks/
    │   ├── tasks_screen.dart           [N]  My tasks, Member view, one-member filter
    │   ├── task_detail_screen.dart     [N]  + Member view
    │   ├── task_form_screen.dart       [N]  new, no-assignee error, edit, save failed
    │   ├── date_picker_sheet.dart      [N]
    │   ├── delete_task_dialog.dart     [N]
    │   ├── change_status_sheet.dart    [M]
    │   ├── task_completed_sheet.dart   [M]
    │   └── board_screen.dart           [M]  (should have)
    │
    └── settings/
        ├── profile_settings_screen.dart [N]
        ├── edit_profile_screen.dart     [M]
        ├── language_screen.dart         [M]
        ├── privacy_consent_screen.dart  [M]
        ├── feedback_screen.dart         [M]
        └── sign_out_dialog.dart         [M]
```

### Backend ownership (`backend/app/`)

| Owner | Routers and services |
|---|---|
| **R** | `auth.py`, `teams.py`, `members.py`, alerts list in `notifications.py`, `permissions.py`, last-Admin rule in `team_service.py` |
| **N** | `tasks.py` (create, edit, delete, list, detail), `progress.py` (dashboard, progress, member filter), `task_service.py` (including the reminder-reset rule) |
| **M** | `users.py` (profile, language, consent, delete account), `feedback.py`, `task_status.py` (status change and board data), device tokens and push, `notification_service.py`, `workers/scheduler.py` (all background jobs), `sync.py`, Neon setup, Alembic baseline, CI |

The status endpoint is in its own file, `task_status.py`, so M's "Change status" and "Task completed" screens never require edits inside N's `tasks.py`.

### Cross-owner dependencies

These are the places where one person's screen needs another person's code. Agree on the signatures in the first two days and merge empty stubs so nobody waits.

| Who needs it | From | What to agree on |
|---|---|---|
| N (task detail) | M | `showChangeStatusSheet(context, task)` and `showTaskCompletedSheet(...)` |
| N (tasks screen) | M | `EmptyState`, `OfflineBanner`, `LoadingSkeleton` widgets |
| R (alerts screen) | N | `AlertsEmptyView()` widget |
| R (alerts screen) | M | `EmptyState`, `LoadingSkeleton` widgets |
| N (profile and settings) | M | route names for Edit profile, Language, Privacy, Feedback, Sign out dialog |
| M (board view) | N | task list endpoint and the `Task` model |
| M (sign out) | R | `AuthRepository.signOut()` |
| M (scheduler jobs) | N | the `tasks` reminder columns and the `reset_reminders(task)` helper in `task_service.py` |
| Everyone | R | `can(Permission.x)` to hide buttons (for example Member view in N's screens) |

Features talk to each other through **route names in `core/router`**, not direct imports. That keeps the rule "features don't import each other's internals" intact.

### Points to watch

- **M's screen count understates M's workload.** M also owns the repo setup, CI, theme, shared widgets, API client, offline queue, push, the scheduler and the Neon setup. If M falls behind, move one shared item (for example the form widgets) to N or R.
- **M's shared code blocks the others.** `core/theme`, `core/widgets` and `core/network` must be delivered in week one. R can start with auth, which needs few shared widgets.
- **Some frames are states of someone else's screen.** Offline, Loading and Empty state are states of N's tasks screen. "Alerts, all caught up" is the empty state of R's alerts list. The map above shows how to split them so each person edits only their own file.
- **Not assigned yet:** push notification frames (056) and everything marked "after v1" (calendar, timeline, plans, export, workload report, conflict merge, integrations, attachments). Decide owners before starting them.

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
├── l10n.yaml
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

Any widget used on three or more screens belongs here. Owner: **M**.

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
| `info_banner`, `offline_banner` | offline notice, "only Sara can change this task" |
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

- `pubspec.yaml` must contain `generate: true` under `flutter:`, and `l10n.yaml` must exist next to it. Run `flutter gen-l10n` after editing any `.arb` file.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end`, never `left`/`right`, so Arabic mirrors correctly.
- The backend returns **error codes** (`INVALID_CREDENTIALS`, `LAST_ADMIN`, `TASK_CONFLICT`). The app turns each code into text from the `.arb` files.
- Prefix every key with its feature (`auth_signInTitle`, `tasks_newTask`) and keep keys alphabetical, so three people editing the same `.arb` file rarely conflict.

### `features/`

Each feature owns its screens, widgets, data and state. A feature must not import another feature's internals. If two features need the same thing, move it to `core/`.

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

Frame numbers per feature:

| Feature | Frames |
|---|---|
| `onboarding` | splash (001), onboarding (002) |
| `auth` | sign up (003), sign in (004, 043), reset password (016), check email (017), new password (042) |
| `teams` | team setup (005), join (018), joined (045), invite (019), switcher (020), team and roles (013), settings (046), roles info (021), change role (014), remove member (051), last-Admin guard (047) |
| `dashboard` | team dashboard (006, 052), project finished (039, after v1) |
| `tasks` | list (007, 010, 022, 029, 057), detail (009, 023, 058, 059), form (008, 024, 036, 037, 048, 060), board (027), calendar (034), timeline (035), delete (025), completed (026), date picker (049), conflicts (041) |
| `progress` | progress (011), weekly summary (038), workload report (063), export (062) |
| `notifications` | alerts (012, 028), allow reminders (031) |
| `settings` | profile and settings (015), edit profile (053), language (030), feedback (032), privacy and consent (054), sign out (044) |
| `billing` | plans (033), organisation account (064), after v1 |
| `integrations` | integrations (040), after v1 |

---

## Backend (`backend/`)

```
backend/
├── app/
│   ├── main.py             # FastAPI app, routers, lifespan (starts the scheduler)
│   ├── core/
│   │   ├── config.py       # settings from environment variables (.env)
│   │   ├── security.py     # password hashing, JWT access and refresh tokens
│   │   ├── deps.py         # get_db, get_current_user, require_permission(...)
│   │   ├── errors.py       # error codes (not translated text)
│   │   └── permissions.py  # Role and Permission matrix, single source of truth
│   ├── db/                 # async SQLAlchemy engine and session (Neon)
│   ├── models/             # SQLAlchemy tables
│   ├── schemas/            # Pydantic request and response models
│   ├── api/v1/             # thin routers
│   ├── services/           # business logic
│   └── workers/
│       └── scheduler.py    # APScheduler setup and all background jobs
├── alembic/                # database migrations
├── tests/
├── .env.example            # template; copy to .env (never commit .env)
├── pyproject.toml
└── uv.lock                 # commit this so everyone has identical versions
```

### Routers (`api/v1/`)

| File | Responsibility | Owner |
|---|---|---|
| `auth.py` | sign up, sign in, refresh token, reset password | R |
| `users.py` | profile, language, consent, delete account | M |
| `teams.py` | create, join by code or link, invite, switch, settings | R |
| `members.py` | list members, change role, remove | R |
| `tasks.py` | create, edit, delete, list, detail, checklist, comments | N |
| `task_status.py` | status change, board data | M |
| `attachments.py` | upload and download task files (after v1) | unassigned |
| `progress.py` | dashboard, progress, weekly summary, workload | N |
| `notifications.py` | alerts list, mark read, device tokens | R (alerts), M (device tokens) |
| `sync.py` | batch replay of the offline queue | M |
| `billing.py` | plans and organisation accounts (after v1) | unassigned |
| `feedback.py` | feedback messages | M |

**Routers stay thin.** They validate input, call a service and return the result. Rules live in `services/`:

- `team_service.py`: the last-Admin guard (047)
- `task_service.py`: assignee rules, versioning, conflict detection, reminder reset
- `notification_service.py`: creates alert rows and sends push notifications with generic text only
- `entitlement_service.py`: Free / Pro / Business gating

---

## Database (PostgreSQL on Neon)

| Table | Purpose |
|---|---|
| `users` | email (unique), password hash, full name, language |
| `consents` | user, policy version, accepted at (003, 054) |
| `teams` | name, purpose, invite code (unique), optional organisation |
| `team_members` | team, user, role (`admin`, `manager`, `member`), unique per pair |
| `tasks` | team, title, notes, deadline, status, reminder offset, `reminder_at`, `reminder_sent_at`, `overdue_notified_at`, `version`, `deleted_at` |
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
- **Reminder columns:** `reminder_at` is the deadline minus the chosen offset ("1 day before", "1 hour before"), computed when the task is saved. `reminder_sent_at` and `overdue_notified_at` record what the scheduler already sent.
- **Reset rule (owner: N, in `task_service.py`):** whenever a task is created, or its deadline, reminder or assignees change, call `reset_reminders(task)`. It recomputes `reminder_at` and sets `reminder_sent_at` and `overdue_notified_at` back to `NULL`. Without this, an edited deadline never triggers a new reminder.

### Neon connection rules

Neon gives each database two hostnames. The one with `-pooler` in its name goes through PgBouncer.

| Use | URL | Variable |
|---|---|---|
| Running API | pooled (`-pooler` host) | `DATABASE_URL` |
| Alembic migrations | direct (no `-pooler`) | `DATABASE_URL_DIRECT` |

With the asyncpg driver:

- Do not put `?sslmode=require` in the URL. Pass `ssl="require"` in the engine's `connect_args`.
- Set `statement_cache_size=0` and `prepared_statement_cache_size=0` so prepared statements work behind PgBouncer.
- Use `pool_pre_ping=True`. Free Neon databases pause when idle, so the first request after a quiet period can be slow, and the pre-ping recovers the connection. Warm it up before a demo.

Example (`app/db/session.py`):

```python
engine = create_async_engine(
    settings.database_url,
    pool_pre_ping=True,
    connect_args={
        "ssl": "require",
        "statement_cache_size": 0,
        "prepared_statement_cache_size": 0,
    },
)
```

### One Neon branch per developer

Neon can create a branch of the database, which is a full copy with its own connection string. Create `main` for the shared demo plus one branch per developer (`dev-m`, `dev-r`, `dev-n`). Each person runs migrations and test data on their own branch without breaking the others. Merge migration files through Git, then apply them to `main` once.

---

## Background jobs (APScheduler)

Reminders, overdue alerts, the weekly summary and repeating tasks all run on a clock, so a scheduler fits better than a job queue. APScheduler runs inside the FastAPI process, which means no extra service to host and nothing else to start.

Install version 3 (version 4 has a different API):

```bash
uv add "apscheduler>=3.10,<4"
```

### Jobs (`app/workers/scheduler.py`, owner: M)

| Job | Schedule | What it does |
|---|---|---|
| `send_due_reminders` | every minute | finds tasks whose `reminder_at` has passed and `reminder_sent_at` is empty, marks them, notifies assignees |
| `send_overdue_alerts` | every 15 minutes | finds tasks past their deadline, not done, with `overdue_notified_at` empty, marks them, notifies |
| `send_weekly_summary` | Monday 08:00 | builds the weekly summary per team and notifies members |
| `create_repeating_tasks` | daily 00:05 | inserts the next copy of each repeating task |

### Design rules

- **State lives in PostgreSQL, not in memory.** Do not schedule one APScheduler job per task. A restart would lose them. The fixed jobs above query the database, so after a restart the next run simply catches up.
- **Claim and mark in one statement.** Use `UPDATE ... SET reminder_sent_at = now ... RETURNING id`, then notify the returned tasks. This stops the same reminder from being sent twice, even if two instances run the scheduler by mistake.
- **`max_instances=1` and `coalesce=True`** on every job, so a slow run never overlaps with the next one.
- **Jobs are plain async functions.** Test them by calling them directly in `pytest`, without starting the scheduler.
- **Push text stays generic.** `notification_service.notify_task_assignees(task_id, kind)` creates the row in `notifications` and sends "Task due tomorrow" style text, never the task title (056).

### Starting the scheduler (`app/main.py`)

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

from app.core.config import settings
from app.workers.scheduler import scheduler, register_jobs


@asynccontextmanager
async def lifespan(app: FastAPI):
    if settings.run_scheduler:
        register_jobs()
        scheduler.start()
    yield
    if settings.run_scheduler:
        scheduler.shutdown(wait=False)


app = FastAPI(lifespan=lifespan)
```

### Rules for running it

- Run the API with **one worker** (`uvicorn app.main:app --reload`, never `--workers 4`). Each worker process would start its own scheduler.
- Only one machine should have `RUN_SCHEDULER=true` against the shared database. For daily development, leave it `false` on your own branch unless you are testing reminders. Otherwise several laptops send the same reminders.

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

Design the `version` field and the queue before building many task screens. They are hard to add afterwards.

### Plans (033)

The server decides what each team may use. Pro features (calendar, timeline, workload report, export) return **403 `PLAN_REQUIRED`** on the Free plan. The app's `core/entitlements` reads the plan to show or lock screens.

### Push notifications (031, 056)

Sent through Firebase Cloud Messaging by `notification_service.py`, called from the scheduler jobs and from request handlers. Payloads carry **generic text only** ("New task for you"), never a task title. The app loads the real content after it opens.

### Invite links

`tandem.example/join/QX47MP` must open the app through Android App Links and iOS Universal Links, with a web fallback page. The backend serves `assetlinks.json` and `apple-app-site-association`. For the academic version, the invite **code** alone is enough, and links can be added later.

### API client

FastAPI publishes `/openapi.json`. The Dart client in `mobile/lib/core/network/generated/` is generated from it. Never edit generated files; change the backend schema and regenerate.

---

## Hosting and data location

| Part | Where it runs |
|---|---|
| PostgreSQL | Neon (managed) |
| FastAPI and scheduler | each developer's machine with `uvicorn`; optionally one free host such as Render for the demo |
| Push | Firebase Cloud Messaging |

The privacy screen (054) says data is stored on a server in Algeria. In this academic version the database runs on Neon, outside Algeria, so that sentence describes the production target, not the current setup. Either change the text in the design, or state this in the project report.

Notes for the demo:

- **Free hosts sleep when idle**, and a sleeping app runs no jobs. Keep the service awake with a periodic ping, or run the API on a laptop during the presentation.
- On a physical phone, `localhost` does not reach a developer's laptop. Use the deployed API URL or the laptop's LAN IP as the app's base URL.
- Set `RUN_SCHEDULER=true` only on the instance used for the demo.

---

## Getting started

Prerequisites: Git, Flutter, [uv](https://docs.astral.sh/uv/), and a Neon account (free plan).

### 1. Clone and configure secrets

```bash
git clone <repo-url> tandem
cd tandem/backend
cp .env.example .env
```

Fill in `backend/.env`:

```bash
# Neon: pooled URL for the app, direct URL for migrations
DATABASE_URL=postgresql+asyncpg://USER:PASSWORD@ep-xxxx-pooler.REGION.aws.neon.tech/DBNAME
DATABASE_URL_DIRECT=postgresql+asyncpg://USER:PASSWORD@ep-xxxx.REGION.aws.neon.tech/DBNAME

JWT_SECRET=change-me

# true only on the one instance that should send reminders
RUN_SCHEDULER=false
```

Never commit `.env`. Each developer uses their own Neon branch URLs.

### 2. Backend

```bash
cd backend
uv sync --extra dev                       # creates .venv and installs everything
uv run alembic upgrade head               # applies migrations (uses the direct URL)
uv run uvicorn app.main:app --reload
```

The API docs open at `http://localhost:8000/docs`.

Other commands:

```bash
uv run pytest
uv run ruff check .
uv add <package>                          # add a dependency
```

If your team uses conda instead of uv: `conda create -n tandem python=3.12`, `conda activate tandem`, then `pip install -e ".[dev]"`. Do not mix tools; pick one for the whole team.

### 3. Mobile

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run
```

If `flutter gen-l10n` complains about `generate`, add this to `pubspec.yaml`:

```yaml
flutter:
  generate: true
```

### 4. Regenerate the Dart API client

With the backend running, run your OpenAPI generator against `http://localhost:8000/openapi.json`, with output in `mobile/lib/core/network/generated/`.

### 5. Test the reminders

1. Create a task with a deadline a few minutes ahead.
2. In the database, set its `reminder_at` to a time in the past.
3. With `RUN_SCHEDULER=true`, within a minute `reminder_sent_at` fills in and a row appears in `notifications`.
4. Edit the task's deadline through the API and check that `reminder_sent_at` goes back to `NULL`.

---

## Conventions

- **Files:** `lowercase_with_underscores.dart`; screens end in `_screen.dart`, repositories in `_repository.dart`, models in `_model.dart`.
- **Classes:** `UpperCamelCase`. Prefix feature-specific widgets so names cannot clash (`TaskStatusChip`, not `StatusChip`).
- **One widget per file** when it is more than a few lines.
- **No text in code:** every visible string comes from the `.arb` files.
- **Tests:** mirror `lib/` under `test/`; add golden tests for shared widgets in English and Arabic.
- **Formatting:** run `dart format .` before every commit, and `uv run ruff format .` on the backend.
- **Secrets:** only `.env.example` is committed, never `.env`.

---

## Team workflow

1. **API contract first.** Write the endpoint and its Pydantic schema, merge it, and regenerate the Dart client. After that, mobile and backend work on the same screen can happen in parallel.
2. **One Alembic migration at a time.** Two people creating migrations at once produces two heads. Announce it in chat, merge it quickly, and the others rebase. CI runs `alembic heads` to catch mistakes.
3. **Own database branch.** Develop against your own Neon branch. Apply migrations to the shared `main` branch only after merging to Git.
4. **One scheduler.** Only one instance (usually the demo server) sets `RUN_SCHEDULER=true`, so reminders on shared data are not sent from several laptops.
5. **Short-lived branches.** One Git branch per screen or slice, merged within a day or two, named `feature/tasks-board` or `fix/sign-in-error`. `main` is protected and needs one review.
6. **Reviews:** M reviews R and N. R and N review each other's work that touches `core/`.
7. **Stub before you depend.** If your screen needs a widget or function from another owner (see the dependency table), merge an empty stub with the agreed signature first.
8. **Never edit generated code** in `core/network/generated/`.
9. **CI on every pull request:** `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, `ruff`, `pytest`, and the `alembic heads` check.
10. **Feature isolation:** use lint rules or an import check so a feature cannot import another feature's internals.

---

## Build order

1. **Together, one day:** create the repo, create the Neon project (with one branch per developer), set up CI, the empty folder structure, naming and branch rules, and the cross-owner stubs.
2. **Week one, in parallel:**
   - **M:** `core/theme`, `core/widgets`, `l10n`, `core/network` and the OpenAPI generation pipeline, Alembic baseline.
   - **R:** auth end to end, then `core/router` and `core/permissions`.
   - **N:** database models for tasks (including the reminder columns), then the tasks list and task form.
3. **Weeks two and three:** R builds teams and roles (including the last-Admin rule on both sides). N builds task detail, dashboard and progress. M builds offline sync, status sheets, onboarding and settings screens.
4. **Integration:** test the full flow of sign up, create a team, invite, create a task, change status, go offline and come back.
5. **Scheduler jobs and push notifications** (M, with N's `reset_reminders` helper in place).
6. **After v1:** `billing`, `integrations`, calendar, timeline, export, workload report, attachments, conflict merge.
