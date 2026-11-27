import uuid
from datetime import UTC, datetime

from sqlalchemy import delete, func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, ErrorCode
from app.models.consent import Consent
from app.models.device_token import DeviceToken
from app.models.enums import Language, Role
from app.models.feedback import Feedback
from app.models.notification import Notification
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.team import Team
from app.models.team_member import TeamMember
from app.models.user import User


async def latest_consent(session: AsyncSession, user_id: uuid.UUID) -> Consent | None:
    return await session.scalar(
        select(Consent)
        .where(Consent.user_id == user_id)
        .order_by(Consent.accepted_at.desc())
        .limit(1)
    )


async def update_profile(
    session: AsyncSession, user: User, *, full_name: str | None, email: str | None
) -> User:
    if email is not None and email != user.email:
        taken = await session.scalar(select(User.id).where(User.email == email, User.id != user.id))
        if taken is not None:
            raise AppError(ErrorCode.EMAIL_TAKEN, 409, "This email is already used.")
        user.email = email
    if full_name is not None:
        user.full_name = full_name
    try:
        await session.commit()
    except IntegrityError as exc:  # two requests raced for the same email
        await session.rollback()
        raise AppError(ErrorCode.EMAIL_TAKEN, 409, "This email is already used.") from exc
    return user


async def set_language(session: AsyncSession, user: User, language: Language) -> User:
    user.language = language.value
    await session.commit()
    return user


async def record_consent(session: AsyncSession, user: User, policy_version: str) -> Consent:
    """Idempotent: consenting twice to the same policy version keeps the first record."""
    existing = await session.scalar(
        select(Consent).where(Consent.user_id == user.id, Consent.policy_version == policy_version)
    )
    if existing is not None:
        return existing
    consent = Consent(user_id=user.id, policy_version=policy_version)
    session.add(consent)
    await session.commit()
    return consent


async def delete_account(session: AsyncSession, user: User) -> None:
    """Erases the person's data (Law 18-07). A team never loses its last Admin.

    * Sole Admin of a team that has other members: refused with LAST_ADMIN. The person
      must make someone else an Admin first.
    * Sole member of a team: the team goes with them.
    * The user row is kept as an anonymous shell so that task history stays consistent.
    """
    blocking: list[str] = []
    empty_teams: list[uuid.UUID] = []
    admin_team_ids = list(
        await session.scalars(
            select(TeamMember.team_id).where(
                TeamMember.user_id == user.id, TeamMember.role == Role.admin.value
            )
        )
    )
    for team_id in admin_team_ids:
        others = await session.scalar(
            select(func.count())
            .select_from(TeamMember)
            .where(TeamMember.team_id == team_id, TeamMember.user_id != user.id)
        )
        other_admins = await session.scalar(
            select(func.count())
            .select_from(TeamMember)
            .where(
                TeamMember.team_id == team_id,
                TeamMember.user_id != user.id,
                TeamMember.role == Role.admin.value,
            )
        )
        if others and not other_admins:
            blocking.append(str(team_id))
        elif not others:
            empty_teams.append(team_id)
    if blocking:
        raise AppError(
            ErrorCode.LAST_ADMIN,
            409,
            "Make another member an Admin before you leave.",
            detail={"team_ids": blocking},
        )

    if empty_teams:
        await session.execute(delete(Team).where(Team.id.in_(empty_teams)))  # tasks cascade
    await session.execute(delete(TaskAssignee).where(TaskAssignee.user_id == user.id))
    await session.execute(delete(TeamMember).where(TeamMember.user_id == user.id))
    await session.execute(delete(DeviceToken).where(DeviceToken.user_id == user.id))
    await session.execute(delete(Notification).where(Notification.user_id == user.id))
    await session.execute(delete(Consent).where(Consent.user_id == user.id))
    await session.execute(delete(Feedback).where(Feedback.user_id == user.id))
    await session.execute(update(Task).where(Task.created_by == user.id).values(created_by=None))

    user.email = f"deleted-{user.id}@deleted.invalid"
    user.full_name = "Deleted user"
    user.password_hash = ""
    user.deleted_at = datetime.now(UTC)
    await session.commit()
