const db = require('../config/db');

class Maintenance {
    static async getDefinitions() {
        const [rows] = await db.execute('SELECT * FROM maintenance_definitions');
        return rows;
    }

    static async createDefinition(defData) {
        const { name, km_interval, month_interval, warning_note } = defData;
        const [result] = await db.execute(
            'INSERT INTO maintenance_definitions (name, km_interval, month_interval, warning_note) VALUES (?, ?, ?, ?)',
            [name, km_interval ? parseInt(km_interval) : null, month_interval ? parseInt(month_interval) : null, warning_note ?? null]
        );
        return result.insertId;
    }

    static async updateDefinition(id, defData) {
        const { name, km_interval, month_interval, warning_note } = defData;
        const [result] = await db.execute(
            'UPDATE maintenance_definitions SET name = ?, km_interval = ?, month_interval = ?, warning_note = ? WHERE id = ?',
            [name, km_interval ?? null, month_interval ?? null, warning_note ?? null, id]
        );
        return result.affectedRows > 0;
    }

    static async deleteDefinition(id) {
        const [result] = await db.execute('DELETE FROM maintenance_definitions WHERE id = ?', [id]);
        return result.affectedRows > 0;
    }

    static async createLog(logData) {
        const { vehicle_id, definition_id, service_date, service_km, price, notes } = logData;
        const [result] = await db.execute(
            'INSERT INTO maintenance_logs (vehicle_id, definition_id, service_date, service_km, price, notes) VALUES (?, ?, ?, ?, ?, ?)',
            [vehicle_id, definition_id, service_date, parseInt(service_km), price ?? null, notes ?? null]
        );
        return result.insertId;
    }

    static async updateLog(id, logData) {
        const { service_date, service_km, price, notes } = logData;
        const [result] = await db.execute(
            'UPDATE maintenance_logs SET service_date = ?, service_km = ?, price = ?, notes = ? WHERE id = ?',
            [service_date, service_km, price ?? null, notes ?? null, id]
        );
        return result.affectedRows > 0;
    }

    static async deleteLog(id) {
        const [result] = await db.execute('DELETE FROM maintenance_logs WHERE id = ?', [id]);
        return result.affectedRows > 0;
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

    static async getLogsByUserId(userId) {
        const query = `
            SELECT ml.*, md.name as definition_name, md.km_interval, md.month_interval, md.warning_note, v.brand, v.model, v.plate
            FROM maintenance_logs ml
            JOIN maintenance_definitions md ON ml.definition_id = md.id
            JOIN vehicles v ON ml.vehicle_id = v.id
            WHERE v.user_id = ?
            ORDER BY ml.service_date DESC
        `;
        const [rows] = await db.execute(query, [userId]);
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
                SELECT id, service_km, service_date, price, notes
                FROM maintenance_logs 
                WHERE vehicle_id = ? AND definition_id = ? 
                ORDER BY service_date DESC LIMIT 1
            `;
            const [[lastLog]] = await db.execute(query, [vehicleId, def.id]);
            
            // Get total log count for this definition
            const [[countResult]] = await db.execute(
                'SELECT COUNT(*) as count FROM maintenance_logs WHERE vehicle_id = ? AND definition_id = ?',
                [vehicleId, def.id]
            );

            let remainingKm = def.km_interval;
            let remainingDays = null;
            let status_note = "Henüz bakım yapılmadı";
            let urgency = 'none'; // none, ok, warning, critical

            if (lastLog) {
                // KM based calculation
                const kmSinceLastService = vehicle.current_km - lastLog.service_km;
                remainingKm = def.km_interval - kmSinceLastService;
                
                // Date based calculation
                if (def.month_interval) {
                    const lastDate = new Date(lastLog.service_date);
                    const nextDate = new Date(lastDate);
                    nextDate.setMonth(nextDate.getMonth() + def.month_interval);
                    const now = new Date();
                    remainingDays = Math.ceil((nextDate - now) / (1000 * 60 * 60 * 24));
                }

                // Determine urgency
                if (remainingKm <= 0 || (remainingDays !== null && remainingDays <= 0)) {
                    urgency = 'critical';
                    status_note = 'Bakım zamanı geldi!';
                } else if (remainingKm <= 1000 || (remainingDays !== null && remainingDays <= 30)) {
                    urgency = 'warning';
                    status_note = `Yaklaşıyor! Kalan: ${Math.max(0, remainingKm)} KM`;
                } else {
                    urgency = 'ok';
                    status_note = `Kalan: ${remainingKm} KM`;
                }
            }

            status.push({
                ...def,
                last_service_km: lastLog ? lastLog.service_km : null,
                last_service_date: lastLog ? lastLog.service_date : null,
                last_service_price: lastLog ? lastLog.price : null,
                last_service_notes: lastLog ? lastLog.notes : null,
                last_log_id: lastLog ? lastLog.id : null,
                total_logs: countResult.count,
                remaining_km: remainingKm,
                remaining_days: remainingDays,
                urgency: urgency,
                status_note: status_note
            });
        }
        return status;
    }
}

module.exports = Maintenance;
