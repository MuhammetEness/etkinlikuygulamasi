import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart';
import '../utils/date_utils.dart';
import '../utils/html_cleaner.dart';
import '../utils/category_style_utils.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  /// Chrome garantili URL açıcı
  Future<void> _launchURL(String url) async {
    try {
      final Uri? uri = Uri.tryParse(Uri.encodeFull(url));

      if (uri == null) {
        debugPrint("❌ Geçersiz URL: $url");
        return;
      }

      // Chrome veya varsayılan tarayıcıda aç
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Chrome garantili
        );
      } else {
        debugPrint("❌ URL açılamadı: $url");
      }
    } catch (e) {
      debugPrint("❌ URL açılırken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = event.venue?.city?.name ?? '';
    final place = event.venue?.name ?? '';

    // Debug: Venue bilgilerini kontrol et
    debugPrint('🔍 Event Detail Debug:');
    debugPrint('   Venue: ${event.venue?.name}');
    debugPrint('   City: ${event.venue?.city?.name}');
    debugPrint('   Lat: ${event.venue?.lat}');
    debugPrint('   Lng: ${event.venue?.lng}');
    debugPrint('   Address: ${event.venue?.address}');

    // Kategori rengi
    final categoryStyle = getCategoryStyle(event.category?.name ?? '');
    final categoryColor = categoryStyle["color"] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: categoryColor,
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster - Gelişmiş önbellek sistemi
            if (event.posterUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: event.posterUrl,
                  cacheKey: 'event_detail_${event.id}_${event.posterUrl.hashCode}',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  memCacheHeight: 600,
                  maxWidthDiskCache: 1200,
                  maxHeightDiskCache: 800,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'Görsel yüklenemedi',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tarih
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Text(formatEventDate(event.date)),
                ],
              ),
            ),

            // Mekan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text('$place, $city')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Açıklama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                HtmlUtils.cleanHtml(event.description).isNotEmpty
                    ? HtmlUtils.cleanHtml(event.description)
                    : "Açıklama bulunmuyor.",
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),

            // Etkinlik Sayfasına Git ve Yol Tarifi Al butonları
            if (event.link.isNotEmpty)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _launchURL(event.link),
                      icon: const Icon(Icons.link),
                      label: const Text("Etkinlik Sayfasına Git"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                                             onPressed: () {
                         debugPrint('🔍 Yol Tarifi Butonu Tıklandı');
                         debugPrint('   Venue: ${event.venue?.name}');
                         debugPrint('   City: ${event.venue?.city?.name}');
                        
                        // Her zaman mekan adı ile arama yap (daha güncel sonuç için)
                        final venueName = event.venue?.name ?? '';
                        final cityName = event.venue?.city?.name ?? '';
                        final address = event.venue?.address ?? '';
                        
                        String searchQuery;
                                                 if (address.isNotEmpty) {
                           // Adres varsa adres + şehir kullan
                           searchQuery = '$address, $cityName';
                           debugPrint('📍 Adres ile arama yapılıyor: $searchQuery');
                         } else {
                           // Adres yoksa mekan adı + şehir kullan
                           searchQuery = '$venueName, $cityName';
                           debugPrint('📍 Mekan adı ile arama yapılıyor: $searchQuery');
                         }
                        
                        final mapsUrl = 'https://www.google.com/maps/search/$searchQuery';
                        _launchURL(mapsUrl);
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text("Yol Tarifi Al"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
