# Owner: M. Kept apart from notifications.py (R's Alerts list) so the two never collide.
from fastapi import APIRouter, Response, status
from sqlalchemy import delete, select

from app.core.deps import CurrentUser, DbSession
from app.models.device_token import DeviceToken
from app.schemas.device_tokens import DeviceTokenDelete, DeviceTokenIn

router = APIRouter(prefix="/notifications/device-tokens", tags=["notifications"])


@router.put("", status_code=status.HTTP_204_NO_CONTENT)
async def register_token(body: DeviceTokenIn, user: CurrentUser, session: DbSession) -> Response:
    """Called by the app after sign-in and whenever Firebase rotates the token."""
    row = await session.scalar(select(DeviceToken).where(DeviceToken.token == body.token))
    if row is None:
        session.add(DeviceToken(user_id=user.id, token=body.token, platform=body.platform.value))
    else:  # the phone changed owner or the app was reinstalled
        row.user_id = user.id
        row.platform = body.platform.value
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def unregister_token(
    body: DeviceTokenDelete, user: CurrentUser, session: DbSession
) -> Response:
    """Called on sign out, so the next owner of the phone gets nothing meant for you."""
    await session.execute(
        delete(DeviceToken).where(DeviceToken.token == body.token, DeviceToken.user_id == user.id)
    )
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
