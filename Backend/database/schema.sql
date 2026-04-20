CREATE DATABASE IF NOT EXISTS car_care_db;
USE car_care_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT,
    plate VARCHAR(20),
    current_km INT DEFAULT 0,
    fuel_type ENUM('Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS maintenance_definitions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    km_interval INT,
    month_interval INT,
    warning_note TEXT
);

CREATE TABLE IF NOT EXISTS maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    definition_id INT NOT NULL,
    service_date DATE NOT NULL,
    service_km INT NOT NULL,
    price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (definition_id) REFERENCES maintenance_definitions(id)
);

-- Insert default maintenance definitions
INSERT INTO maintenance_definitions (name, km_interval, month_interval, warning_note) VALUES
('Motor Yağı Değişimi', 10000, 12, 'Yağ filtresi ile birlikte değiştirilmesi önerilir. Pesimist Hoca: Ucuz yağ kullanma, motoru eline alırsın!'),
('Triger Kayışı Kontrolü', 60000, 48, 'Kopması durumunda motora büyük zarar verir. Pesimist Hoca: Zamanı geçtiyse yolda kalman an meselesi.'),
('Fren Balatası Kontrolü', 20000, 12, 'Güvenliğiniz için her bakımda kontrol ettirin.'),
('Hava Filtresi Değişimi', 10000, 12, 'Performans ve yakıt ekonomisi için kritiktir.');
