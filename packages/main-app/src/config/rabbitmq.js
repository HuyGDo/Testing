const amqp = require('amqplib');

const rabbitmqUrl = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5672/%2f';
const queueName = 'prediction_tasks';

let connection = null;
let channel = null;

async function connectToRabbitMQ() {
  try {
    connection = await amqp.connect(rabbitmqUrl);
    channel = await connection.createChannel();
    await channel.assertQueue(queueName, { durable: true });
    console.log('Connected to RabbitMQ and queue asserted');
  } catch (error) {
    console.error('Failed to connect to RabbitMQ:', error);
    // Optional: implement retry logic
    setTimeout(connectToRabbitMQ, 5000);
  }

  connection.on('error', (err) => {
    console.error('RabbitMQ connection error:', err);
    // Reconnect on error
    if (!connection.isConnected()) {
        connectToRabbitMQ();
    }
  });

  connection.on('close', () => {
    console.error('RabbitMQ connection closed. Reconnecting...');
    // Reconnect on close
    setTimeout(connectToRabbitMQ, 5000);
  });
}

function getChannel() {
  if (!channel) {
    throw new Error('RabbitMQ channel is not available.');
  }
  return channel;
}

module.exports = {
  connectToRabbitMQ,
  getChannel,
  queueName,
};
