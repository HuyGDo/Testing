import psycopg2
from sqlalchemy import create_engine
from app.core.config import settings

# --- SQLAlchemy Engine (NEW) ---
# This engine is what libraries like Pandas expect. It manages a connection
# pool and makes database interactions easier and more efficient.
# This line directly solves the "cannot import name 'engine'" error.
engine = create_engine(settings.DATABASE_URL)


# --- Existing Direct Psycopg2 Connection ---
# This code can remain for other parts of the app that might use it.
class DBConnection:
    conn = None

db = DBConnection()

def get_db_connection():
    """Returns the active raw psycopg2 database connection."""
    if db.conn is None or db.conn.closed:
        connect_to_db()
    return db.conn

def connect_to_db():
    """Establishes the global psycopg2 database connection."""
    if db.conn is None or db.conn.closed:
        db.conn = psycopg2.connect(settings.DATABASE_URL)
        print("Database connection established.")

def close_db_connection():
    """Closes the global psycopg2 database connection."""
    if db.conn is not None and not db.conn.closed:
        db.conn.close()
        db.conn = None
        print("Database connection closed.")
