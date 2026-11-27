"""baseline

Revision ID: 49f1ec6f45a1
Revises:
Create Date: 2026-11-07 09:33:08.329684

"""

from collections.abc import Sequence

# revision identifiers, used by Alembic.
revision: str = "49f1ec6f45a1"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""


def downgrade() -> None:
    """Downgrade schema."""
