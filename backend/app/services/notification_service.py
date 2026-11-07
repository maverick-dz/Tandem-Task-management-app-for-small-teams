from sqlalchemy import select

from app.db.session import SessionLocal
from app.models.notification import Notification
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.device_token import DeviceToken

# Generic text only. Never include the task title (screen 056).
PUSH_TEXT = {
    "assigned": ("New task for you", "A task was assigned to you."),
    "due_soon": ("Due tomorrow", "A task of yours is due soon."),
    "overdue": ("Task overdue", "A task in your team is overdue."),
}


async def notify_task_assignees(task_id, kind: str) -> None:
    title, body = PUSH_TEXT[kind]
    async with SessionLocal() as session:
        task = await session.get(Task, task_id)
        if task is None or task.deleted_at is not None:
            return

        user_ids = (
            await session.scalars(
                select(TaskAssignee.user_id).where(TaskAssignee.task_id == task_id)
            )
        ).all()

        for user_id in user_ids:
            session.add(
                Notification(
                    user_id=user_id,
                    type=kind,
                    payload={"task_id": str(task_id)},
                )
            )

        tokens = (
            await session.scalars(
                select(DeviceToken.token).where(DeviceToken.user_id.in_(user_ids))
            )
        ).all()
        await session.commit()

    await send_push(list(tokens), title, body, data={"task_id": str(task_id)})


async def send_push(tokens: list[str], title: str, body: str, data: dict) -> None:
    # TODO (after Firebase is set up): send through firebase_admin.messaging.
    # Until then this does nothing, and the in-app alerts list still works.
    return