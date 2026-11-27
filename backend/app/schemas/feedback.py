import uuid
from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from app.models.enums import FeedbackKind

MAX_MESSAGE_LENGTH = 2000


class FeedbackCreate(BaseModel):
    kind: FeedbackKind
    message: str = Field(max_length=MAX_MESSAGE_LENGTH)

    @field_validator("message")
    @classmethod
    def _not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("message must not be blank")
        return value


class FeedbackOut(BaseModel):
    id: uuid.UUID
    created_at: datetime
