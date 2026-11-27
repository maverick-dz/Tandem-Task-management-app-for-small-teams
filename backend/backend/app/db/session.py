from collections.abc import AsyncIterator

from sqlalchemy import event
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import StaticPool

from app.core.config import settings


def build_engine(url: str) -> AsyncEngine:
    """Neon (PostgreSQL) in production, SQLite in the tests."""
    if url.startswith("sqlite"):
        engine = create_async_engine(
            url, poolclass=StaticPool, connect_args={"check_same_thread": False}
        )

        @event.listens_for(engine.sync_engine, "connect")
        def _enable_foreign_keys(dbapi_connection, _record):
            cursor = dbapi_connection.cursor()
            cursor.execute("PRAGMA foreign_keys=ON")
            cursor.close()

        return engine

    return create_async_engine(
        url,  # pooled (-pooler) host
        pool_pre_ping=True,  # recovers after Neon pauses an idle database
        connect_args={
            "ssl": "require",  # not ?sslmode=require in the URL
            "statement_cache_size": 0,  # needed behind PgBouncer
            "prepared_statement_cache_size": 0,
        },
    )


engine = build_engine(settings.database_url)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    async with SessionLocal() as session:
        yield session
