from sqlalchemy import select

from app.models.device_token import DeviceToken
from tests.factories import auth, make_user

TOKEN = "fcm-token-abcdef123456"


async def test_register_creates_then_updates_one_row(client, session):
    sara = await make_user(session)
    for platform in ("android", "ios"):
        response = await client.put(
            "/api/v1/notifications/device-tokens",
            json={"token": TOKEN, "platform": platform},
            headers=auth(sara),
        )
        assert response.status_code == 204
    rows = (await session.scalars(select(DeviceToken))).all()
    assert len(rows) == 1 and rows[0].platform == "ios"


async def test_a_phone_that_changes_owner_follows_the_newest_sign_in(client, session):
    sara = await make_user(session, "Sara")
    omar = await make_user(session, "Omar")
    body = {"token": TOKEN, "platform": "android"}
    await client.put("/api/v1/notifications/device-tokens", json=body, headers=auth(sara))
    await client.put("/api/v1/notifications/device-tokens", json=body, headers=auth(omar))
    row = await session.scalar(select(DeviceToken))
    assert row.user_id == omar.id


async def test_sign_out_removes_only_your_own_token(client, session):
    sara = await make_user(session, "Sara")
    omar = await make_user(session, "Omar")
    await client.put(
        "/api/v1/notifications/device-tokens",
        json={"token": TOKEN, "platform": "android"},
        headers=auth(sara),
    )
    # someone else cannot unregister it
    await client.request(
        "DELETE", "/api/v1/notifications/device-tokens", json={"token": TOKEN}, headers=auth(omar)
    )
    assert await session.scalar(select(DeviceToken)) is not None
    mine = await client.request(
        "DELETE", "/api/v1/notifications/device-tokens", json={"token": TOKEN}, headers=auth(sara)
    )
    assert mine.status_code == 204
    assert await session.scalar(select(DeviceToken)) is None
    # deleting again is fine
    again = await client.request(
        "DELETE", "/api/v1/notifications/device-tokens", json={"token": TOKEN}, headers=auth(sara)
    )
    assert again.status_code == 204


async def test_invalid_platform_or_token_is_rejected(client, session):
    sara = await make_user(session)
    for body in ({"token": TOKEN, "platform": "web"}, {"token": "short", "platform": "ios"}):
        response = await client.put(
            "/api/v1/notifications/device-tokens", json=body, headers=auth(sara)
        )
        assert response.status_code == 422


async def test_registering_requires_sign_in(client):
    response = await client.put(
        "/api/v1/notifications/device-tokens", json={"token": TOKEN, "platform": "ios"}
    )
    assert response.status_code == 401
