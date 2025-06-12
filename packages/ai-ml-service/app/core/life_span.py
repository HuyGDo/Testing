from contextlib import asynccontextmanager
from fastapi import FastAPI
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.services.data_processing_service import process_cpu_metrics
from app.core.db import connect_to_db, close_db_connection
from app.core.cache import connect_to_redis, close_redis_connection

scheduler = AsyncIOScheduler()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Handles startup and shutdown events, including DB connection and scheduled jobs.
    """
    try:
        # Establish database connection
        connect_to_db()
        connect_to_redis()
        
        # Schedule the job to run every 5 minutes
        scheduler.add_job(process_cpu_metrics, 'interval', minutes=5, id="process_cpu_metrics_job")
        scheduler.start()
        
        yield
    finally:
        # Shutdown scheduler and close DB connection
        if scheduler.running:
            scheduler.shutdown()
        close_db_connection()
        close_redis_connection()
