import os
import time
import logging
import atexit
import sys
from app.features.cpu_transformer import CpuFeatureTransformer # Import the new class
from app.core.db import connect_to_db, close_db_connection

# --- Setup logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Singleton Lock using PID file ---
PIDFILE = "/tmp/feature_engineering_worker.pid"

def acquire_lock():
    """Acquires a lock by writing the current PID to a file."""
    if os.path.exists(PIDFILE):
        try:
            with open(PIDFILE, 'r') as f:
                pid = int(f.read())
            os.kill(pid, 0)
            logger.warning(f"Worker already running with PID {pid}. Exiting.")
            return False
        except (OSError, ValueError):
            logger.warning("Stale PID file found. Removing it.")
            os.remove(PIDFILE)
    
    with open(PIDFILE, 'w') as f:
        f.write(str(os.getpid()))
    
    atexit.register(release_lock)
    logger.info(f"Acquired lock. Worker started with PID {os.getpid()}.")
    return True

def release_lock():
    """Releases the lock by deleting the PID file."""
    try:
        if os.path.exists(PIDFILE) and os.path.isfile(PIDFILE):
            with open(PIDFILE, 'r') as f:
                if f.read() == str(os.getpid()):
                    os.remove(PIDFILE)
                    logger.info("Released lock.")
    except Exception as e:
        logger.error(f"Failed to release lock: {e}")

def main_loop():
    """The main loop that periodically runs the feature engineering batch job."""
    if not acquire_lock():
        sys.exit(1)
        
    # Instantiate the transformer once.
    cpu_transformer = CpuFeatureTransformer()
    
    try:
        connect_to_db()
        logger.info("Starting feature engineering worker...")
        
        while True:
            try:
                # Call the run_batch method on the instance
                cpu_transformer.run_batch()
            except Exception as e:
                logger.error(f"An error occurred during the feature engineering batch: {e}", exc_info=True)
            
            sleep_interval = 30 
            logger.info(f"Batch finished. Sleeping for {sleep_interval} seconds...")
            time.sleep(sleep_interval)
            
    finally:
        close_db_connection()
        release_lock()

if __name__ == "__main__":
    try:
        main_loop()
    except KeyboardInterrupt:
        logger.info("Worker stopped by user.")
        sys.exit(0)
