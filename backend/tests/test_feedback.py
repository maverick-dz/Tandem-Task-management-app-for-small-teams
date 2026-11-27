from sqlalchemy import select

from app.models.feedback import Feedback
from tests.factories import auth, make_user


async def test_feedback_is_stored_with_its_author(client, session):
    sara = await make_user(session)
    response = await client.post(
        "/api/v1/feedback",
        json={"kind": "idea", "message": "  A calendar view would help.  "},
        headers=auth(sara),
    )
    assert response.status_code == 201
    row = await session.scalar(select(Feedback))
    assert row.user_id == sara.id
    assert row.kind == "idea"
    assert row.message == "A calendar view would help."  # trimmed


async def test_feedback_needs_a_message_and_a_known_kind(client, session):
    sara = await make_user(session)
    for body in (
        {"kind": "idea", "message": "   "},
        {"kind": "idea"},
        {"kind": "praise", "message": "hello"},
        {"kind": "problem", "message": "x" * 2001},
    ):
        response = await client.post("/api/v1/feedback", json=body, headers=auth(sara))
        assert response.status_code == 422, body
        assert response.json()["code"] == "VALIDATION_ERROR"


async def test_feedback_accepts_the_longest_allowed_message(client, session):
    sara = await make_user(session)
    response = await client.post(
        "/api/v1/feedback", json={"kind": "other", "message": "x" * 2000}, headers=auth(sara)
    )
    assert response.status_code == 201


async def test_feedback_requires_sign_in(client):
    response = await client.post("/api/v1/feedback", json={"kind": "idea", "message": "hi"})
    assert response.status_code == 401
