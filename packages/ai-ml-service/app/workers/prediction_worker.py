import logging
import json
import sys
from app.workers.rabbitmq_client import rabbitmq_client
from app.services.prediction_service import prediction_service
from app.core.db import connect_to_db, close_db_connection
from app.core.cache import connect_to_redis, close_redis_connection

# --- Setup logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def prediction_callback(ch, method, properties, body):
    """
    This function is called for each message received from the queue.
    It processes the message and acknowledges it upon completion.
    """
    task_id = None  # Initialize task_id to ensure it's available for logging
    try:
        message = json.loads(body)
        task_id = message.get("task_id")
        vm_id = message.get("vm_id")
        metric_name = message.get("metric_name")
        horizon_min = message.get("horizon_min")

        if not all([task_id, vm_id, metric_name, horizon_min]):
            logger.error(f"Invalid message received (missing keys): {message}")
            # Reject the message as it cannot be processed
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
            return

        logger.info(f"Received prediction task: {task_id}")
        prediction_service.process_prediction_request(task_id, vm_id, metric_name, horizon_min)
        
        # Acknowledge the message to remove it from the queue
        ch.basic_ack(delivery_tag=method.delivery_tag)
        logger.info(f"Successfully processed and acknowledged task: {task_id}")

    except json.JSONDecodeError:
        logger.error(f"Failed to decode message body: {body}", exc_info=True)
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
    except Exception as e:
        logger.error(f"An unexpected error occurred processing task {task_id}: {e}", exc_info=True)
        # Negatively acknowledge the message, but don't requeue to prevent poison pills
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def main():
    """
    Main function to start the prediction worker.
    Establishes connections and begins consuming from RabbitMQ.
    """
    try:
        # Establish all necessary connections before starting
        connect_to_db()
        connect_to_redis()
        
        # This call starts a blocking loop that waits for messages
        logger.info("Prediction worker started. Waiting for tasks...")
        rabbitmq_client.consume("prediction_tasks", prediction_callback)

    except KeyboardInterrupt:
        logger.info("Shutdown signal received (Ctrl+C).")
    except Exception as e:
        logger.error(f"Prediction worker failed to start or encountered a fatal error: {e}", exc_info=True)
    finally:
        # This block will now execute reliably on shutdown
        logger.info("Shutting down worker and closing connections...")
        close_db_connection()
        close_redis_connection()
        # It's good practice for the RabbitMQ client to have a close method
        if hasattr(rabbitmq_client, 'close_connection'):
            rabbitmq_client.close_connection()
        logger.info("Prediction worker has been shut down.")
        sys.exit(0)


if __name__ == "__main__":
    main()
