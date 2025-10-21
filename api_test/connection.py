import sqlite3
from pathlib import Path

# -----------------------
# Conexão com SQLite
# -----------------------

DB_PATH = Path(__file__).resolve().parent.parent / "database" / "greendb"

def get_db_connection():
    # usa um caminho absoluto baseado na localização do arquivo para evitar erros
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn