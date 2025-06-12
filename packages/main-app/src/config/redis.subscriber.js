const { redisClient } = require('./redis');
const sseService = require('../services/sse.service');

function initializeRedisSubscriber() {
  const subscriber = redisClient.duplicate();

  subscriber.on('connect', () => {
    console.log('Redis subscriber connected.');
  });

  subscriber.on('error', (err) => {
    console.error('Redis subscriber connection error:', err);
  });

  (async () => {
    await subscriber.connect();
    await subscriber.subscribe('prediction_events', (message) => {
      try {
        const parsedMessage = JSON.parse(message);
        console.log('Received message from Redis:', parsedMessage);
        
        if (parsedMessage.event === 'prediction_ready' && parsedMessage.vm_id) {
          sseService.send(parsedMessage.vm_id, parsedMessage);
        }
      } catch (error) {
        console.error('Failed to parse or handle message from Redis:', error);
      }
    });
  })();

  return subscriber;
}

module.exports = { initializeRedisSubscriber }; 