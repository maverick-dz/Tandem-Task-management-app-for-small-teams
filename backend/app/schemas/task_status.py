import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.enums import TaskStatus


class StatusUpdate(BaseModel):
    status: TaskStatus
    # The version the client last saw. A different server version means someone else
    # changed the task first: the answer is 409 TASK_CONFLICT with the current copy.
    version: int | None = Field(default=None, ge=1)


class TaskStatusOut(BaseModel):
    id: uuid.UUID
    status: TaskStatus
    version: int
    completed_at: datetime | None
    deadline: datetime
    is_overdue: bool
    due_tomorrow: bool
    updated_at: datetime


class MemberRef(BaseModel):
    id: uuid.UUID
    full_name: str


class BoardCard(BaseModel):
    id: uuid.UUID
    title: str
    status: TaskStatus
    deadline: datetime
    assignee: MemberRef | None
    is_overdue: bool
    due_tomorrow: bool
    version: int


class Progress(BaseModel):
    done: int
    total: int


class BoardOut(BaseModel):
    team_id: uuid.UUID
    todo: list[BoardCard]
    in_progress: list[BoardCard]
    done: list[BoardCard]
    progress: Progress
