const express = require('express');
const cors = require('cors');
const { connectToRabbitMQ } = require('./config/rabbitmq');
const vmRoutes = require('./api/vm.routes');
const predictionRoutes = require('./api/prediction.routes.js');
const { initializeRedisSubscriber } = require('./config/redis.subscriber.js');
require('./cron/prediction.cron.js'); // Initialize cron jobs

const app = express();
const port = process.env.PORT || 3000;

// Connect to RabbitMQ
connectToRabbitMQ();

// Initialize Redis Subscriber for SSE
initializeRedisSubscriber();

app.use(cors({ origin: 'http://localhost:3001' }));
app.use(express.json());

app.use('/api/', vmRoutes);
app.use('/api/', predictionRoutes);

module.exports = app;
