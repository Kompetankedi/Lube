const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');

router.get('/', vehicleController.getVehicles);
router.post('/', vehicleController.createVehicle);
router.put('/:id', vehicleController.updateKm);
router.delete('/:id', vehicleController.deleteVehicle);

module.exports = router;
