"""Sending push messages through Firebase Cloud Messaging.

The rest of the backend only knows `PushSender`. Tests plug in a fake sender, and
without credentials the default sender does nothing, so the Alerts list keeps working.
"""

import asyncio
from dataclasses import dataclass
from typing import Protocol

from app.core.config import settings

FCM_BATCH = 500  # Firebase accepts at most 500 tokens per multicast call


@dataclass(frozen=True)
class PushResult:
    sent: int = 0
    invalid_tokens: tuple[str, ...] = ()


class PushSender(Protocol):
    async def send(
        self, tokens: list[str], title: str, body: str, data: dict[str, str]
    ) -> PushResult: ...


class NullPushSender:
    async def send(
        self, tokens: list[str], title: str, body: str, data: dict[str, str]
    ) -> PushResult:
        return PushResult()


class FcmPushSender:
    def __init__(self, credentials_path: str) -> None:
        self._credentials_path = credentials_path

    async def send(
        self, tokens: list[str], title: str, body: str, data: dict[str, str]
    ) -> PushResult:
        return await asyncio.to_thread(self._send_blocking, tokens, title, body, data)

    def _send_blocking(
        self, tokens: list[str], title: str, body: str, data: dict[str, str]
    ) -> PushResult:
        import firebase_admin  # imported late: optional dependency
        from firebase_admin import credentials, messaging

        try:
            firebase_admin.get_app()
        except ValueError:
            firebase_admin.initialize_app(credentials.Certificate(self._credentials_path))

        sent = 0
        invalid: list[str] = []
        for start in range(0, len(tokens), FCM_BATCH):
            batch = tokens[start : start + FCM_BATCH]
            message = messaging.MulticastMessage(
                tokens=batch,
                notification=messaging.Notification(title=title, body=body),
                data=data,
            )
            response = messaging.send_each_for_multicast(message)
            for token, item in zip(batch, response.responses, strict=True):
                if item.success:
                    sent += 1
                elif isinstance(
                    item.exception,
                    (messaging.UnregisteredError, messaging.SenderIdMismatchError),
                ):
                    invalid.append(token)  # the app was uninstalled: forget the token
        return PushResult(sent=sent, invalid_tokens=tuple(invalid))


_sender: PushSender | None = None


def get_push_sender() -> PushSender:
    global _sender
    if _sender is None:
        path = settings.firebase_credentials_path
        _sender = FcmPushSender(path) if path else NullPushSender()
    return _sender


def set_push_sender(sender: PushSender | None) -> None:
    """Swap the sender (tests). Passing None restores the default."""
    global _sender
    _sender = sender
