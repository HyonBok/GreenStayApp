"""Database connection helpers.

This module centralises how the application obtains a SQLite connection.
For deployment on Render the database file remains bundled with the app,
but the location can be overridden using the ``DATABASE_PATH`` environment
variable. This keeps the default behaviour for local development while
allowing the path to be configured when necessary.
"""

from __future__ import annotations

import os
import sqlite3
from pathlib import Path

DEFAULT_DB_PATH = Path(__file__).resolve().parent.parent / "database" / "greendb"


def _resolve_db_path() -> Path:
    """Return the absolute path to the SQLite database file.

    Render deploys the repository to ``/opt/render/project/src`` by default,
    so we first look for an override through the ``DATABASE_PATH`` environment
    variable. When unset we fall back to the bundled database file.
    """

    env_path = os.getenv("DATABASE_PATH")
    if env_path:
        return Path(env_path).expanduser().resolve()
    return DEFAULT_DB_PATH


def get_db_connection():
    """Open a new SQLite connection using an absolute database path."""

    db_path = _resolve_db_path()
    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    return conn
