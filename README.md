# Eventera: Full-Stack Etkinlik Keşif ve Sosyal Ağ Platformu

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Proje Hakkında
Eventera, kullanıcıların kültürel ve sanatsal etkinlikleri keşfetmesini sağlayan ve geleneksel e-ticaret (biletleme) yaklaşımını yıkarak kullanıcıları bir araya getiren **gerçek zamanlı bir etkinlik tabanlı sosyal ağ (EBSN)** platformudur. Uygulama, sadece bir etkinlik listeleme aracı değil; kullanıcıların etkileşime girdiği, mesajlaştığı ve ortak ilgi alanlarında buluştuğu kapsamlı bir mimaridir.

## Temel Özellikler
- **Bağlam-Duyarlı Keşif:** Dış REST API'lerden asenkron HTTP istekleriyle çekilen verilerin şehir ve kategori bazlı (Tiyatro, Müzik, Sinema vb.) milisaniyeler içinde filtrelenmesi.
- **Gerçek Zamanlı Mesajlaşma (Chat):** Firebase Cloud Firestore ve `StreamBuilder` altyapısı kullanılarak eşler arası (peer-to-peer) sıfır gecikmeli sohbet modülü.
- **Sosyal Akış (Feed):** Kullanıcıların takip ettikleri profillerin etkileşimlerini (beğeni, favoriye alma, etkinlik oluşturma) kronolojik olarak listeleyen özel veri madenciliği algoritması.
- **Performans Optimizasyonu:** Yüzlerce etkinliğin cihaz belleğini yormadan akıcı listelenmesi için Lazy Loading (Tembel Yükleme) ve `cached_network_image` önbellekleme mimarisi.
- **Topluluk Etkinlikleri:** Sistem üyelerinin "Keşfet" ekranı üzerinden kendi bağımsız buluşmalarını yaratıp yayınlayabilmesi.

## Mimari ve Teknolojiler
- **Frontend Katmanı:** Flutter SDK, Dart (Nesne Yönelimli Programlama)
- **Backend & Veritabanı:** Serverless Mimari, Google Firebase (Authentication, Cloud Firestore - NoSQL)
- **State Management & Network:** FutureBuilder, StreamBuilder, asenkron HTTP yönetimi (Timeout, Try/Catch mekanizmaları)
- **Veri Modelleme:** API'den dönen karmaşık JSON hiyerarşisinin Dart sınıflarına (Data Classes) ayrıştırılması (Parsing).

## Ekran Görüntüleri
*(Not: Buraya uygulamanın ana sayfası, chat ekranı ve profil ekranından 3-4 adet ekran görüntüsü eklenecektir.)*
