from datetime import datetime, timezone
from zoneinfo import ZoneInfo

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import update

from app.db.session import SessionLocal
from app.models.task import Task
from app.services.notification_service import notify_task_assignees

scheduler = AsyncIOScheduler(timezone=ZoneInfo("Africa/Algiers"))


async def send_due_reminders() -> None:
    now = datetime.now(timezone.utc)
    async with SessionLocal() as session:
        # Claim and mark in one statement, so a reminder is never sent twice.
        result = await session.execute(
            update(Task)
            .where(
                Task.reminder_at <= now,
                Task.reminder_sent_at.is_(None),
                Task.status != "done",
                Task.deleted_at.is_(None),
            )
            .values(reminder_sent_at=now)
            .returning(Task.id)
        )
        task_ids = result.scalars().all()
        await session.commit()

    for task_id in task_ids:
        await notify_task_assignees(task_id, kind="due_soon")


async def send_overdue_alerts() -> None:
    now = datetime.now(timezone.utc)
    async with SessionLocal() as session:
        result = await session.execute(
            update(Task)
            .where(
                Task.deadline < now,
                Task.overdue_notified_at.is_(None),
                Task.status != "done",
                Task.deleted_at.is_(None),
            )
            .values(overdue_notified_at=now)
            .returning(Task.id)
        )
        task_ids = result.scalars().all()
        await session.commit()

    for task_id in task_ids:
        await notify_task_assignees(task_id, kind="overdue")


async def send_weekly_summary() -> None:
    ...  # per team: count done/open/overdue, then notify members (screen 038)


async def create_repeating_tasks() -> None:
    ...  # for each recurrence due today, insert a new copy and call reset_reminders


def register_jobs() -> None:
    scheduler.add_job(send_due_reminders, "interval", minutes=1,
                      id="reminders", max_instances=1, coalesce=True)
    scheduler.add_job(send_overdue_alerts, "interval", minutes=15,
                      id="overdue", max_instances=1, coalesce=True)
    scheduler.add_job(send_weekly_summary, "cron", day_of_week="mon", hour=8,
                      id="weekly_summary", max_instances=1, coalesce=True)
    scheduler.add_job(create_repeating_tasks, "cron", hour=0, minute=5,
                      id="repeating", max_instances=1, coalesce=True)