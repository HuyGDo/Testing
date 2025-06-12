import pika
import os
import logging
import json
from app.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RabbitMQClient:
    def __init__(self):
        self.rabbitmq_url = settings.RABBITMQ_URL
        self.connection = None
        self.channel = None

    def connect(self):
        try:
            logger.info(f"Connecting to RabbitMQ at {self.rabbitmq_url}")
            self.connection = pika.BlockingConnection(pika.URLParameters(self.rabbitmq_url))
            self.channel = self.connection.channel()
            logger.info("Successfully connected to RabbitMQ")
        except pika.exceptions.AMQPConnectionError as e:
            logger.error(f"Failed to connect to RabbitMQ: {e}")
            raise

    def close(self):
        if self.connection and not self.connection.is_closed:
            self.connection.close()
            logger.info("RabbitMQ connection closed")

    def publish(self, queue_name, message):
        if not self.channel:
            self.connect()
        
        self.channel.queue_declare(queue=queue_name, durable=True)
        self.channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(message),
            properties=pika.BasicProperties(
                delivery_mode=2,  # make message persistent
            ))
        logger.info(f"Published message to queue '{queue_name}'")

    def consume(self, queue_name, callback):
        if not self.channel:
            self.connect()

        self.channel.queue_declare(queue=queue_name, durable=True)
        self.channel.basic_qos(prefetch_count=1)
        self.channel.basic_consume(queue=queue_name, on_message_callback=callback)

        try:
            logger.info(f"Waiting for messages in queue '{queue_name}'. To exit press CTRL+C")
            self.channel.start_consuming()
        except KeyboardInterrupt:
            self.channel.stop_consuming()
            self.close()

rabbitmq_client = RabbitMQClient()
