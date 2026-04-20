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
    chassis_number VARCHAR(50),
    transmission_type ENUM('Manuel', 'Otomatik', 'Yarı Otomatik', 'DSG', 'CVT', 'Diğer'),
    current_km INT DEFAULT 0,
    fuel_type ENUM('Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'),
    insurance_date DATE,
    casco_date DATE,
    inspection_date DATE,
    exhaust_emission_date DATE,
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
('Motor Yağı ve Yağ Filtresi', 10000, 12, 'Motor ömrü için kritiktir.  Ucuz yağ kullanma, motoru eline alırsın!'),
('Hava Filtresi', 10000, 12, 'Performans ve yakıt ekonomisi için her bakımda değişmeli.'),
('Polen Filtresi', 10000, 12, 'Klima performansı ve kabin hava kalitesi için önemli.'),
('Mazot / Yakıt Filtresi', 20000, 24, 'Özellikle dizel araçlarda enjektör sağlığı için çok kritik.'),
('Antifriz / Soğutma Suyu', 40000, 24, 'Motorun donmasını ve hararet yapmasını engeller.'),
('Fren Hidroliği', 40000, 24, 'Fren performansı için hidroliğin nem oranı önemlidir.'),
('Şanzıman Yağı', 60000, 48, 'Otomatik şanzımanlarda ömürlüktür yalanına inanmayın, değişmesi gerekir.'),
('Triger Kayışı / Seti', 60000, 48, 'Kopması motora büyük zarar verir.  Triger değişirken devirdaim de mutlaka değişmeli!'),
('V Kayışı ve Gergisi', 60000, 48, 'Koparsa şarj dinamosu ve klima çalışmaz.'),
('Eksantrik Zinciri', 100000, 120, 'Ses yapmaya başladığında veya periyodu geldiğinde değişmeli.'),
('Fren Balataları ve Diskleri', 20000, 12, 'Güvenliğiniz için her periyodik bakımda kontrol edilmeli.'),
('Debriyaj Seti (Baskı Balata)', 80000, 60, 'Kavrama zayıfladığında veya sertleştiğinde kontrol edilmeli.'),
('Rot Ayarı / Balans Ayarı', 10000, 12, 'Lastik ömrü ve sürüş güvenliği için yılda bir yapılmalı.'),
('Lastik Rotasyonu', 10000, 12, 'Lastiklerin eşit aşınması için ön-arka değişimi.'),
('Amortisör Kontrolü', 50000, 24, 'Yol tutuşu ve fren mesafesi için önemlidir.');
