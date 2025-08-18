import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/category_style_utils.dart';
import '../screens/category_results_page.dart';

class CategoryGrid extends StatelessWidget {
  final List<Event> events;
  final Set<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;
  final String? selectedCity;

  const CategoryGrid({
    super.key,
    required this.events,
    required this.favoriteEvents,
    required this.onToggleFavorite,
    required this.selectedCity,
  });

  /// Sabit 9 kategori - her zaman gösterilecek
  static const List<String> fixedCategories = [
    "Müzik",
    "Tiyatro",
    "Sinema",
    "Spor",
    "Sanat",
    "Eğitim",
    "Çocuk",
    "Açık Hava",
    "Diğer"
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 36),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.96,
        ),
        itemCount: fixedCategories.length,
        itemBuilder: (ctx, i) {
          final cat = fixedCategories[i];
          final style = getCategoryStyle(cat);
          final imagePath = style["image"] as String;

          return GestureDetector(
            onTap: () async {
              // HomePage'deki gibi filtreleme yap
              try {
                List<Event> categoryEvents;
                
                // Seçili şehre göre kategori verilerini filtrele
                if (selectedCity != null && selectedCity != "Tümü") {
                debugPrint("🎯 Kategori tıklandı - Seçili şehir: $selectedCity, Kategori: $cat");
                  categoryEvents = events.where((event) {
                    final eventCity = event.venue?.city?.name ?? '';
                    final eventCategory = getCategoryStyle(event.category?.name ?? '')["title"];
                    final matches = eventCity == selectedCity && eventCategory == cat;
                    if (matches) {
                      debugPrint("✅ Eşleşen etkinlik: ${event.title} - Şehir: $eventCity, Kategori: $eventCategory");
                    }
                    return matches;
                  }).toList();
                debugPrint("🎯 Bulunan etkinlik sayısı: ${categoryEvents.length}");
                } else {
                  // Şehir seçili değilse, sadece kategoriye göre filtrele
                debugPrint("🎯 Kategori tıklandı - Şehir seçili değil, Kategori: $cat");
                  categoryEvents = events.where((event) {
                    final eventCategory = getCategoryStyle(event.category?.name ?? '')["title"];
                    final matches = eventCategory == cat;
                    if (matches) {
                      debugPrint("✅ Eşleşen etkinlik: ${event.title} - Kategori: $eventCategory");
                    }
                    return matches;
                  }).toList();
                debugPrint("🎯 Bulunan etkinlik sayısı: ${categoryEvents.length}");
                }
                
              debugPrint("🎯 Kategori: $cat, Toplam etkinlik: ${categoryEvents.length}");
                
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryResultsPage(
                        events: categoryEvents,
                        favoriteEvents: favoriteEvents,
                        onToggleFavorite: onToggleFavorite,
                        category: cat,
                      ),
                    ),
                  );
                }
              } catch (e) {
              debugPrint("❌ Kategori filtreleme hatası: $e");
                // Hata durumunda boş liste göster
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryResultsPage(
                        events: [],
                        favoriteEvents: favoriteEvents,
                        onToggleFavorite: onToggleFavorite,
                        category: cat,
                      ),
                    ),
                  );
                }
              }
            },
            child: Stack(
              children: [
                // Arka plan görseli
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Siyah overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Ortada kategori ismi
                Center(
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 