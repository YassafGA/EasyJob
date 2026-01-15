# EasyJob – Mobil Tabanlı İş Arama ve CV Oluşturma Platformu

EasyJob, iş arama ve CV (özgeçmiş) oluşturma süreçlerini tek bir mobil platform altında birleştiren, iOS tabanlı bir mobil uygulamadır.  
Bu proje, Manisa Celal Bayar Üniversitesi Yazılım Mühendisliği Bölümü Lisans Bitirme Tezi kapsamında geliştirilmiştir.

---

## 📌 Proje Amacı

Günümüzde iş arama, başvuru yapma ve CV oluşturma süreçleri genellikle farklı platformlar üzerinden yürütülmektedir. Bu durum kullanıcı deneyimini olumsuz etkilemektedir.

EasyJob’un amacı:
- İş arama ve başvuru süreçlerini tek bir mobil uygulamada toplamak
- CV oluşturmayı **modüler, güncellenebilir ve dinamik** hale getirmek
- İş arayanlar ve işverenler arasında hızlı ve güvenli bir etkileşim sağlamak

---

## 🚀 Temel Özellikler

### 👤 İş Arayan Kullanıcılar
- İş ilanlarını görüntüleme
- İlanlara tek tıkla başvuru yapma
- Mobil ortamda CV oluşturma ve düzenleme
- Tek CV ile çoklu iş başvurusu yapabilme

### 🏢 İşveren Kullanıcılar
- İş ilanı yayınlama
- Başvuruları görüntüleme
- Aday CV’lerini standart formatta inceleme

### 📄 CV Oluşturma Mekanizması
- Modüler yapı:
  - Kişisel bilgiler
  - Eğitim bilgileri
  - İş deneyimleri
  - Yetenekler
- Dinamik ve güncellenebilir CV
- CV verilerinin başvurularda otomatik kullanımı

---

## 🧱 Sistem Mimarisi

EasyJob, **istemci–sunucu (client–server)** mimarisi ile geliştirilmiştir.

- **Frontend:**  
  - iOS
  - Swift & SwiftUI

- **Backend:**  
  - Supabase
    - Authentication (Kimlik Doğrulama)
    - PostgreSQL tabanlı veritabanı
    - Yetkilendirme ve veri erişim kontrolü

---

## 🛠️ Kullanılan Teknolojiler

- Swift
- SwiftUI
- Supabase
- PostgreSQL
- REST tabanlı veri erişimi

---

## 🗄️ Veritabanı Yapısı (Özet)

- Users
- CVs
- Educations
- Experiences
- Skills
- JobPosts
- Applications

Veritabanı, CV oluşturma ve iş başvuru süreçlerini destekleyecek şekilde ilişkisel olarak tasarlanmıştır.

---

## 📱 Platform Desteği

- ✅ iOS
- ❌ Android (gelecek çalışmalarda planlanmaktadır)

---

## 🔮 Gelecek Çalışmalar

- CV tasarım şablonlarının çeşitlendirilmesi
- Kullanıcı yetkinliklerine göre iş ilanı öneri sistemi
- Android platformu için uygulama geliştirilmesi
- İşverenler için gelişmiş aday analiz araçları

---

## 🎓 Akademik Bilgi

- **Proje Türü:** Lisans Bitirme Tezi  
- **Bölüm:** Yazılım Mühendisliği  
- **Üniversite:** Manisa Celal Bayar Üniversitesi  
- **Danışman:** Prof. Dr. Akın ÖZÇİFT  
- **Öğrenci:** Yusuf SUKARİ  

---

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.
