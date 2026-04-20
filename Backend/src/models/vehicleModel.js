const db = require('../config/db');

class Vehicle {
    static async getAllByUserId(userId) {
        const [rows] = await db.execute('SELECT * FROM vehicles WHERE user_id = ?', [userId]);
        return rows;
    }

    static async create(vehicleData) {
        const { user_id, brand, model, year, plate, current_km, fuel_type, chassis_number, transmission_type, insurance_date, casco_date, inspection_date, exhaust_emission_date } = vehicleData;
        const [result] = await db.execute(
            'INSERT INTO vehicles (user_id, brand, model, year, plate, current_km, fuel_type, chassis_number, transmission_type, insurance_date, casco_date, inspection_date, exhaust_emission_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                user_id ?? null, 
                brand ?? null, 
                model ?? null, 
                year ?? null, 
                plate ?? null, 
                current_km ?? null, 
                fuel_type ?? null, 
                chassis_number ?? null, 
                transmission_type ?? null, 
                insurance_date ?? null, 
                casco_date ?? null, 
                inspection_date ?? null, 
                exhaust_emission_date ?? null
            ]
        );
        return result.insertId;
    }

    static async updateKm(id, km) {
        const [result] = await db.execute('UPDATE vehicles SET current_km = ? WHERE id = ?', [km, id]);
        return result.affectedRows > 0;
    }

    static async update(id, vehicleData) {
        const { brand, model, year, plate, current_km, fuel_type, chassis_number, transmission_type, insurance_date, casco_date, inspection_date, exhaust_emission_date } = vehicleData;
        const [result] = await db.execute(
            'UPDATE vehicles SET brand = ?, model = ?, year = ?, plate = ?, current_km = ?, fuel_type = ?, chassis_number = ?, transmission_type = ?, insurance_date = ?, casco_date = ?, inspection_date = ?, exhaust_emission_date = ? WHERE id = ?',
            [
                brand ?? null, 
                model ?? null, 
                year ?? null, 
                plate ?? null, 
                current_km ?? null, 
                fuel_type ?? null, 
                chassis_number ?? null, 
                transmission_type ?? null, 
                insurance_date ?? null, 
                casco_date ?? null, 
                inspection_date ?? null, 
                exhaust_emission_date ?? null,
                id
            ]
        );
        return result.affectedRows > 0;
    }

    static async delete(id) {
        const [result] = await db.execute('DELETE FROM vehicles WHERE id = ?', [id]);
        return result.affectedRows > 0;
    }
}

module.exports = Vehicle;
