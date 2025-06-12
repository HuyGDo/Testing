const PredictionService = require('../services/prediction.service');
const RecommendationService = require('../services/recommendation.service');

class RecommendationController {
    static async createRecommendation(req, res) {
        try {
            const { task_id } = req.query;
            if (!task_id) {
                return res.status(400).json({ error: "task_id is required." });
            }
            const predictionResult = await PredictionService.getPredictionResult(task_id);
            if (!predictionResult || predictionResult.status !== 'COMPLETED') {
                return res.status(404).json({ error: "Prediction not completed or not found." });
            }

            const recommendation = RecommendationService.getRecommendation(predictionResult);
            res.status(200).json(recommendation);
        } catch (error) {
            console.error('Error creating recommendation:', error);
            res.status(500).json({ error: 'Failed to create recommendation.' });
        }
    }
}
module.exports = RecommendationController; 