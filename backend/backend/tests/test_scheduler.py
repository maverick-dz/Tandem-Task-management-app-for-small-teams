from datetime import timedelta

from sqlalchemy import func, select

from app.models.notification import Notification
from app.workers import scheduler as jobs
from tests.factories import add_token, make_task, make_team, make_user, now


async def _setup(session):
    omar = await make_user(session, "Omar")
    lina = await make_user(session, "Lina")
    team = await make_team(session, [(omar, "member"), (lina, "manager")])
    await add_token(session, omar, "tok-omar-1")
    return team, omar, lina


async def test_a_due_reminder_is_sent_once(session, push):
    team, omar, _lina = await _setup(session)
    task = await make_task(session, team, omar, reminder_at=now() - timedelta(minutes=1))

    assert await jobs.send_due_reminders() == [task.id]
    assert await jobs.send_due_reminders() == []  # claimed: never sent twice

    assert len(push.calls) == 1
    await session.refresh(task)
    assert task.reminder_sent_at is not None


async def test_reminders_skip_future_done_deleted_and_already_sent_tasks(session, push):
    team, omar, _lina = await _setup(session)
    past = now() - timedelta(minutes=5)
    await make_task(session, team, omar, reminder_at=now() + timedelta(hours=1))  # not yet
    await make_task(session, team, omar, status="done", reminder_at=past)
    await make_task(session, team, omar, reminder_at=past, deleted_at=now())
    await make_task(session, team, omar, reminder_at=past, reminder_sent_at=now())
    await make_task(session, team, omar)  # no reminder at all

    assert await jobs.send_due_reminders() == []
    assert push.calls == []


async def test_a_failing_push_does_not_stop_the_other_reminders(session, push):
    team, omar, _lina = await _setup(session)
    past = now() - timedelta(minutes=1)
    first = await make_task(session, team, omar, reminder_at=past)
    second = await make_task(session, team, omar, reminder_at=past)
    push.fail_next = True

    claimed = await jobs.send_due_reminders()

    assert set(claimed) == {first.id, second.id}
    assert len(push.calls) == 1  # one failed, one went out
    assert await session.scalar(select(func.count()).select_from(Notification)) == 2


async def test_an_overdue_task_alerts_the_assignee_and_the_manager_once(session, push):
    team, omar, lina = await _setup(session)
    task = await make_task(session, team, omar, deadline=now() - timedelta(hours=2))

    assert await jobs.send_overdue_alerts() == [task.id]
    assert await jobs.send_overdue_alerts() == []

    alerted = set(await session.scalars(select(Notification.user_id)))
    assert alerted == {omar.id, lina.id}
    await session.refresh(task)
    assert task.overdue_notified_at is not None


async def test_overdue_skips_done_deleted_and_future_tasks(session, push):
    team, omar, _lina = await _setup(session)
    await make_task(session, team, omar, status="done", deadline=now() - timedelta(days=1))
    await make_task(session, team, omar, deadline=now() - timedelta(days=1), deleted_at=now())
    await make_task(session, team, omar, deadline=now() + timedelta(days=1))
    assert await jobs.send_overdue_alerts() == []


async def test_a_given_clock_decides_what_is_due(session, push):
    team, omar, _lina = await _setup(session)
    task = await make_task(session, team, omar, reminder_at=now() + timedelta(hours=3))
    assert await jobs.send_due_reminders(now=now()) == []
    assert await jobs.send_due_reminders(now=now() + timedelta(hours=4)) == [task.id]


def test_the_four_jobs_are_registered_with_stable_ids():
    try:
        jobs.register_jobs()
        jobs.register_jobs()  # registering twice must not duplicate jobs
        ids = sorted(job.id for job in jobs.scheduler.get_jobs())
        assert ids == ["due_reminders", "overdue_alerts", "repeating_tasks", "weekly_summary"]
    finally:
        jobs.scheduler.remove_all_jobs()
