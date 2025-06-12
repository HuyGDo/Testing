const express = require('express');
const router = express.Router();
const vmController = require('../controllers/vm.controller');

router.post('/vms', vmController.createVm);
router.get('/vms', vmController.getAllVms);

module.exports = router;
