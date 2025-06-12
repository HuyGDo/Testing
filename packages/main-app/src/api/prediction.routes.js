const express = require('express');
const PredictionController = require('../controllers/prediction.controller');
const sseService = require('../services/sse.service');

const router = express.Router();

// Route to start a new prediction task
router.post('/prediction', PredictionController.createPrediction);

// Route to get the result of a prediction task (for polling)
router.get('/prediction/status', PredictionController.getPrediction);

// Route for clients to subscribe to prediction events for a specific VM
router.get('/prediction/events/:vm_id', (req, res) => {
    const { vm_id } = req.params;
    sseService.addClient(req, res, vm_id);
});

module.exports = router;
