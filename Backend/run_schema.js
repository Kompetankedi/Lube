const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function runSchema() {
    try {
        console.log('Bağlanılıyor: ', process.env.DB_HOST);
        // First connect without database to create it if it doesn't exist
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            multipleStatements: true
        });

        console.log('Bağlantı başarılı. Schema.sql okunuyor...');
        const schemaPath = path.join(__dirname, 'database', 'schema.sql');
        const sql = fs.readFileSync(schemaPath, 'utf8');

        console.log('Schema çalıştırılıyor...');
        await connection.query(sql);

        console.log('Veritabanı ve tablolar başarıyla oluşturuldu!');
        await connection.end();
    } catch (error) {
        console.error('Hata:', error);
    }
}

runSchema();
