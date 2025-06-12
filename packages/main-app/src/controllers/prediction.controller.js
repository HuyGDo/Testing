const PredictionService = require('../services/prediction.service');
const { getAsync } = require('../config/redis');

class PredictionController {
  /**
   * Handles the request to start a new prediction.
   * Checks for a fresh cached result before creating a new task.
   */
  static async createPrediction(req, res) {
    try {
      const { vm_id, metric_name, horizon_min } = req.body;

      if (!vm_id || !metric_name || !horizon_min) {
        return res.status(400).json({ error: 'Missing required parameters: vm_id, metric_name, horizon_min.' });
      }

      // Check for a recent, completed prediction before starting a new one.
      const lastTaskId = await getAsync(`last_task:${vm_id}:${metric_name}:${horizon_min}`);
      if (lastTaskId) {
        const result = await PredictionService.getPredictionResult(lastTaskId);
        // Define what "fresh" means, e.g., completed in the last 5 minutes.
        const fiveMinutes = 5 * 60 * 1000;
        const isFresh = result && result.status === 'COMPLETED' && (new Date() - new Date(result.timestamp)) < fiveMinutes;
        
        if (isFresh) {
          console.log(`Returning fresh prediction for task_id: ${lastTaskId}`);
          return res.status(200).json(result);
        }
      }

      const task_id = await PredictionService.startPrediction(vm_id, metric_name, horizon_min);
      
      res.status(202).json({
        message: 'Prediction task accepted.',
        task_id,
        status_endpoint: `/api/prediction/status/${task_id}`,
      });
    } catch (error) {
      console.error('Error creating prediction:', error);
      res.status(500).json({ error: 'Failed to start prediction task.' });
    }
  }

  /**
   * Handles the request to get the result of a prediction.
   */
  static async getPrediction(req, res) {
    try {
      const { task_id } = req.params;
      const result = await PredictionService.getPredictionResult(task_id);

      if (!result) {
        return res.status(202).json({ status: 'PENDING', message: 'Prediction is still processing or task ID not found.' });
      }
      
      res.status(200).json(result);
    } catch (error) {
      console.error('Error getting prediction result:', error);
      res.status(500).json({ error: 'Failed to retrieve prediction result.' });
    }
  }

  static async getDashboardData(req, res) {
    try {
      const { vm_id, metric } = req.query;
      
      if (!vm_id || !metric) {
        return res.status(400).json({ 
          error: 'Missing required parameters: vm_id, metric' 
        });
      }

      const data = await PredictionService.getHistoricalData(vm_id, metric);
      res.status(200).json(data);
    } catch (error) {
      console.error('Error getting dashboard data:', error);
      res.status(500).json({ error: 'Failed to retrieve dashboard data.' });
    }
  }

  static async getRecommendations(req, res) {
    try {
      const { task_id } = req.query;
      
      if (!task_id) {
        return res.status(400).json({ 
          error: 'Missing required parameter: task_id' 
        });
      }

      const recommendation = await PredictionService.getRecommendation(task_id);
      res.status(200).json({ recommendation });
    } catch (error) {
      console.error('Error getting recommendations:', error);
      res.status(500).json({ error: 'Failed to retrieve recommendations.' });
    }
  }
}

module.exports = PredictionController;
