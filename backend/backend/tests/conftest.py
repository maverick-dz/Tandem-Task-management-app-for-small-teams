import os

# Set before the app is imported: tests never touch Neon or a developer's .env.
os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///:memory:"
os.environ["DATABASE_URL_DIRECT"] = "sqlite+aiosqlite:///:memory:"
os.environ["JWT_SECRET"] = "test-secret-with-at-least-thirty-two-bytes"
os.environ["RUN_SCHEDULER"] = "false"
os.environ["FIREBASE_CREDENTIALS_PATH"] = ""

import httpx
import pytest
import pytest_asyncio

import app.models
from app.db import session as db_session
from app.db.base import Base
from app.main import app
from app.services.push_sender import PushResult, set_push_sender


class FakePushSender:
    """Records every push instead of calling Firebase."""

    def __init__(self) -> None:
        self.calls: list[dict] = []
        self.invalid: set[str] = set()
        self.fail_next = False

    async def send(self, tokens, title, body, data):
        if self.fail_next:
            self.fail_next = False
            raise RuntimeError("firebase unavailable")
        self.calls.append({"tokens": list(tokens), "title": title, "body": body, "data": data})
        return PushResult(
            sent=len(tokens), invalid_tokens=tuple(t for t in tokens if t in self.invalid)
        )


@pytest_asyncio.fixture(autouse=True)
async def database():
    async with db_session.engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    yield
    async with db_session.engine.begin() as connection:
        await connection.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture
async def session():
    async with db_session.SessionLocal() as s:
        yield s


@pytest_asyncio.fixture
async def client():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


@pytest.fixture
def push():
    sender = FakePushSender()
    set_push_sender(sender)
    yield sender
    set_push_sender(None)
