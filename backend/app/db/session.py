from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.core.config import settings

engine = create_async_engine(
    settings.database_url,          # pooled (-pooler) host
    pool_pre_ping=True,             # recovers after Neon pauses an idle database
    connect_args={
        "ssl": "require",           # not ?sslmode=require in the URL
        "statement_cache_size": 0,  # needed behind PgBouncer
        "prepared_statement_cache_size": 0,
    },
)

SessionLocal = async_sessionmaker(engine, expire_on_commit=False)