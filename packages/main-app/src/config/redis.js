const redis = require('redis');

const redisClient = redis.createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });

redisClient.on('connect', () => {
  console.log('Connected to Redis...');
});

redisClient.on('error', (err) => {
  console.error('Redis connection error:', err);
});

// In redis v4+, we must connect explicitly.
redisClient.connect().catch(console.error);

// The redis v4 client methods return Promises by default, so we no longer need util.promisify.
// We will export async functions to maintain compatibility with the services that use them.
module.exports = {
  redisClient,
  getAsync: async (key) => redisClient.get(key),
  hgetallAsync: async (key) => redisClient.hGetAll(key),
};
