const db = require('../config/db');

exports.register = async (req, res) => {
    try {
        const { email, password, name } = req.body;
        const [result] = await db.execute(
            'INSERT INTO users (email, password, name) VALUES (?, ?, ?)',
            [email, password, name]
        );
        res.status(201).json({ id: result.insertId, message: 'User registered successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 1. Check .env for Master Admin (as requested)
        if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
            return res.json({ 
                user: { id: 0, email: email, name: 'Sistem Yöneticisi' }, 
                message: 'Admin girişi başarılı (Master Account)' 
            });
        }

        // 2. Check Database for normal users
        const [rows] = await db.execute(
            'SELECT id, email, name FROM users WHERE email = ? AND password = ?',
            [email, password]
        );
        
        if (rows.length > 0) {
            res.json({ user: rows[0], message: 'Login successful' });
        } else {
            res.status(401).json({ message: 'Geçersiz e-posta veya şifre' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
