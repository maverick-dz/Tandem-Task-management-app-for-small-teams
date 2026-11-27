import uuid

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import session as db_session
from app.models.device_token import DeviceToken
from app.models.enums import NotificationKind
from app.models.notification import Notification
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.user import User
from app.services.membership_service import team_leaders
from app.services.push_sender import get_push_sender

# Generic text only. Never include the task title (screen 056): the app loads the
# real content after it opens. One text per language of the app (spec F9).
PUSH_TEXT: dict[str, dict[str, tuple[str, str]]] = {
    "assigned": {
        "en": ("New task for you", "A task was assigned to you."),
        "fr": ("Nouvelle tâche pour vous", "Une tâche vous a été assignée."),
        "ar": ("مهمة جديدة لك", "أُسندت إليك مهمة."),
    },
    "due_soon": {
        "en": ("Task due soon", "A task of yours is due soon."),
        "fr": ("Échéance proche", "Une de vos tâches arrive bientôt à échéance."),
        "ar": ("مهمة قريبة الموعد", "موعد إحدى مهامك قريب."),
    },
    "overdue": {
        "en": ("Task overdue", "A task in your team is overdue."),
        "fr": ("Tâche en retard", "Une tâche de votre équipe est en retard."),
        "ar": ("مهمة متأخرة", "تأخرت إحدى مهام فريقك."),
    },
}


def push_text(kind: str, language: str) -> tuple[str, str]:
    texts = PUSH_TEXT[kind]
    return texts.get(language, texts["en"])


async def create_alerts(
    session: AsyncSession, user_ids: list[uuid.UUID], kind: str, payload: dict
) -> None:
    """Adds rows to the Alerts list inside the caller's transaction (no push)."""
    for user_id in dict.fromkeys(user_ids):
        session.add(Notification(user_id=user_id, type=kind, payload=payload))


async def notify_task_assignees(task_id: uuid.UUID, kind: str) -> None:
    """Assignment and due-soon reminders: only the people the task belongs to."""
    await _notify(task_id, kind, include_leaders=False)


async def notify_overdue(task_id: uuid.UUID) -> None:
    """Spec F6: an overdue alert goes to the assignee and to the team's managers."""
    await _notify(task_id, NotificationKind.overdue.value, include_leaders=True)


async def _notify(task_id: uuid.UUID, kind: str, *, include_leaders: bool) -> None:
    async with db_session.SessionLocal() as session:
        task = await session.get(Task, task_id)
        if task is None or task.deleted_at is not None:
            return

        user_ids = list(
            await session.scalars(
                select(TaskAssignee.user_id).where(TaskAssignee.task_id == task_id)
            )
        )
        if include_leaders:
            user_ids += await team_leaders(session, task.team_id)
        user_ids = list(dict.fromkeys(user_ids))
        if not user_ids:
            return

        await create_alerts(session, user_ids, kind, {"task_id": str(task_id)})
        rows = (
            await session.execute(
                select(DeviceToken.token, User.language)
                .join(User, User.id == DeviceToken.user_id)
                .where(DeviceToken.user_id.in_(user_ids))
            )
        ).all()
        await session.commit()

    by_language: dict[str, list[str]] = {}
    for token, language in rows:
        by_language.setdefault(language, []).append(token)

    invalid: list[str] = []
    for language, tokens in by_language.items():
        title, body = push_text(kind, language)
        invalid += await send_push(
            tokens, title, body, data={"task_id": str(task_id), "kind": kind}
        )

    if invalid:
        async with db_session.SessionLocal() as session:
            await session.execute(delete(DeviceToken).where(DeviceToken.token.in_(invalid)))
            await session.commit()


async def send_push(tokens: list[str], title: str, body: str, data: dict) -> list[str]:
    """Sends through the configured sender; returns the tokens that no longer work."""
    if not tokens:
        return []
    result = await get_push_sender().send(tokens, title, body, {k: str(v) for k, v in data.items()})
    return list(result.invalid_tokens)
