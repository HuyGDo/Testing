import redis
from app.core.config import settings

class RedisConnection:
    conn = None

redis_db = RedisConnection()

def get_redis_connection():
    """Returns the active redis connection."""
    return redis_db.conn

def connect_to_redis():
    """Establishes the redis connection."""
    redis_db.conn = redis.from_url(settings.REDIS_URL)

def close_redis_connection():
    """Closes the redis connection."""
    if redis_db.conn is not None:
        redis_db.conn.close() 