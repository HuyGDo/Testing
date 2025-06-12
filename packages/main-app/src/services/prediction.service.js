const { v4: uuidv4 } = require('uuid');
const RabbitMQService = require('./rabbit_mq.service');
const { redisClient, hgetallAsync } = require('../config/redis');
const db = require('../config/database');
const RecommendationService = require('./recommendation.service');

class PredictionService {
  /**
   * Initiates a prediction task by sending it to the queue.
   * @param {string} vm_id - The ID of the VM.
   * @param {string} metric_name - The name of the metric to predict.
   * @param {number} horizon_min - The prediction horizon in minutes.
   * @returns {string} The task ID for the prediction request.
   */
  static async startPrediction(vm_id, metric_name, horizon_min) {
    const task_id = uuidv4();
    const message = {
      task_id,
      vm_id,
      metric_name,
      horizon_min,
    };
    
    RabbitMQService.sendToQueue(message);

    // Store the latest task_id for this prediction combination
    const key = `last_task:${vm_id}:${metric_name}:${horizon_min}`;
    await redisClient.set(key, task_id);
    
    return task_id;
  }

  /**
   * Retrieves the result of a prediction task from Redis.
   * @param {string} task_id - The ID of the task.
   * @returns {object|null} The prediction result or null if not found.
   */
  static async getPredictionResult(task_id) {
    const key = `prediction:${task_id}`;
    const result = await hgetallAsync(key);

    if (result && result.prediction && typeof result.prediction === 'string') {
      // The prediction is stored as a JSON string, so we need to parse it.
      try {
        result.prediction = JSON.parse(result.prediction);
      } catch (e) {
        console.error("Failed to parse prediction JSON", e)
        // Keep it as a string if parsing fails
      }
    }
    
    return result;
  }

  /**
   * [NEW] Fetches historical data for the dashboard.
   */
  static async getHistoricalData(vm_id, metric) {
    // Fetches the last 24 hours of 1-minute aggregated data
    const query = `
      SELECT bucket as timestamp, ${metric} as value
      FROM metrics_wide
      WHERE vm_id = $1 AND ${metric} IS NOT NULL AND bucket >= now() - INTERVAL '24 hours'
      ORDER BY bucket;
    `;
    const { rows } = await db.query(query, [vm_id]);
    return rows;
  }

  /**
   * [NEW] Gets a recommendation based on a completed prediction task.
   */
  static async getRecommendation(task_id) {
    const predictionResult = await this.getPredictionResult(task_id);
    if (!predictionResult || predictionResult.status !== 'COMPLETED') {
        return "Recommendation is not ready yet. Prediction is pending or failed.";
    }
    // The recommendation service expects the raw prediction data
    const recommendation = RecommendationService.getRecommendation(predictionResult);
    return recommendation.recommendation;
  }
}

module.exports = PredictionService;