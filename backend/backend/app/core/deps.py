from collections.abc import AsyncIterator
from typing import Annotated

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import unauthenticated
from app.core.security import decode_access_token
from app.db import session as db_session
from app.models.user import User

_bearer = HTTPBearer(auto_error=False)


async def get_db() -> AsyncIterator[AsyncSession]:
    # Looked up at call time so that tests can swap the session factory.
    async with db_session.SessionLocal() as session:
        yield session


DbSession = Annotated[AsyncSession, Depends(get_db)]


async def get_current_user(
    session: DbSession,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> User:
    if credentials is None:
        raise unauthenticated()
    user_id = decode_access_token(credentials.credentials)
    if user_id is None:
        raise unauthenticated()
    user = await session.get(User, user_id)
    if user is None or user.deleted_at is not None:
        raise unauthenticated()
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
