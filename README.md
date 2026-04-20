# 🚗 Lube - Akıllı Araba Bakım Takip Sistemi

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=for-the-badge)](https://opensource.org/licenses/ISC)

Lube, araç sahiplerinin periyodik bakımlarını, mekanik kontrollerini ve yasal yükümlülüklerini (muayene, sigorta vb.) tek bir noktadan yönetmelerini sağlayan, **Local-First** mimarisine sahip, modern ve kullanıcı dostu bir takip sistemidir.

---

## ✨ Öne Çıkan Özellikler

### 📱 Mobil Uygulama (Frontend - Flutter)
- **Neon Dark Tasarım:** Göz yormayan, premium hissettiren modern gece modu arayüzü.
- **Offline-First (SQLite):** İnternet olmasa dahi tüm verilerinizi yönetebilir, dilediğinizde sunucuya yedekleyebilirsiniz.
- **Akıllı Bakım Algoritması:** Mevcut kilometrenize göre hangi bakımın ne kadar ömrü kaldığını (Kritik/Normal/Güvenli) anlık hesaplar.
- **Gelişmiş Form Validasyonları:** Hatalı veri girişini (negatif KM, geçersiz e-posta vb.) engelleyen akıllı form kontrol sistemi.
- **Yedekleme ve Geri Yükleme:** Veritabanınızı tek tıkla dışa aktarabilir veya başka cihazdan geri yükleyebilirsiniz.

### ⚙️ Sunucu ve API (Backend - Node.js)
- **Güvenli Kimlik Doğrulama:** JWT (JSON Web Token) tabanlı oturum yönetimi.
- **Performans Odaklı Sorgular:** Optimize edilmiş SQL JOIN yapıları ile minimum gecikme süresi.
- **Validasyon Katmanı:** `express-validator` ile sunucu tarafında tam veri güvenliği.

---

## 🛠️ Teknoloji Yığını

| Alan | Teknoloji | Kullanım Amacı |
| :--- | :--- | :--- |
| **Frontend** | Flutter & Dart | Çapraz platform mobil uygulama |
| **Backend** | Node.js & Express | RESTful API Hizmeti |
| **Yerel Veritabanı** | SQLite (sqflite) | Cihaz üzerinde hızlı veri saklama |
| **Sunucu Veritabanı** | MySQL / MariaDB | Bulut tabanlı yedekleme ve senkronizasyon |
| **Tema** | Custom Neon Dark | Premium kullanıcı deneyimi |

---

## 🚀 Kurulum ve Çalıştırma

### 1. Ön Gereksinimler
- Flutter SDK (>= 3.0.0)
- Node.js (>= 16.0.0)
- MySQL veya MariaDB Sunucusu

### 2. Backend Kurulumu
```bash
cd Backend
npm install
```
`.env` dosyasını oluşturun ve aşağıdaki bilgileri doldurun:
```env
DB_HOST=localhost
DB_USER=root
DB_PASS=şifreniz
DB_NAME=lube_db
PORT=3000
JWT_SECRET=özel_anahtarınız
```
Ardından sunucuyu başlatın:
```bash
npm run dev
```

### 3. Frontend Kurulumu
```bash
cd Frontend
flutter pub get
# Geliştirme modunda başlatmak için:
flutter run
```

---

## 📊 Veri Doğrulama ve Güvenlik

Uygulama genelinde uygulanan kritik validasyonlar:
- **KM Kontrolü:** Araç kilometresi asla geriye doğru güncellenemez.
- **Bakım Uyarıları:** Kritik seviyeye (0 KM altı) düşen bakımlar Dashboard üzerinde kırmızı renkle vurgulanır.
- **Form Koruması:** Geçersiz model yılları (örn: 2050) veya hatalı e-posta formatları kaydedilmeden önce kullanıcıyı uyarır.

---

## 📁 Proje Klasör Yapısı

```text
Lube/
├── Backend/                # API ve Sunucu Tarafı
│   ├── src/
│   │   ├── config/         # Veritabanı bağlantı havuzu
│   │   ├── controllers/    # Business logic (İş mantığı)
│   │   ├── models/         # SQL sorgu şablonları
│   │   └── routes/         # API Endpoint tanımları
│   └── database/           # Veritabanı şema ve seed dosyaları
├── Frontend/               # Mobil Uygulama (Flutter)
│   ├── lib/
│   │   ├── screens/        # UI Sayfaları (Dashboard, Login, vb.)
│   │   ├── services/       # API ve Local DB servisleri
│   │   └── widgets/        # Tekrar kullanılabilir UI bileşenleri
│   └── assets/             # Görseller ve fontlar
└── README.md
```

---

## 📅 Yol Haritası (Roadmap)
- [x] SQLite Entegrasyonu ve Offline Mod.
- [x] Neon Dark Tema Uygulaması.
- [x] Veritabanı Yedekleme/Geri Yükleme.
- [ ] 📈 Yakıt Gider Analizi ve Grafiklendirme.
- [ ] 🔔 Push Bildirimleri (Bakım zamanı hatırlatıcısı).
- [ ] 🛠️ Tamirhane/Servis Rehberi Entegrasyonu.

---

## 📄 Lisans
Bu proje [ISC](LICENSE) lisansı altında geliştirilmektedir. Tüm hakları saklıdır.
