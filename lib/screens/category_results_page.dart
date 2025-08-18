import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/category_style_utils.dart';
import '../widgets/event_card.dart';

class CategoryResultsPage extends StatelessWidget {
  final String category;
  final List<Event> events;
  final Set<Event> favoriteEvents;
  final Function(Event) onToggleFavorite;

  const CategoryResultsPage({
    super.key,
    required this.category,
    required this.events,
    required this.favoriteEvents,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // CategoryGrid'deki gibi filtreleme yap
    final filteredEvents = events.where((event) {
      final eventCategory = getCategoryStyle(event.category?.name ?? '')["title"];
      return eventCategory == category;
    }).toList();
    
    debugPrint("CategoryResultsPage - Kategori: $category");
    debugPrint("CategoryResultsPage - Toplam event: ${events.length}");
    debugPrint("CategoryResultsPage - Filtrelenmiş event: ${filteredEvents.length}");
    
    final categoryStyle = getCategoryStyle(category);
    final categoryColor = categoryStyle["color"] as Color? ?? const Color(0xFF1C58F2);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(category),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: filteredEvents.isEmpty
          ? const Center(
              child: Text(
                'Bu kategoriye ait etkinlik bulunamadı.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: EventCard(
                    event: event,
                    isFavorite: favoriteEvents.contains(event),
                    onToggleFavorite: onToggleFavorite,
                  ),
                );
              },
            ),
    );
  }
}
