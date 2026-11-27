import uuid
from datetime import UTC, datetime

from fastapi import APIRouter

from app.core.deps import CurrentUser, DbSession
from app.schemas.task_status import BoardOut, StatusUpdate, TaskStatusOut
from app.services import task_status_service

router = APIRouter(tags=["tasks"])


@router.patch("/tasks/{task_id}/status", response_model=TaskStatusOut)
async def change_task_status(
    task_id: uuid.UUID, body: StatusUpdate, user: CurrentUser, session: DbSession
) -> TaskStatusOut:
    """One tap from the list or one move on the board (spec F4 and F10)."""
    task, _changed = await task_status_service.change_status(
        session, user=user, task_id=task_id, status=body.status, expected_version=body.version
    )
    return task_status_service.status_view(task, datetime.now(UTC))


@router.get("/teams/{team_id}/board", response_model=BoardOut)
async def read_board(team_id: uuid.UUID, user: CurrentUser, session: DbSession) -> BoardOut:
    """Board view (spec F10): three columns and the team progress."""
    return await task_status_service.board_for_team(session, user=user, team_id=team_id)
