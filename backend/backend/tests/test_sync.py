import uuid

from sqlalchemy import func, select

from app.models.sync_operation import SyncOperation
from tests.factories import auth, make_task, make_team, make_user


def _op(task, status, base_version=None, client_id=None):
    return {
        "client_id": str(client_id or uuid.uuid4()),
        "type": "task.status",
        "task_id": str(task.id),
        "status": status,
    } | ({"base_version": base_version} if base_version else {})


async def _post(client, user, *ops):
    return await client.post("/api/v1/sync", json={"operations": list(ops)}, headers=auth(user))


async def test_queued_changes_are_applied_in_order(client, session):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar)

    response = await _post(client, omar, _op(task, "in_progress"), _op(task, "done"))

    results = response.json()["results"]
    assert [r["outcome"] for r in results] == ["applied", "applied"]
    assert results[-1]["task"]["status"] == "done" and results[-1]["task"]["version"] == 3


async def test_a_retried_operation_is_answered_again_not_applied_twice(client, session):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar)
    op = _op(task, "done")

    first = (await _post(client, omar, op)).json()["results"][0]
    again = (await _post(client, omar, op)).json()["results"][0]

    assert first["outcome"] == "applied" and again["outcome"] == "duplicate"
    assert again["task"]["version"] == first["task"]["version"] == 2
    assert await session.scalar(select(func.count()).select_from(SyncOperation)) == 1


async def test_a_change_made_by_someone_else_meanwhile_is_a_conflict(client, session):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar, version=3)
    result = (await _post(client, omar, _op(task, "done", base_version=2))).json()["results"][0]
    assert result["outcome"] == "conflict"
    assert result["error_code"] == "TASK_CONFLICT"
    assert result["task"]["version"] == 3 and result["task"]["status"] == "todo"


async def test_operations_the_person_may_not_do_are_rejected_not_fatal(client, session):
    omar = await make_user(session, "Omar")
    lina = await make_user(session, "Lina")
    team = await make_team(session, [(omar, "member"), (lina, "manager")])
    mine = await make_task(session, team, lina)  # not Omar's task
    ok = await make_task(session, team, omar)

    results = (await _post(client, omar, _op(mine, "done"), _op(ok, "done"))).json()["results"]

    assert results[0]["outcome"] == "rejected" and results[0]["error_code"] == "NOT_ASSIGNEE"
    assert results[1]["outcome"] == "applied"  # the batch carried on


async def test_someone_elses_client_id_is_not_replayed(client, session):
    omar = await make_user(session, "Omar")
    sara = await make_user(session, "Sara")
    team = await make_team(session, [(omar, "member"), (sara, "member")])
    task = await make_task(session, team, omar)
    op = _op(task, "done")
    await _post(client, omar, op)
    result = (await _post(client, sara, op)).json()["results"][0]
    assert result["outcome"] == "rejected" and result["error_code"] == "FORBIDDEN"


async def test_bad_payloads_are_rejected(client, session):
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(omar, "member")])
    task = await make_task(session, team, omar)
    bad_type = _op(task, "done") | {"type": "task.delete"}
    assert (await _post(client, omar, bad_type)).status_code == 422
    too_many = [_op(task, "done") for _ in range(101)]
    assert (await _post(client, omar, *too_many)).status_code == 422
    assert (await client.post("/api/v1/sync", json={"operations": []})).status_code == 401
