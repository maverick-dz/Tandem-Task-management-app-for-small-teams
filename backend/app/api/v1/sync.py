from fastapi import APIRouter

from app.core.deps import CurrentUser, DbSession
from app.schemas.sync import SyncRequest, SyncResponse
from app.services import sync_service

router = APIRouter(prefix="/sync", tags=["sync"])


@router.post("", response_model=SyncResponse)
async def replay(body: SyncRequest, user: CurrentUser, session: DbSession) -> SyncResponse:
    """Replays queued changes in order. Safe to retry: operations carry a client id."""
    results = await sync_service.apply_operations(session, user, body.operations)
    return SyncResponse(results=results)
