# Owner: R (auth). Minimal working version so M's endpoints can be tested; R extends it.
import uuid
from datetime import UTC, datetime, timedelta

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerificationError

from app.core.config import settings

_hasher = PasswordHasher()


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except VerificationError:
        return False


def create_access_token(user_id: uuid.UUID, minutes: int | None = None) -> str:
    now = datetime.now(UTC)
    expires = now + timedelta(
        minutes=minutes if minutes is not None else settings.access_token_minutes
    )
    payload = {"sub": str(user_id), "iat": now, "exp": expires}
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> uuid.UUID | None:
    """The user id inside a valid token, or None when it is invalid or expired."""
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        return uuid.UUID(payload["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        return None
