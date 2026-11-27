"""Background jobs: reminders and overdue alerts.

APScheduler runs inside the API process. Set RUN_SCHEDULER=true on exactly one
instance. Each job claims its rows with a single `UPDATE ... RETURNING`, so even two
schedulers could not notify the same task twice.
"""

import logging
import uuid
from datetime import UTC, datetime

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import update

from app.core.config import settings
from app.db import session as db_session
from app.models.enums import NotificationKind, TaskStatus
from app.models.task import Task
from app.services.notification_service import notify_overdue, notify_task_assignees

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler(timezone=settings.app_timezone)


async def send_due_reminders(now: datetime | None = None) -> list[uuid.UUID]:
    """Reminders whose time has come (the offset chosen when the task was created)."""
    now = now or datetime.now(UTC)
    async with db_session.SessionLocal() as session:
        claimed = list(
            await session.scalars(
                update(Task)
                .where(
                    Task.reminder_at <= now,
                    Task.reminder_sent_at.is_(None),
                    Task.status != TaskStatus.done.value,
                    Task.deleted_at.is_(None),
                )
                .values(reminder_sent_at=now)
                .returning(Task.id)
            )
        )
        await session.commit()
    for task_id in claimed:
        try:
            await notify_task_assignees(task_id, NotificationKind.due_soon.value)
        except Exception:  # one failing push must not stop the others
            logger.exception("reminder failed for task %s", task_id)
    return claimed


async def send_overdue_alerts(now: datetime | None = None) -> list[uuid.UUID]:
    """Overdue alert to the assignee and the team's managers (spec F6), once per task."""
    now = now or datetime.now(UTC)
    async with db_session.SessionLocal() as session:
        claimed = list(
            await session.scalars(
                update(Task)
                .where(
                    Task.deadline < now,
                    Task.overdue_notified_at.is_(None),
                    Task.status != TaskStatus.done.value,
                    Task.deleted_at.is_(None),
                )
                .values(overdue_notified_at=now)
                .returning(Task.id)
            )
        )
        await session.commit()
    for task_id in claimed:
        try:
            await notify_overdue(task_id)
        except Exception:
            logger.exception("overdue alert failed for task %s", task_id)
    return claimed


async def send_weekly_summary() -> None:
    """After version 1 (spec 5.3: workload alerts and the weekly progress summary)."""


async def create_repeating_tasks() -> None:
    """After version 1 (spec 5.3: recurring tasks)."""


def register_jobs() -> None:
    scheduler.remove_all_jobs()  # idempotent: never two copies of a job
    scheduler.add_job(
        send_due_reminders, "interval", minutes=1, id="due_reminders", replace_existing=True
    )
    scheduler.add_job(
        send_overdue_alerts, "interval", minutes=5, id="overdue_alerts", replace_existing=True
    )
    scheduler.add_job(
        send_weekly_summary,
        "cron",
        day_of_week="sun",
        hour=8,
        id="weekly_summary",
        replace_existing=True,
    )
    scheduler.add_job(
        create_repeating_tasks,
        "cron",
        hour=0,
        minute=5,
        id="repeating_tasks",
        replace_existing=True,
    )
