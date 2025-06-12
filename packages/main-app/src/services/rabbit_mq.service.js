const { getChannel, queueName } = require('../config/rabbitmq');

class RabbitMQService {
  /**
   * Sends a message to the prediction tasks queue.
   * @param {object} message - The message payload.
   */
  static sendToQueue(message) {
    try {
      const channel = getChannel();
      const messageBuffer = Buffer.from(JSON.stringify(message));
      
      channel.sendToQueue(queueName, messageBuffer, { persistent: true });
      
      console.log(`Sent message to queue '${queueName}':`, message);
    } catch (error) {
      console.error('Failed to send message to RabbitMQ:', error);
      // Depending on the application's needs, you might want to throw the error
      // to let the caller handle it (e.g., by returning a 500 error to the client).
      throw new Error('Failed to publish prediction task.');
    }
  }
}

module.exports = RabbitMQService;
