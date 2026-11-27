"""Importing this package registers every table with `Base.metadata` (Alembic needs that)."""

from app.models.consent import Consent
from app.models.device_token import DeviceToken
from app.models.feedback import Feedback
from app.models.notification import Notification
from app.models.sync_operation import SyncOperation
from app.models.task import Task
from app.models.task_assignee import TaskAssignee
from app.models.team import Team
from app.models.team_member import TeamMember
from app.models.user import User

__all__ = [
    "Consent",
    "DeviceToken",
    "Feedback",
    "Notification",
    "SyncOperation",
    "Task",
    "TaskAssignee",
    "Team",
    "TeamMember",
    "User",
]
