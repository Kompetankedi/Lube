const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');

router.get('/definitions', maintenanceController.getDefinitions);
router.post('/logs', maintenanceController.createLog);
router.get('/logs/:vehicle_id', maintenanceController.getLogs);
router.get('/status/:vehicle_id', maintenanceController.getStatus);

module.exports = router;
