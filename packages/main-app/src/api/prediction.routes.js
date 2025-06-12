const express = require('express');
const PredictionController = require('../controllers/prediction.controller');
const sseService = require('../services/sse.service');

const router = express.Router();

// Route to trigger a new prediction
router.post('/predict', PredictionController.createPrediction);

// Route to get prediction status
router.get('/predict/status/:task_id', PredictionController.getPrediction);

// Route for real-time updates via SSE
router.get('/predict/events/:vm_id', (req, res) => {
    const { vm_id } = req.params;
    sseService.addClient(req, res, vm_id);
});

// Route to get dashboard data
router.get('/dashboard-data', PredictionController.getDashboardData);

// Route to get recommendations
router.get('/recommendations', PredictionController.getRecommendations);

module.exports = router;
