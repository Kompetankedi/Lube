# Araba Bakım Takip Uygulaması - Geliştirme Planı

## 1. Araç Tanımlama ve Profil Modülü
- [ ] **Araç Ekleme Ekranı:**
    - [ ] Marka (Örn: Volkswagen, Toyota)
    - [ ] Model (Örn: Golf, Corolla)
    - [ ] Model Yılı
    - [ ] Plaka
    - [ ] Şase Numarası (Opsiyonel - Parça uyumu için)
    - [ ] Motor Tipi (Benzin, Dizel, Hibrit, Elektrik)
    - [ ] Şanzıman Tipi (Manuel, Otomatik, DSG vb.)
- [ ] **Kilometre Takibi:**
    - [ ] Güncel Kilometre Girişi
    - [ ] Ortalama Aylık Kilometre Hesaplama (Tahminleme için)

## 2. Periyodik Bakım Kalemleri (Eklenecekler)
- [ ] **Sıvılar ve Filtreler:**
    - [ ] Motor Yağı ve Yağ Filtresi
    - [ ] Hava Filtresi
    - [ ] Polen Filtresi
    - [ ] Mazot / Yakıt Filtresi (Dizel araç uyarısı ile)
    - [ ] Antifriz / Soğutma Suyu
    - [ ] Fren Hidroliği
    - [ ] Şanzıman Yağı
- [ ] **Mekanik ve Ağır Bakım:**
    - [ ] Triger Kayışı / Seti (Devirdaim uyarısı eklenecek)
    - [ ] V Kayışı ve Gergisi
    - [ ] Eksantrik Zinciri
    - [ ] Fren Balataları ve Diskleri
    - [ ] Debriyaj Seti (Baskı Balata)
- [ ] **Yürüyen Aksam:**
    - [ ] Rot Ayarı / Balans Ayarı
    - [ ] Lastik Rotasyonu (Ön-Arka değişimi)
    - [ ] Amortisör Kontrolü

## 3. Yasal ve Resmi Takip Modülü
- [ ] **Tarih Bazlı Hatırlatıcılar:**
    - [ ] Trafik Sigortası Bitiş Tarihi
    - [ ] Kasko Bitiş Tarihi
    - [ ] Araç Muayene (Vize) Tarihi
    - [ ] Egzoz Emisyon Ölçüm Tarihi
    - [ ] MTV Ödeme Dönemleri (Ocak/Temmuz)

## 4. Teknik Altyapı (Backend & DB)
- [ ] **MariaDB Tablo Tasarımı:**
    - [ ] `vehicles` tablosu (Marka, model, yıl, km vb.)
    - [ ] `maintenance_types` tablosu (Bakım isimleri ve varsayılan periyotlar)
    - [ ] `user_logs` tablosu (Yapılan işlemlerin geçmişi)
- [ ] **Node.js API Geliştirme:**
    - [ ] CRUD operasyonları (Araç ekleme, bakım kaydetme, listeleme)
    - [ ] Güvenli bağlantı katmanı (JWT veya basit API Key)

## 5. Flutter Arayüz ve Özellikler
- [ ] **Dashboard:** Yaklaşan bakımların görselleştirilmesi (Kritiklik seviyesine göre renk kodları).
- [ ] **Akıllı Uyarı Sistemi:** Forumda bahsedilen "Triger değişirken devirdaim de değişmeli" gibi notların popup/ipucu olarak gösterilmesi.
- [ ] **Bildirim Sistemi:** Bakıma son 500 km veya 15 gün kala push notification.
- [ ] **Geçmiş (Log) Ekranı:** Aracın geçmişte yapılan tüm bakımlarının kronolojik listesi.

## 6. Gelecek Özellikler (V2)
- [ ] Yakıt gider takibi ve istatistikler.
- [ ] Servis fişi / fatura fotoğrafı yükleme alanı.
- [ ] Yakınlardaki yetkili/özel servis haritası.