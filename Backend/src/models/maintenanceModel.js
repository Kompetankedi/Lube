const db = require('../config/db');

class Maintenance {
    static async getDefinitions() {
        const [rows] = await db.execute('SELECT * FROM maintenance_definitions');
        return rows;
    }

    static async createLog(logData) {
        const { vehicle_id, definition_id, service_date, service_km, price, notes } = logData;
        const [result] = await db.execute(
            'INSERT INTO maintenance_logs (vehicle_id, definition_id, service_date, service_km, price, notes) VALUES (?, ?, ?, ?, ?, ?)',
            [vehicle_id, definition_id, service_date, service_km, price, notes]
        );
        return result.insertId;
    }

    static async getLogsByVehicleId(vehicleId) {
        const query = `
            SELECT ml.*, md.name as definition_name, md.km_interval, md.month_interval, md.warning_note
            FROM maintenance_logs ml
            JOIN maintenance_definitions md ON ml.definition_id = md.id
            WHERE ml.vehicle_id = ?
            ORDER BY ml.service_date DESC
        `;
        const [rows] = await db.execute(query, [vehicleId]);
        return rows;
    }

    static async getVehicleMaintenanceStatus(vehicleId) {
        // Fetch current vehicle info
        const [[vehicle]] = await db.execute('SELECT current_km FROM vehicles WHERE id = ?', [vehicleId]);
        if (!vehicle) return null;

        // Fetch all definitions
        const definitions = await this.getDefinitions();
        
        // Fetch last log for each definition
        const status = [];
        for (const def of definitions) {
            const query = `
                SELECT service_km, service_date 
                FROM maintenance_logs 
                WHERE vehicle_id = ? AND definition_id = ? 
                ORDER BY service_date DESC LIMIT 1
            `;
            const [[lastLog]] = await db.execute(query, [vehicleId, def.id]);
            
            let remainingKm = def.km_interval;
            let status_note = "Henüz bakım yapılmadı";

            if (lastLog) {
                const kmSinceLastService = vehicle.current_km - lastLog.service_km;
                remainingKm = def.km_interval - kmSinceLastService;
                status_note = remainingKm <= 0 ? "Bakım zamanı geldi!" : `Kalan: ${remainingKm} KM`;
            }

            status.push({
                ...def,
                last_service_km: lastLog ? lastLog.service_km : null,
                last_service_date: lastLog ? lastLog.service_date : null,
                remaining_km: remainingKm,
                status_note: status_note
            });
        }
        return status;
    }
}

module.exports = Maintenance;
