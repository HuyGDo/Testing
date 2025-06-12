import psycopg2
from app.core.config import settings

class DBConnection:
    conn = None

db = DBConnection()

def get_db_connection():
    """Returns the active database connection."""
    return db.conn

def connect_to_db():
    """Establishes the database connection."""
    db.conn = psycopg2.connect(settings.DATABASE_URL)

def close_db_connection():
    """Closes the database connection."""
    if db.conn is not None:
        db.conn.close() 