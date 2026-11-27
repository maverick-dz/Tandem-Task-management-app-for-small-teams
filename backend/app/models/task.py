# Owner: N (tasks). Agreed stub with the columns M's jobs and status endpoint need.
# `completed_at` is a small addition: the "done" stamp of the design shows when.
import uuid
from datetime import datetime

from sqlalchemy import ForeignKey, Integer, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.types import UTCDateTime
from app.models._common import utcnow, uuid_pk


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[uuid.UUID] = uuid_pk()
    team_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("teams.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(200))
    notes: Mapped[str | None] = mapped_column(Text, default=None)
    deadline: Mapped[datetime] = mapped_column(UTCDateTime)
    status: Mapped[str] = mapped_column(String(16), default="todo", index=True)
    reminder_offset: Mapped[str | None] = mapped_column(String(16), default=None)
    reminder_at: Mapped[datetime | None] = mapped_column(UTCDateTime, default=None, index=True)
    reminder_sent_at: Mapped[datetime | None] = mapped_column(UTCDateTime, default=None)
    overdue_notified_at: Mapped[datetime | None] = mapped_column(UTCDateTime, default=None)
    completed_at: Mapped[datetime | None] = mapped_column(UTCDateTime, default=None)
    version: Mapped[int] = mapped_column(Integer, default=1, server_default="1")
    created_by: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), default=None
    )
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, onupdate=utcnow)
    deleted_at: Mapped[datetime | None] = mapped_column(UTCDateTime, default=None)
