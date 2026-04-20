# Araba Bakım Takip Uygulaması - Geliştirme Planı

## 1. Araç Tanımlama ve Profil Modülü
- [x] **Araç Ekleme Ekranı:**
    - [x] Marka (Örn: Volkswagen, Toyota)
    - [x] Model (Örn: Golf, Corolla)
    - [x] Model Yılı
    - [x] Plaka
    - [x] Şase Numarası (Opsiyonel - Parça uyumu için)
    - [x] Motor Tipi (Benzin, Dizel, Hibrit, Elektrik)
    - [x] Şanzıman Tipi (Manuel, Otomatik, DSG vb.)
- [ ] **Kilometre Takibi:**
    - [x] Güncel Kilometre Girişi
    - [ ] Ortalama Aylık Kilometre Hesaplama (Tahminleme için)

## 2. Periyodik Bakım Kalemleri (Eklenecekler)
- [x] **Sıvılar ve Filtreler:**
    - [x] Motor Yağı ve Yağ Filtresi
    - [x] Hava Filtresi
    - [x] Polen Filtresi
    - [x] Mazot / Yakıt Filtresi (Dizel araç uyarısı ile)
    - [x] Antifriz / Soğutma Suyu
    - [x] Fren Hidroliği
    - [x] Şanzıman Yağı
- [x] **Mekanik ve Ağır Bakım:**
    - [x] Triger Kayışı / Seti (Devirdaim uyarısı eklenecek)
    - [x] V Kayışı ve Gergisi
    - [x] Eksantrik Zinciri
    - [x] Fren Balataları ve Diskleri
    - [x] Debriyaj Seti (Baskı Balata)
- [x] **Yürüyen Aksam:**
    - [x] Rot Ayarı / Balans Ayarı
    - [x] Lastik Rotasyonu (Ön-Arka değişimi)
    - [x] Amortisör Kontrolü

## 3. Yasal ve Resmi Takip Modülü
- [x] **Tarih Bazlı Hatırlatıcılar:**
    - [x] Trafik Sigortası Bitiş Tarihi
    - [x] Kasko Bitiş Tarihi
    - [x] Araç Muayene (Vize) Tarihi
    - [x] Egzoz Emisyon Ölçüm Tarihi
    - [x] MTV Ödeme Dönemleri (Ocak/Temmuz)

## 4. Teknik Altyapı (Backend & DB)
- [x] **MariaDB Tablo Tasarımı:**
    - [x] `vehicles` tablosu (Marka, model, yıl, km vb.)
    - [x] `maintenance_types` tablosu (Bakım isimleri ve varsayılan periyotlar)
    - [x] `user_logs` tablosu (Yapılan işlemlerin geçmişi)
- [x] **Node.js API Geliştirme:**
    - [x] CRUD operasyonları (Araç ekleme, bakım kaydetme, listeleme)
    - [x] Güvenli bağlantı katmanı (JWT veya basit API Key)

## 5. Flutter Arayüz ve Özellikler
- [x] **Dashboard:** Yaklaşan bakımların görselleştirilmesi (Kritiklik seviyesine göre renk kodları).
- [x] **Akıllı Uyarı Sistemi:** Forumda bahsedilen "Triger değişirken devirdaim de değişmeli" gibi notların popup/ipucu olarak gösterilmesi.
- [ ] **Bildirim Sistemi:** Bakıma son 500 km veya 15 gün kala push notification.
- [x] **Geçmiş (Log) Ekranı:** Aracın geçmişte yapılan tüm bakımlarının kronolojik listesi.

## 6. Gelecek Özellikler (V2)
- [ ] Yakıt gider takibi ve istatistikler.
- [ ] Servis fişi / fatura fotoğrafı yükleme alanı.
- [ ] Yakınlardaki yetkili/özel servis haritası.