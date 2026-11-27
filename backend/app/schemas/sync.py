import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

from app.models.enums import TaskStatus
from app.schemas.task_status import TaskStatusOut

MAX_OPERATIONS = 100


class SyncOperationIn(BaseModel):
    client_id: uuid.UUID  # generated on the phone, so a retry is recognised
    type: Literal["task.status"]
    task_id: uuid.UUID
    status: TaskStatus
    base_version: int | None = Field(default=None, ge=1)
    queued_at: datetime | None = None


class SyncRequest(BaseModel):
    operations: list[SyncOperationIn] = Field(max_length=MAX_OPERATIONS)


class SyncResultOut(BaseModel):
    client_id: uuid.UUID
    outcome: Literal["applied", "duplicate", "conflict", "rejected"]
    task: TaskStatusOut | None = None
    error_code: str | None = None


class SyncResponse(BaseModel):
    results: list[SyncResultOut]
