const db = require('../config/db');

class Vehicle {
    static async getAllByUserId(userId) {
        const [rows] = await db.execute('SELECT * FROM vehicles WHERE user_id = ?', [userId]);
        return rows;
    }

    static async create(vehicleData) {
        const { user_id, brand, model, year, plate, current_km, fuel_type } = vehicleData;
        const [result] = await db.execute(
            'INSERT INTO vehicles (user_id, brand, model, year, plate, current_km, fuel_type) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [user_id, brand, model, year, plate, current_km, fuel_type]
        );
        return result.insertId;
    }

    static async updateKm(id, km) {
        const [result] = await db.execute('UPDATE vehicles SET current_km = ? WHERE id = ?', [km, id]);
        return result.affectedRows > 0;
    }

    static async delete(id) {
        const [result] = await db.execute('DELETE FROM vehicles WHERE id = ?', [id]);
        return result.affectedRows > 0;
    }
}

module.exports = Vehicle;
