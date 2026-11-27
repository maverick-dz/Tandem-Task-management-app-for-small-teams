import os
import sqlite3
import subprocess
import sys
from pathlib import Path

from alembic.autogenerate import compare_metadata
from alembic.migration import MigrationContext
from sqlalchemy import create_engine

import app.models  # noqa: F401
from app.db.base import Base

BACKEND = Path(__file__).resolve().parent.parent


def _alembic(db_file: Path, *args: str) -> str:
    env = {
        **os.environ,
        "DATABASE_URL_DIRECT": f"sqlite+aiosqlite:///{db_file}",
    }
    result = subprocess.run(
        [sys.executable, "-m", "alembic", *args],
        cwd=BACKEND,
        env=env,
        capture_output=True,
        text=True,
        check=False,  # the assertion below reports stderr, which is clearer
    )
    assert result.returncode == 0, result.stderr
    return result.stdout + result.stderr


def test_there_is_a_single_migration_head(tmp_path):
    output = _alembic(tmp_path / "db.sqlite", "heads")
    assert output.count("(head)") == 1


def test_migrations_build_exactly_the_schema_of_the_models(tmp_path):
    db = tmp_path / "db.sqlite"
    _alembic(db, "upgrade", "head")

    engine = create_engine(f"sqlite:///{db}")
    with engine.connect() as connection:
        context = MigrationContext.configure(connection, opts={"compare_type": False})
        differences = compare_metadata(context, Base.metadata)
    assert differences == []


def test_migrations_can_be_undone(tmp_path):
    db = tmp_path / "db.sqlite"
    _alembic(db, "upgrade", "head")
    _alembic(db, "downgrade", "base")
    tables = {
        row[0]
        for row in sqlite3.connect(db).execute("select name from sqlite_master where type='table'")
    }
    assert tables <= {"alembic_version"}
