import secrets
import uuid
from datetime import UTC, datetime, timedelta

from app.core.security import create_access_token
from app.models.device_token import DeviceToken
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.team import Team
from app.models.team_member import TeamMember
from app.models.user import User
from app.services.task_service import compute_reminder_at  # noqa: F401  (re-exported for tests)


def now() -> datetime:
    return datetime.now(UTC)


async def make_user(session, name="Sara", email=None, language="en") -> User:
    user = User(
        email=email or f"{name.lower()}-{uuid.uuid4().hex[:6]}@example.com",
        full_name=name,
        language=language,
        password_hash="x",
    )
    session.add(user)
    await session.commit()
    return user


async def make_team(session, members: list[tuple[User, str]], name="Studio 4 Capstone") -> Team:
    team = Team(name=name, invite_code=secrets.token_hex(4).upper())
    session.add(team)
    await session.flush()
    for user, role in members:
        session.add(TeamMember(team_id=team.id, user_id=user.id, role=role))
    await session.commit()
    return team


async def make_task(
    session, team, assignee, *, title="Draft survey questions", status="todo", deadline=None, **kw
) -> Task:
    task = Task(
        team_id=team.id,
        title=title,
        status=status,
        deadline=deadline or now() + timedelta(days=3),
        **kw,
    )
    session.add(task)
    await session.flush()
    if assignee is not None:
        session.add(TaskAssignee(task_id=task.id, user_id=assignee.id, status=status))
    await session.commit()
    return task


async def add_token(session, user, token=None, platform="android") -> str:
    token = token or f"token-{uuid.uuid4().hex}"
    session.add(DeviceToken(user_id=user.id, token=token, platform=platform))
    await session.commit()
    return token


def auth(user) -> dict[str, str]:
    return {"Authorization": f"Bearer {create_access_token(user.id)}"}
