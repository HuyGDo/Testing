from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.core.db import connect_to_db, close_db_connection
from app.core.cache import connect_to_redis, close_redis_connection
import logging

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Handles application startup and shutdown events.
    """
    # --- Startup ---
    logger.info("Application starting up...")
    connect_to_db()
    connect_to_redis()
    logger.info("Database and Redis connections established.")
    
    # The call to the obsolete data_processing_service has been removed.
    # Feature engineering is now handled exclusively by the standalone worker.

    yield  # The application is now running

    # --- Shutdown ---
    logger.info("Application shutting down...")
    close_db_connection()
    close_redis_connection()
    logger.info("Database and Redis connections closed.")

