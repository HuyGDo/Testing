import logging
import json
from app.workers.rabbitmq_client import rabbitmq_client
from app.services.prediction_service import prediction_service
from app.core.db import connect_to_db, close_db_connection
from app.core.cache import connect_to_redis, close_redis_connection

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def prediction_callback(ch, method, properties, body):
    try:
        message = json.loads(body)
        task_id = message.get("task_id")
        vm_id = message.get("vm_id")
        metric_name = message.get("metric_name")
        horizon_min = message.get("horizon_min")

        if not all([task_id, vm_id, metric_name, horizon_min]):
            logger.error(f"Invalid message received: {message}")
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
            return

        logger.info(f"Received prediction task: {task_id}")
        prediction_service.process_prediction_request(task_id, vm_id, metric_name, horizon_min)
        
        ch.basic_ack(delivery_tag=method.delivery_tag)
        logger.info(f"Acknowledged task: {task_id}")

    except json.JSONDecodeError:
        logger.error(f"Failed to decode message body: {body}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def main():
    try:
        connect_to_db()
        connect_to_redis()
        rabbitmq_client.consume("prediction_tasks", prediction_callback)
    except Exception as e:
        logger.error(f"Prediction worker failed to start: {e}")
    finally:
        close_db_connection()
        close_redis_connection()
        logger.info("Prediction worker shut down.")

if __name__ == "__main__":
    main()
