# 🚗 Lube - Akıllı Araba Bakım Takip Sistemi

Lube, araç sahiplerinin periyodik bakımlarını, mekanik kontrollerini ve yasal yükümlülüklerini (muayene, sigorta vb.) tek bir noktadan yönetmelerini sağlayan, akıllı uyarı mekanizmalarına sahip bir takip sistemidir.

---

## 🌟 Öne Çıkan Özellikler

### 📱 Mobil Uygulama (Frontend - Flutter)
- **Kapsamlı Araç Profili:** Marka, model, yıl, plaka, şase numarası, motor ve şanzıman tipi detaylarıyla araç yönetimi.
- **Akıllı Kilometre Takibi:** Aylık ortalama kullanım hesaplama ve gelecek bakım tarihlerini tahminleme.
- **Geniş Bakım Yelpazesi:** 
  - Sıvılar (Motor yağı, antifriz, fren hidroliği vb.)
  - Filtreler (Hava, polen, mazot vb.)
  - Mekanik/Ağır Bakımlar (Triger seti, baskı balata, fren diskleri vb.)
  - Yürüyen Aksam (Rot-balans, lastik rotasyonu vb.)
- **Yasal Takip Modülü:** Trafik sigortası, Kasko, Muayene (Vize), Egzoz emisyon ve MTV ödeme dönemleri için hatırlatıcılar.
- **Dashboard:** Bakımların kritiklik seviyesine göre (renk kodlu) görselleştirilmesi.
- **Uzman İpuçları:** Bakım esnasında dikkat edilmesi gereken teknik detaylar (Örn: "Triger değişirken devirdaim pompası da kontrol edilmelidir").

### ⚙️ Sunucu ve API (Backend - Node.js)
- **Güvenli Kimlik Doğrulama:** JWT tabanlı kullanıcı kayıt ve giriş sistemi.
- **Gelişmiş Veri Yapısı:** MariaDB üzerinde optimize edilmiş kullanıcı, araç ve bakım logları tabloları.
- **Akıllı İş Mantığı:** Mevcut KM ve son servis verilerini karşılaştırarak "Kalan KM" hesaplayan algoritmalar.
- **RESTful Endpoints:**
  - `POST /api/auth/register` & `login`
  - `GET/POST/PUT/DELETE /api/vehicles`
  - `GET /api/maintenance/definitions`
  - `GET/POST /api/maintenance/logs`

---

## 🛠️ Teknoloji Yığını

- **Frontend:** Flutter & Dart
- **Backend:** Node.js, Express.js
- **Veritabanı:** MariaDB / MySQL
- **Araçlar:** `express-validator`, `dotenv`, `cors`, `mysql2`, `nodemon`

---

## 🚀 Kurulum ve Çalıştırma

### 1. Veritabanı Hazırlığı
- `Backend/database/schema.sql` dosyasını MariaDB sunucunuzda çalıştırarak gerekli tabloları (`users`, `vehicles`, `maintenance_definitions`, `maintenance_logs`) oluşturun.

### 2. Backend Kurulumu
```bash
cd Backend
npm install
# .env dosyasını oluşturun (DB_HOST, DB_USER, DB_PASS, DB_NAME, PORT)
npm run dev
```

### 3. Frontend Kurulumu
```bash
cd Frontend
flutter pub get
flutter run
```

---

## 📁 Proje Klasör Yapısı

```text
Lube/
├── Backend/                # API ve Sunucu Tarafı
│   ├── src/
│   │   ├── config/         # Veritabanı havuzu ve ayarlar
│   │   ├── controllers/    # İstek işleme ve logic
│   │   ├── models/         # DB sorguları
│   │   └── routes/         # API uç noktaları
│   └── database/           # SQL şemaları
├── Frontend/               # Mobil Uygulama Tarafı
│   ├── lib/                # Ekranlar ve modeller
│   └── android/ios/etc.    # Platform spesifik dosyalar
└── README.md
```

---

## 📅 Gelecek Planları (Roadmap)
- [ ] Yakıt gider analizi ve grafikler.


---

## 📄 Lisans
Bu proje [ISC](LICENSE) lisansı altında geliştirilmektedir.
