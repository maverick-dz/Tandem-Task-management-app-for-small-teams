"""Replay of changes queued on the phone.

Version 1 reads from the last loaded data when offline and needs a connection to edit
(spec 5.1), so the app does not queue anything yet. The endpoint is ready for the
"offline editing" feature of 5.3, and it is safe to retry: every operation carries a
client-generated id.
"""

from datetime import UTC, datetime

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, ErrorCode
from app.models.sync_operation import SyncOperation
from app.models.user import User
from app.schemas.sync import SyncOperationIn, SyncResultOut
from app.schemas.task_status import TaskStatusOut
from app.services.task_status_service import change_status, status_view


async def apply_operations(
    session: AsyncSession, user: User, operations: list[SyncOperationIn]
) -> list[SyncResultOut]:
    results: list[SyncResultOut] = []
    for op in operations:
        previous = await session.get(SyncOperation, op.client_id)
        if previous is not None:
            if previous.user_id != user.id:
                results.append(
                    SyncResultOut(
                        client_id=op.client_id,
                        outcome="rejected",
                        error_code=ErrorCode.FORBIDDEN.value,
                    )
                )
            else:
                stored = {**previous.result, "outcome": "duplicate"}
                results.append(SyncResultOut.model_validate(stored))
            continue

        try:
            task, _ = await change_status(
                session,
                user=user,
                task_id=op.task_id,
                status=op.status,
                expected_version=op.base_version,
            )
            result = SyncResultOut(
                client_id=op.client_id,
                outcome="applied",
                task=status_view(task, datetime.now(UTC)),
            )
        except AppError as err:
            if err.code == ErrorCode.TASK_CONFLICT:
                result = SyncResultOut(
                    client_id=op.client_id,
                    outcome="conflict",
                    task=TaskStatusOut.model_validate(err.detail["current"]),
                    error_code=err.code.value,
                )
            else:
                result = SyncResultOut(
                    client_id=op.client_id, outcome="rejected", error_code=err.code.value
                )

        session.add(
            SyncOperation(
                client_id=op.client_id, user_id=user.id, result=result.model_dump(mode="json")
            )
        )
        await session.commit()
        results.append(result)
    return results
