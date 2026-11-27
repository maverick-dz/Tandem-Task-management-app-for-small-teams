import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.enums import Role
from app.models.team_member import TeamMember


async def get_membership(
    session: AsyncSession, user_id: uuid.UUID, team_id: uuid.UUID
) -> TeamMember | None:
    return await session.scalar(
        select(TeamMember).where(TeamMember.user_id == user_id, TeamMember.team_id == team_id)
    )


async def team_leaders(session: AsyncSession, team_id: uuid.UUID) -> list[uuid.UUID]:
    """Admins and Managers of a team: the people told about overdue and finished tasks."""
    rows = await session.scalars(
        select(TeamMember.user_id).where(
            TeamMember.team_id == team_id,
            TeamMember.role.in_([Role.admin.value, Role.manager.value]),
        )
    )
    return list(rows)
