from fastapi import APIRouter, Response, status

from app.core.config import settings
from app.core.deps import CurrentUser, DbSession
from app.models.consent import Consent
from app.models.user import User
from app.schemas.users import ConsentCreate, ConsentOut, LanguageUpdate, UserOut, UserUpdate
from app.services import user_service

router = APIRouter(prefix="/users", tags=["users"])


def _out(user: User, consent: Consent | None) -> UserOut:
    return UserOut(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        language=user.language,
        consent=(
            ConsentOut(policy_version=consent.policy_version, accepted_at=consent.accepted_at)
            if consent
            else None
        ),
    )


@router.get("/me", response_model=UserOut)
async def read_me(user: CurrentUser, session: DbSession) -> UserOut:
    return _out(user, await user_service.latest_consent(session, user.id))


@router.patch("/me", response_model=UserOut)
async def update_me(body: UserUpdate, user: CurrentUser, session: DbSession) -> UserOut:
    """Edit profile (screen 057)."""
    user = await user_service.update_profile(
        session, user, full_name=body.full_name, email=body.email
    )
    return _out(user, await user_service.latest_consent(session, user.id))


@router.put("/me/language", response_model=UserOut)
async def update_language(body: LanguageUpdate, user: CurrentUser, session: DbSession) -> UserOut:
    """Language (screen 053): also the language of push messages."""
    user = await user_service.set_language(session, user, body.language)
    return _out(user, await user_service.latest_consent(session, user.id))


@router.post("/me/consent", response_model=ConsentOut, status_code=status.HTTP_201_CREATED)
async def give_consent(body: ConsentCreate, user: CurrentUser, session: DbSession) -> ConsentOut:
    """Privacy consent (screen 054)."""
    consent = await user_service.record_consent(session, user, body.policy_version)
    return ConsentOut(policy_version=consent.policy_version, accepted_at=consent.accepted_at)


@router.get("/policy-version")
async def current_policy_version() -> dict[str, str]:
    """The version the app should ask people to accept."""
    return {"policy_version": settings.policy_version}


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_me(user: CurrentUser, session: DbSession) -> Response:
    await user_service.delete_account(session, user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
