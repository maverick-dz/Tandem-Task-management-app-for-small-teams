import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError, ErrorCode, forbidden, not_found
from app.core.permissions import Permission, can
from app.models.enums import NotificationKind, TaskStatus
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.user import User
from app.schemas.task_status import BoardCard, BoardOut, MemberRef, Progress, TaskStatusOut
from app.services.membership_service import get_membership, team_leaders
from app.services.notification_service import create_alerts
from app.services.task_service import APP_TZ


def is_overdue(task: Task, now: datetime) -> bool:
    """A task past its deadline and not Done is Overdue (spec F4)."""
    return task.status != TaskStatus.done.value and task.deadline < now


def is_due_tomorrow(task: Task, now: datetime) -> bool:
    """Deadlines are never shown by colour alone: due-tomorrow carries a label."""
    if task.status == TaskStatus.done.value or is_overdue(task, now):
        return False
    today = now.astimezone(APP_TZ).date()
    return task.deadline.astimezone(APP_TZ).date() == today + timedelta(days=1)


def status_view(task: Task, now: datetime) -> TaskStatusOut:
    return TaskStatusOut(
        id=task.id,
        status=TaskStatus(task.status),
        version=task.version,
        completed_at=task.completed_at,
        deadline=task.deadline,
        is_overdue=is_overdue(task, now),
        due_tomorrow=is_due_tomorrow(task, now),
        updated_at=task.updated_at,
    )


async def change_status(
    session: AsyncSession,
    *,
    user: User,
    task_id: uuid.UUID,
    status: TaskStatus,
    expected_version: int | None = None,
    now: datetime | None = None,
) -> tuple[Task, bool]:
    """Spec F4: the assignee changes the status of their own task.

    Returns the task and whether anything changed. Setting the status a task already
    has is not an error and does not bump the version.
    """
    now = now or datetime.now(UTC)

    task = await session.get(Task, task_id)
    if task is None or task.deleted_at is not None:
        raise not_found(ErrorCode.TASK_NOT_FOUND, "Task not found.")

    # People outside the team must not learn that the task exists.
    membership = await get_membership(session, user.id, task.team_id)
    if membership is None:
        raise not_found(ErrorCode.TASK_NOT_FOUND, "Task not found.")
    if not can(membership.role, Permission.change_own_task_status):
        raise forbidden()

    assignee = await session.scalar(
        select(TaskAssignee).where(TaskAssignee.task_id == task.id, TaskAssignee.user_id == user.id)
    )
    if assignee is None:
        raise forbidden(ErrorCode.NOT_ASSIGNEE, "Only the assignee can change the status.")

    if expected_version is not None and expected_version != task.version:
        raise AppError(
            ErrorCode.TASK_CONFLICT,
            409,
            "The task changed since you loaded it.",
            detail={"current": status_view(task, now).model_dump(mode="json")},
        )

    if task.status == status.value:
        return task, False

    previous = task.status
    task.status = status.value
    task.completed_at = now if status == TaskStatus.done else None
    task.version += 1
    assignee.status = status.value

    if status == TaskStatus.done and previous != TaskStatus.done.value:
        leaders = [uid for uid in await team_leaders(session, task.team_id) if uid != user.id]
        await create_alerts(
            session, leaders, NotificationKind.task_done.value, {"task_id": str(task.id)}
        )

    await session.commit()
    return task, True


async def board_for_team(
    session: AsyncSession, *, user: User, team_id: uuid.UUID, now: datetime | None = None
) -> BoardOut:
    """Spec F10: the same tasks as three columns, with the team progress."""
    now = now or datetime.now(UTC)
    if await get_membership(session, user.id, team_id) is None:
        raise not_found(ErrorCode.NOT_FOUND, "Team not found.")

    rows = (
        await session.execute(
            select(Task, User.id, User.full_name)
            .outerjoin(TaskAssignee, TaskAssignee.task_id == Task.id)
            .outerjoin(User, User.id == TaskAssignee.user_id)
            .where(Task.team_id == team_id, Task.deleted_at.is_(None))
            .order_by(Task.deadline, Task.created_at)
        )
    ).all()

    columns: dict[str, list[BoardCard]] = {s.value: [] for s in TaskStatus}
    seen: set[uuid.UUID] = set()
    for task, assignee_id, assignee_name in rows:
        if task.id in seen:  # version 1 has one assignee; keep the first if there are more
            continue
        seen.add(task.id)
        columns[task.status].append(
            BoardCard(
                id=task.id,
                title=task.title,
                status=TaskStatus(task.status),
                deadline=task.deadline,
                assignee=MemberRef(id=assignee_id, full_name=assignee_name)
                if assignee_id
                else None,
                is_overdue=is_overdue(task, now),
                due_tomorrow=is_due_tomorrow(task, now),
                version=task.version,
            )
        )
    done = len(columns[TaskStatus.done.value])
    return BoardOut(
        team_id=team_id,
        todo=columns[TaskStatus.todo.value],
        in_progress=columns[TaskStatus.in_progress.value],
        done=columns[TaskStatus.done.value],
        progress=Progress(done=done, total=len(seen)),
    )
