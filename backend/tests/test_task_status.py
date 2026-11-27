from datetime import UTC, datetime, timedelta

from sqlalchemy import select

from app.models.notification import Notification
from tests.factories import auth, make_task, make_team, make_user, now


async def _team(session):
    lina = await make_user(session, "Lina")  # manager
    omar = await make_user(session, "Omar")  # member
    sara = await make_user(session, "Sara")  # admin
    team = await make_team(session, [(lina, "manager"), (omar, "member"), (sara, "admin")])
    return team, lina, omar, sara


def _status(client, task, user, status, version=None):
    body = {"status": status} | ({"version": version} if version else {})
    return client.patch(f"/api/v1/tasks/{task.id}/status", json=body, headers=auth(user))


async def test_the_assignee_changes_the_status_in_one_call(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar)
    response = await _status(client, task, omar, "in_progress")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "in_progress" and body["version"] == 2
    assert body["completed_at"] is None


async def test_done_is_stamped_with_the_time_and_reopening_clears_it(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar)
    done = (await _status(client, task, omar, "done")).json()
    assert done["completed_at"] is not None
    reopened = (await _status(client, task, omar, "todo")).json()
    assert reopened["completed_at"] is None and reopened["version"] == 3


async def test_only_the_assignee_may_change_the_status(client, session):
    team, lina, omar, sara = await _team(session)
    task = await make_task(session, team, omar)
    for other in (lina, sara):  # even a Manager or an Admin
        response = await _status(client, task, other, "done")
        assert response.status_code == 403
        assert response.json()["code"] == "NOT_ASSIGNEE"
    await session.refresh(task)
    assert task.status == "todo"


async def test_people_outside_the_team_cannot_even_see_the_task(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar)
    stranger = await make_user(session, "Yacine")
    response = await _status(client, task, stranger, "done")
    assert response.status_code == 404
    assert response.json()["code"] == "TASK_NOT_FOUND"


async def test_missing_and_deleted_tasks_are_not_found(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar, deleted_at=now())
    assert (await _status(client, task, omar, "done")).status_code == 404


async def test_unknown_status_and_missing_token_are_rejected(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar)
    assert (await _status(client, task, omar, "archived")).status_code == 422
    assert (
        await client.patch(f"/api/v1/tasks/{task.id}/status", json={"status": "done"})
    ).status_code == 401


async def test_a_stale_version_is_a_conflict_that_carries_the_current_copy(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar)
    await _status(client, task, omar, "in_progress")  # version is now 2
    response = await _status(client, task, omar, "done", version=1)
    assert response.status_code == 409
    assert response.json()["code"] == "TASK_CONFLICT"
    assert response.json()["detail"]["current"]["status"] == "in_progress"
    assert (await _status(client, task, omar, "done", version=2)).status_code == 200


async def test_setting_the_same_status_changes_nothing(client, session):
    team, _lina, omar, _sara = await _team(session)
    task = await make_task(session, team, omar, status="in_progress")
    response = await _status(client, task, omar, "in_progress")
    assert response.status_code == 200 and response.json()["version"] == 1


async def test_finishing_a_task_tells_the_leaders_but_not_the_person_who_did_it(client, session):
    team, lina, _omar, sara = await _team(session)
    task = await make_task(session, team, sara)  # the Admin finishes her own task
    await _status(client, task, sara, "done")
    alerts = (await session.scalars(select(Notification))).all()
    assert {a.user_id for a in alerts} == {lina.id}
    assert alerts[0].type == "task_done" and "title" not in alerts[0].payload


async def test_overdue_and_due_tomorrow_are_flagged_with_a_label_flag(client, session):
    team, _lina, omar, _sara = await _team(session)
    late = await make_task(session, team, omar, deadline=now() - timedelta(days=2))
    soon = await make_task(session, team, omar, deadline=now() + timedelta(days=1))
    far = await make_task(session, team, omar, deadline=now() + timedelta(days=9))
    body = (await client.get(f"/api/v1/teams/{team.id}/board", headers=auth(omar))).json()
    cards = {c["id"]: c for c in body["todo"]}
    assert cards[str(late.id)]["is_overdue"] and not cards[str(late.id)]["due_tomorrow"]
    assert cards[str(soon.id)]["due_tomorrow"] and not cards[str(soon.id)]["is_overdue"]
    assert not cards[str(far.id)]["is_overdue"] and not cards[str(far.id)]["due_tomorrow"]


async def test_a_done_task_is_never_overdue(client, session):
    team, _lina, omar, _sara = await _team(session)
    await make_task(
        session, team, omar, status="done", deadline=now() - timedelta(days=5), completed_at=now()
    )
    body = (await client.get(f"/api/v1/teams/{team.id}/board", headers=auth(omar))).json()
    assert body["done"][0]["is_overdue"] is False


async def test_the_board_groups_tasks_in_three_columns_with_progress(client, session):
    team, lina, omar, sara = await _team(session)
    base = datetime(2026, 11, 1, 12, tzinfo=UTC)
    await make_task(session, team, omar, title="B", deadline=base + timedelta(days=2))
    await make_task(session, team, omar, title="A", deadline=base + timedelta(days=1))
    await make_task(session, team, lina, title="C", status="in_progress", deadline=base)
    await make_task(session, team, sara, title="D", status="done", deadline=base, completed_at=base)
    await make_task(session, team, sara, title="gone", deadline=base, deleted_at=now())
    response = await client.get(f"/api/v1/teams/{team.id}/board", headers=auth(omar))
    assert response.status_code == 200
    body = response.json()
    assert [c["title"] for c in body["todo"]] == ["A", "B"]  # sorted by deadline
    assert [c["title"] for c in body["in_progress"]] == ["C"]
    assert [c["title"] for c in body["done"]] == ["D"]
    assert body["progress"] == {"done": 1, "total": 4}  # the deleted task is not counted
    assert body["todo"][0]["assignee"]["full_name"] == "Omar"


async def test_the_board_is_only_for_team_members(client, session):
    team, *_ = await _team(session)
    stranger = await make_user(session, "Yacine")
    response = await client.get(f"/api/v1/teams/{team.id}/board", headers=auth(stranger))
    assert response.status_code == 404
    assert (await client.get(f"/api/v1/teams/{team.id}/board")).status_code == 401


async def test_an_empty_team_has_an_empty_board(client, session):
    team, lina, *_ = await _team(session)
    body = (await client.get(f"/api/v1/teams/{team.id}/board", headers=auth(lina))).json()
    assert body["todo"] == body["in_progress"] == body["done"] == []
    assert body["progress"] == {"done": 0, "total": 0}
