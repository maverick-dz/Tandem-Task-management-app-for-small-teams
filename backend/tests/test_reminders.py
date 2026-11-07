from datetime import datetime, timedelta, timezone
from types import SimpleNamespace

from app.models.enums import ReminderOffset
from app.services.task_service import compute_reminder_at, reset_reminders

DEADLINE = datetime(2030, 10, 30, 17, 0, tzinfo=timezone.utc)


def test_one_day_before():
    assert compute_reminder_at(DEADLINE, ReminderOffset.one_day_before) == DEADLINE - timedelta(days=1)


def test_one_hour_before():
    assert compute_reminder_at(DEADLINE, ReminderOffset.one_hour_before) == DEADLINE - timedelta(hours=1)


def test_no_offset_means_no_reminder():
    assert compute_reminder_at(DEADLINE, None) is None


def test_editing_deadline_clears_sent_flags():
    task = SimpleNamespace(
        deadline=DEADLINE,
        reminder_offset=ReminderOffset.one_day_before,
        reminder_at=None,
        reminder_sent_at=datetime.now(timezone.utc),
        overdue_notified_at=datetime.now(timezone.utc),
    )
    reset_reminders(task)
    assert task.reminder_sent_at is None
    assert task.overdue_notified_at is None
    assert task.reminder_at is not None