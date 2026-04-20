const Maintenance = require('../models/maintenanceModel');

exports.getDefinitions = async (req, res) => {
    try {
        const definitions = await Maintenance.getDefinitions();
        res.json(definitions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createLog = async (req, res) => {
    try {
        const logId = await Maintenance.createLog(req.body);
        res.status(201).json({ id: logId, message: 'Maintenance log created successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getLogs = async (req, res) => {
    try {
        const { vehicle_id } = req.params;
        const logs = await Maintenance.getLogsByVehicleId(vehicle_id);
        res.json(logs);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getStatus = async (req, res) => {
    try {
        const { vehicle_id } = req.params;
        const status = await Maintenance.getVehicleMaintenanceStatus(vehicle_id);
        if (status) {
            res.json(status);
        } else {
            res.status(404).json({ message: 'Vehicle not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
