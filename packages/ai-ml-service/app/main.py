# File: packages/ai-ml-service/app/main.py
from fastapi import FastAPI, Depends
# from app.api.v1 import prediction_router, training_router
from app.core.life_span import lifespan
from app.core.db import get_db_connection
import psycopg2

# Create the FastAPI app instance
app = FastAPI(
    title="AI/ML Prediction Service",
    description="A service to train models and predict system load.",
    version="1.0.0",
    lifespan=lifespan
)

# Include the API routers. All routes from a router will be prefixed with its `prefix`.
# app.include_router(prediction_router.router, prefix="/api/v1", tags=["Prediction"])
# app.include_router(training_router.router, prefix="/api/v1", tags=["Training"])

@app.get("/", tags=["Health Check"])
def read_root():
    """A simple endpoint to confirm the service is welcoming."""
    return {"status": "ok", "message": "Welcome to the AI/ML Service!"}

@app.get("/health", tags=["Health Check"])
def health_check(conn: psycopg2.extensions.connection = Depends(get_db_connection)):
    """A health check endpoint to confirm the service is running and connected to the database."""
    db_status = "ok"
    db_message = "Database connection is healthy."
    try:
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.close()
    except Exception as e:
        db_status = "error"
        db_message = f"Database connection failed: {e}"

    return {
        "service_status": "ok",
        "database_status": db_status,
        "database_message": db_message
    }

# To run this application:
# 1. Navigate to the `packages/ai-ml-service` directory in your terminal.
# 2. Create a .env file with DATABASE_URL (e.g., DATABASE_URL="postgresql://user:password@host:port/dbname")
# 3. Run the command: uvicorn app.main:app --reload
#    This starts the server, and `--reload` makes it restart automatically on code changes.
