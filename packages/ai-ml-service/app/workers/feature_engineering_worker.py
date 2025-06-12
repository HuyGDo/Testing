import os
import time
import logging
import atexit
import sys
from app.features.cpu_transformer import run_cpu_feature_engineering_batch

# --- Setup logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Singleton Lock using PID file ---
# This prevents multiple instances of the worker from running concurrently.
PIDFILE = "/tmp/feature_engineering_worker.pid"

def acquire_lock():
    """Acquires a lock by writing the current PID to a file."""
    if os.path.exists(PIDFILE):
        try:
            with open(PIDFILE, 'r') as f:
                pid = int(f.read())
            # Check if the process with that PID is still running.
            os.kill(pid, 0)
            logger.warning(f"Worker already running with PID {pid}. Exiting.")
            return False
        except (OSError, ValueError):
            # The process is not running, or the PID file is corrupt.
            logger.warning("Stale PID file found. Removing it.")
            os.remove(PIDFILE)

    with open(PIDFILE, 'w') as f:
        f.write(str(os.getpid()))
    
    # Register the cleanup function to be called on script exit.
    atexit.register(release_lock)
    logger.info(f"Acquired lock. Worker started with PID {os.getpid()}.")
    return True

def release_lock():
    """Releases the lock by deleting the PID file."""
    try:
        if os.path.exists(PIDFILE):
            with open(PIDFILE, 'r') as f:
                # Ensure we are not deleting a lock held by another process
                if f.read() == str(os.getpid()):
                    os.remove(PIDFILE)
                    logger.info("Released lock.")
    except Exception as e:
        logger.error(f"Failed to release lock: {e}")

def main_loop():
    """The main loop that periodically runs the feature engineering batch job."""
    if not acquire_lock():
        sys.exit(1) # Exit if lock cannot be acquired
        
    logger.info("Starting feature engineering worker...")
    
    # Run indefinitely, scheduling the feature engineering job
    while True:
        try:
            run_cpu_feature_engineering_batch()
        except Exception as e:
            # Log the error but allow the worker to continue running.
            logger.error(f"An error occurred during the feature engineering batch: {e}", exc_info=True)
        
        # As per the prompt, run every 20-30 seconds.
        sleep_interval = 30 
        logger.info(f"Batch finished. Sleeping for {sleep_interval} seconds...")
        time.sleep(sleep_interval)

if __name__ == "__main__":
    try:
        main_loop()
    except KeyboardInterrupt:
        logger.info("Worker stopped by user.")
        sys.exit(0)

