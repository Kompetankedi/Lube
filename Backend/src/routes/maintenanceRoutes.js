const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');

// Definitions
router.get('/definitions', maintenanceController.getDefinitions);
router.post('/definitions', maintenanceController.createDefinition);
router.put('/definitions/:id', maintenanceController.updateDefinition);
router.delete('/definitions/:id', maintenanceController.deleteDefinition);

// Logs
router.post('/logs', maintenanceController.createLog);
router.put('/logs/:id', maintenanceController.updateLog);
router.delete('/logs/:id', maintenanceController.deleteLog);
router.get('/logs/:vehicle_id', maintenanceController.getLogs);
router.get('/user-logs/:user_id', maintenanceController.getLogsByUser);

// Status
router.get('/status/:vehicle_id', maintenanceController.getStatus);

module.exports = router;
