import uuid
from datetime import UTC, datetime

from sqlalchemy import JSON, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import mapped_column

JSONType = JSON().with_variant(JSONB(), "postgresql")


def utcnow() -> datetime:
    return datetime.now(UTC)


def uuid_pk():
    return mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
