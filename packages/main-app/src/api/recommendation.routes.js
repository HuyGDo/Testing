const express = require('express');
const RecommendationController = require('../controllers/recommendation.controller');
const router = express.Router();

router.get('/', RecommendationController.createRecommendation);

module.exports = router; 