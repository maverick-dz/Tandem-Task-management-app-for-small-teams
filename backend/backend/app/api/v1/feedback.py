from fastapi import APIRouter, status

from app.core.deps import CurrentUser, DbSession
from app.schemas.feedback import FeedbackCreate, FeedbackOut
from app.services import feedback_service

router = APIRouter(prefix="/feedback", tags=["feedback"])


@router.post("", response_model=FeedbackOut, status_code=status.HTTP_201_CREATED)
async def send_feedback(body: FeedbackCreate, user: CurrentUser, session: DbSession) -> FeedbackOut:
    """Feedback (screen 058)."""
    entry = await feedback_service.create_feedback(
        session, user, kind=body.kind, message=body.message
    )
    return FeedbackOut(id=entry.id, created_at=entry.created_at)
