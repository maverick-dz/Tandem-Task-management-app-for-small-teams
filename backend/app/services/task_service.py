from datetime import datetime, time, timedelta, timezone
from zoneinfo import ZoneInfo

from app.models.enums import ReminderOffset

APP_TZ = ZoneInfo("Africa/Algiers")
ON_DAY_HOUR = 8


def compute_reminder_at(
    deadline: datetime | None, offset: str | None
) -> datetime | None:
    if deadline is None or offset is None:
        return None
    if offset == ReminderOffset.on_day:
        local_day = deadline.astimezone(APP_TZ).date()
        return datetime.combine(local_day, time(ON_DAY_HOUR), tzinfo=APP_TZ)
    if offset == ReminderOffset.one_day_before:
        return deadline - timedelta(days=1)
    if offset == ReminderOffset.one_hour_before:
        return deadline - timedelta(hours=1)
    return None


def reset_reminders(task) -> None:
    """Call whenever the deadline or the reminder offset is set or changed."""
    reminder_at = compute_reminder_at(task.deadline, task.reminder_offset)
    # A reminder time already in the past would fire instantly, so skip it.
    if reminder_at and reminder_at <= datetime.now(timezone.utc):
        reminder_at = None
    task.reminder_at = reminder_at
    task.reminder_sent_at = None
    task.overdue_notified_at = None