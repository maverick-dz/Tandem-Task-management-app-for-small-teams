from sqlalchemy import func, select

from app.models.consent import Consent
from app.models.device_token import DeviceToken
from app.models.team import Team
from app.models.user import User
from tests.factories import add_token, auth, make_task, make_team, make_user


async def test_profile_requires_a_valid_token(client):
    assert (await client.get("/api/v1/users/me")).status_code == 401
    bad = await client.get("/api/v1/users/me", headers={"Authorization": "Bearer nope"})
    assert bad.status_code == 401
    assert bad.json()["code"] == "UNAUTHENTICATED"


async def test_read_profile(client, session):
    sara = await make_user(session, "Sara", "sara@example.com", language="fr")
    body = (await client.get("/api/v1/users/me", headers=auth(sara))).json()
    assert body["email"] == "sara@example.com"
    assert body["full_name"] == "Sara"
    assert body["language"] == "fr"
    assert body["consent"] is None


async def test_edit_name_and_email(client, session):
    sara = await make_user(session, "Sara", "sara@example.com")
    response = await client.patch(
        "/api/v1/users/me",
        json={"full_name": "  Sara Benali ", "email": "Sara.B@Example.com "},
        headers=auth(sara),
    )
    assert response.status_code == 200
    assert response.json()["full_name"] == "Sara Benali"
    assert response.json()["email"] == "sara.b@example.com"


async def test_blank_name_and_bad_email_are_validation_errors(client, session):
    sara = await make_user(session)
    for body in ({"full_name": "   "}, {"email": "not-an-email"}):
        response = await client.patch("/api/v1/users/me", json=body, headers=auth(sara))
        assert response.status_code == 422
        assert response.json()["code"] == "VALIDATION_ERROR"


async def test_email_already_used_is_a_conflict(client, session):
    sara = await make_user(session, "Sara", "sara@example.com")
    await make_user(session, "Lina", "lina@example.com")
    response = await client.patch(
        "/api/v1/users/me", json={"email": "lina@example.com"}, headers=auth(sara)
    )
    assert response.status_code == 409
    assert response.json()["code"] == "EMAIL_TAKEN"
    same = await client.patch(
        "/api/v1/users/me", json={"email": "sara@example.com"}, headers=auth(sara)
    )
    assert same.status_code == 200


async def test_language_is_saved_and_checked(client, session):
    sara = await make_user(session)
    ok = await client.put("/api/v1/users/me/language", json={"language": "ar"}, headers=auth(sara))
    assert ok.status_code == 200 and ok.json()["language"] == "ar"
    bad = await client.put("/api/v1/users/me/language", json={"language": "de"}, headers=auth(sara))
    assert bad.status_code == 422


async def test_consent_is_recorded_once_per_policy_version(client, session):
    sara = await make_user(session)
    first = await client.post(
        "/api/v1/users/me/consent", json={"policy_version": "2026-11"}, headers=auth(sara)
    )
    second = await client.post(
        "/api/v1/users/me/consent", json={"policy_version": "2026-11"}, headers=auth(sara)
    )
    assert first.status_code == second.status_code == 201
    assert first.json()["accepted_at"] == second.json()["accepted_at"]
    count = await session.scalar(select(func.count()).select_from(Consent))
    assert count == 1
    me = (await client.get("/api/v1/users/me", headers=auth(sara))).json()
    assert me["consent"]["policy_version"] == "2026-11"


async def test_policy_version_is_public(client):
    response = await client.get("/api/v1/users/policy-version")
    assert response.status_code == 200
    assert response.json() == {"policy_version": "2026-11"}


async def test_sole_member_can_delete_the_account_and_the_team_goes_too(client, session):
    sara = await make_user(session, "Sara", "sara@example.com")
    team = await make_team(session, [(sara, "admin")])
    await make_task(session, team, sara)
    await add_token(session, sara)
    headers = auth(sara)

    assert (await client.delete("/api/v1/users/me", headers=headers)).status_code == 204

    # the person is anonymous, their data is gone and the token no longer works
    await session.refresh(sara)
    assert sara.deleted_at is not None
    assert sara.email.endswith("@deleted.invalid")
    assert sara.full_name == "Deleted user"
    assert await session.scalar(select(func.count()).select_from(DeviceToken)) == 0
    assert await session.scalar(select(func.count()).select_from(Team)) == 0
    assert (await client.get("/api/v1/users/me", headers=headers)).status_code == 401


async def test_the_last_admin_cannot_leave_a_team_that_has_other_members(client, session):
    sara = await make_user(session, "Sara")
    omar = await make_user(session, "Omar")
    team = await make_team(session, [(sara, "admin"), (omar, "member")])

    blocked = await client.delete("/api/v1/users/me", headers=auth(sara))
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "LAST_ADMIN"
    assert blocked.json()["detail"]["team_ids"] == [str(team.id)]
    assert (await session.get(User, sara.id)).deleted_at is None

    # once someone else is Admin the account can be deleted
    from app.models.team_member import TeamMember

    membership = await session.scalar(select(TeamMember).where(TeamMember.user_id == omar.id))
    membership.role = "admin"
    await session.commit()
    assert (await client.delete("/api/v1/users/me", headers=auth(sara))).status_code == 204


async def test_a_deleted_email_can_be_used_again(client, session):
    sara = await make_user(session, "Sara", "sara@example.com")
    await client.delete("/api/v1/users/me", headers=auth(sara))
    again = await make_user(session, "Sara", "sara@example.com")
    assert again.id != sara.id
