# Araba Bakım Uygulaması - Backend (API) Geliştirme Planı

## 1. Hazırlık ve Ortam Kurulumu
- [x] **Proje Başlatma:** `npm init` ile projenin oluşturulması.
- [x] **Bağımlılıkların Kurulması:**
    - [x] `express` (Sunucu çatısı)
    - [x] `mysql2` (MariaDB bağlantısı için)
    - [x] `dotenv` (Gizli bilgileri saklamak için)
    - [x] `cors` (Flutter erişimine izin vermek için)
    - [x] `nodemon` (Geliştirme hızlandırma)
- [x] **Klasör Yapısı:** `src/controllers`, `src/routes`, `src/config`, `src/models` yapısının kurulması.

## 2. Veritabanı (MariaDB) Tasarımı
- [x] **Veritabanı Oluşturma:** `car_care_db` oluşturulması.
- [x] **Tabloların Yazılması:**
    - [x] `users`: id, email, password, name, created_at.
    - [x] `vehicles`: id, user_id, brand, model, year, plate, current_km, fuel_type.
    - [x] `maintenance_definitions`: id, name, km_interval, month_interval, warning_note (Forumdaki özel notlar buraya).
    - [x] `maintenance_logs`: id, vehicle_id, definition_id, service_date, service_km, price, notes.

## 3. API Endpoint'lerinin Yazılması (RESTful)
- [x] **Auth (Giriş/Kayıt):**
    - [x] `POST /api/auth/register`
    - [x] `POST /api/auth/login`
- [x] **Araç Yönetimi:**
    - [x] `GET /api/vehicles` (Kullanıcının araçlarını getir)
    - [x] `POST /api/vehicles` (Yeni araç ekle)
    - [x] `PUT /api/vehicles/:id` (KM güncelleme veya düzenleme)
    - [x] `DELETE /api/vehicles/:id` (Aracı sil)
- [x] **Bakım İşlemleri:**
    - [x] `GET /api/maintenance/definitions` (Tanımlı bakım listesini çek - Örn: Triger, Yağ vb.)
    - [x] `POST /api/maintenance/logs` (Yapılan bakımı kaydet)
    - [x] `GET /api/maintenance/logs/:vehicle_id` (Aracın bakım geçmişini getir)

## 4. İş Mantığı (Business Logic) ve Hesaplamalar
- [x] **Bakım Durumu Hesaplama:** Mevcut KM ve son bakım KM'sini karşılaştırıp "Kalan KM" döndüren bir logic oluşturulması.
- [x] **Akıllı Not Sistemi:** Bakım tanımı çekilirken ilgili `warning_note` verisinin (Pesimist Hoca'nın önerileri) JSON'a dahil edilmesi.

## 5. Güvenlik ve Yayına Hazırlık
- [x] **Hata Yönetimi:** Try-catch blokları ve standart hata mesajları.
- [x] **Giriş Doğrulama:** `express-validator` ile gelen verilerin kontrolü.
- [x] **CORS Ayarları:** Flutter uygulamasının IP adresine/portuna izin verilmesi.
- [x] **Bağlantı Havuzu (Connection Pool):** MariaDB bağlantısının performanslı çalışması için pool yapısının kurulması.

## 6. Test
- [x] **Postman/Thunder Client / Admin Dashboard:** Tüm endpoint'lerin test edilmesi ve JSON çıktıların doğrulanması.