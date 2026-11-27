from sqlalchemy.ext.asyncio import AsyncSession

from app.models.enums import FeedbackKind
from app.models.feedback import Feedback
from app.models.user import User


async def create_feedback(
    session: AsyncSession, user: User, *, kind: FeedbackKind, message: str
) -> Feedback:
    entry = Feedback(user_id=user.id, kind=kind.value, message=message)
    session.add(entry)
    await session.commit()
    return entry
