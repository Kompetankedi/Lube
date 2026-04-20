const Maintenance = require('../models/maintenanceModel');

exports.getDefinitions = async (req, res) => {
    try {
        const definitions = await Maintenance.getDefinitions();
        res.json(definitions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.createDefinition = async (req, res) => {
    try {
        console.log('Create definition request body:', req.body);
        const defId = await Maintenance.createDefinition(req.body);
        res.status(201).json({ id: defId, message: 'Bakım tanımı oluşturuldu' });
    } catch (error) {
        console.error('Create definition error:', error);
        res.status(500).json({ error: error.message });
    }
};

exports.updateDefinition = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Maintenance.updateDefinition(id, req.body);
        if (success) {
            res.json({ message: 'Bakım tanımı güncellendi' });
        } else {
            res.status(404).json({ message: 'Bakım tanımı bulunamadı' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteDefinition = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Maintenance.deleteDefinition(id);
        if (success) {
            res.json({ message: 'Bakım tanımı silindi' });
        } else {
            res.status(404).json({ message: 'Bakım tanımı bulunamadı' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.createLog = async (req, res) => {
    try {
        const { vehicle_id, definition_id, service_date, service_km } = req.body;
        
        if (!vehicle_id || !definition_id || !service_date || service_km === undefined) {
            return res.status(400).json({ error: 'Eksik bilgi: araç, bakım türü, tarih ve km zorunludur.' });
        }

        console.log('Bakım kaydı oluşturuluyor:', req.body);
        const logId = await Maintenance.createLog(req.body);
        res.status(201).json({ id: logId, message: 'Bakım kaydı oluşturuldu' });
    } catch (error) {
        console.error('Bakım kaydı oluşturma hatası:', error);
        
        let errorMessage = 'Bakım kaydı eklenirken bir hata oluştu.';
        if (error.code === 'ER_NO_REFERENCED_ROW_2') {
            errorMessage = 'Seçilen araç veya bakım türü geçerli değil.';
        } else if (error.code === 'ER_TRUNCATED_WRONG_VALUE') {
            errorMessage = 'Geçersiz veri formatı (tarih veya sayısal değerler).';
        }

        res.status(500).json({ error: errorMessage, details: error.message });
    }
};


exports.updateLog = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Maintenance.updateLog(id, req.body);
        if (success) {
            res.json({ message: 'Bakım kaydı güncellendi' });
        } else {
            res.status(404).json({ message: 'Bakım kaydı bulunamadı' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteLog = async (req, res) => {
    try {
        const { id } = req.params;
        const success = await Maintenance.deleteLog(id);
        if (success) {
            res.json({ message: 'Bakım kaydı silindi' });
        } else {
            res.status(404).json({ message: 'Bakım kaydı bulunamadı' });
        }
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

exports.getLogsByUser = async (req, res) => {
    try {
        const { user_id } = req.params;
        const logs = await Maintenance.getLogsByUserId(user_id);
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
            res.status(404).json({ message: 'Araç bulunamadı' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
