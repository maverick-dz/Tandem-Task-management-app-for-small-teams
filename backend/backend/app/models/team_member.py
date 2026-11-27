# Owner: R (teams and roles). Agreed stub, created so that M's endpoints can run.
import uuid
from datetime import datetime

from sqlalchemy import ForeignKey, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.types import UTCDateTime
from app.models._common import utcnow, uuid_pk


class TeamMember(Base):
    __tablename__ = "team_members"
    __table_args__ = (UniqueConstraint("team_id", "user_id"),)

    id: Mapped[uuid.UUID] = uuid_pk()
    team_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("teams.id", ondelete="CASCADE"))
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"))
    role: Mapped[str] = mapped_column(String(16), default="member")
    joined_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow)
