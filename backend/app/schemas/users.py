import re
import uuid
from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from app.models.enums import Language

_EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class ConsentOut(BaseModel):
    policy_version: str
    accepted_at: datetime


class UserOut(BaseModel):
    id: uuid.UUID
    email: str
    full_name: str
    language: Language
    consent: ConsentOut | None = None


class UserUpdate(BaseModel):
    """Edit profile (screen 057): the name and the email."""

    full_name: str | None = Field(default=None, max_length=120)
    email: str | None = Field(default=None, max_length=320)

    @field_validator("full_name")
    @classmethod
    def _name(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip()
        if not value:
            raise ValueError("name must not be blank")
        return value

    @field_validator("email")
    @classmethod
    def _email_format(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip().lower()
        if not _EMAIL.match(value):
            raise ValueError("invalid email address")
        return value


class LanguageUpdate(BaseModel):
    language: Language


class ConsentCreate(BaseModel):
    policy_version: str = Field(min_length=1, max_length=32)
