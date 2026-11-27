from datetime import timedelta

from sqlalchemy import func, select

from app.models.device_token import DeviceToken
from app.models.notification import Notification
from app.services.notification_service import (
    PUSH_TEXT,
    notify_overdue,
    notify_task_assignees,
    push_text,
)
from tests.factories import add_token, make_task, make_team, make_user, now


async def test_push_text_is_generic_and_never_holds_the_task_title(session, push):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar, title="Secret budget sheet")
    await add_token(session, omar, "tok-omar-1")

    await notify_task_assignees(task.id, "due_soon")

    (call,) = push.calls
    assert call["tokens"] == ["tok-omar-1"]
    assert "Secret" not in call["title"] + call["body"] + str(call["data"])
    assert call["data"] == {"task_id": str(task.id), "kind": "due_soon"}


async def test_an_alert_row_is_created_for_the_alerts_screen(session, push):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar)
    await notify_task_assignees(task.id, "assigned")  # no device token at all
    alert = await session.scalar(select(Notification))
    assert alert.user_id == omar.id and alert.type == "assigned"
    assert alert.payload == {"task_id": str(task.id)}
    assert push.calls == []


async def test_each_person_gets_the_text_in_their_own_language(session, push):
    sara = await make_user(session, "Sara", language="ar")
    omar = await make_user(session, "Omar", language="fr")
    yacine = await make_user(session, "Yacine", language="xx")  # unknown: falls back to English
    team = await make_team(session, [(sara, "member"), (omar, "member"), (yacine, "member")])
    task = await make_task(session, team, sara)
    from app.models.task_assignee import TaskAssignee

    for person in (omar, yacine):
        session.add(TaskAssignee(task_id=task.id, user_id=person.id))
    await session.commit()
    for person in (sara, omar, yacine):
        await add_token(session, person, f"tok-{person.full_name}")

    await notify_task_assignees(task.id, "assigned")

    titles = {tuple(c["tokens"]): c["title"] for c in push.calls}
    assert titles[("tok-Sara",)] == PUSH_TEXT["assigned"]["ar"][0]
    assert titles[("tok-Omar",)] == PUSH_TEXT["assigned"]["fr"][0]
    assert titles[("tok-Yacine",)] == PUSH_TEXT["assigned"]["en"][0]


async def test_overdue_goes_to_the_assignee_and_the_leaders_only(session, push):
    omar = await make_user(session, "Omar")  # assignee
    yacine = await make_user(session, "Yacine")  # bystander member
    lina = await make_user(session, "Lina")  # manager
    sara = await make_user(session, "Sara")  # admin
    team = await make_team(
        session, [(omar, "member"), (yacine, "member"), (lina, "manager"), (sara, "admin")]
    )
    task = await make_task(session, team, omar, deadline=now() - timedelta(hours=1))

    await notify_overdue(task.id)

    alerted = set(await session.scalars(select(Notification.user_id)))
    assert alerted == {omar.id, lina.id, sara.id}


async def test_nobody_is_alerted_twice_when_the_assignee_is_also_a_leader(session, push):
    sara = await make_user(session, "Sara")
    team = await make_team(session, [(sara, "admin")])
    task = await make_task(session, team, sara, deadline=now() - timedelta(hours=1))
    await notify_overdue(task.id)
    assert await session.scalar(select(func.count()).select_from(Notification)) == 1


async def test_deleted_or_unknown_tasks_notify_nobody(session, push):
    import uuid

    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    gone = await make_task(session, team, omar, deleted_at=now())
    await add_token(session, omar)
    await notify_task_assignees(gone.id, "due_soon")
    await notify_task_assignees(uuid.uuid4(), "due_soon")
    assert push.calls == []
    assert await session.scalar(select(func.count()).select_from(Notification)) == 0


async def test_tokens_that_firebase_rejects_are_forgotten(session, push):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar)
    await add_token(session, omar, "tok-good")
    await add_token(session, omar, "tok-uninstalled")
    push.invalid = {"tok-uninstalled"}

    await notify_task_assignees(task.id, "assigned")

    left = set(await session.scalars(select(DeviceToken.token)))
    assert left == {"tok-good"}


def test_every_kind_has_a_text_in_every_language_without_placeholders():
    for kind, languages in PUSH_TEXT.items():
        assert set(languages) == {"en", "fr", "ar"}, kind
        for title, body in languages.values():
            assert title and body and "{" not in title + body


def test_unknown_language_falls_back_to_english():
    assert push_text("overdue", "zz") == PUSH_TEXT["overdue"]["en"]
