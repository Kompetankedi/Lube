const Vehicle = require('../models/vehicleModel');

exports.getVehicles = async (req, res) => {
    try {
        const userId = req.query.user_id || 1; 
        const vehicles = await Vehicle.getAllByUserId(userId);
        res.json(vehicles);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createVehicle = async (req, res) => {
    try {
        const vehicleId = await Vehicle.create(req.body);
        res.status(201).json({ id: vehicleId, message: 'Vehicle created successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateKm = async (req, res) => {
    try {
        const { id } = req.params;
        const { current_km } = req.body;
        const success = await Vehicle.updateKm(id, current_km);
        if (success) {
            res.json({ message: 'KM updated successfully' });
        } else {
            res.status(404).json({ message: 'Vehicle not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateVehicle = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Vehicle.update(id, req.body);
        if (success) {
            res.json({ message: 'Vehicle updated successfully' });
        } else {
            res.status(404).json({ message: 'Vehicle not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteVehicle = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Vehicle.delete(id);
        if (success) {
            res.json({ message: 'Vehicle deleted successfully' });
        } else {
            res.status(404).json({ message: 'Vehicle not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
