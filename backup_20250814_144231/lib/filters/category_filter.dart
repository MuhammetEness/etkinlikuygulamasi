import '../models/event.dart';

List<Event> filterEventsByCategory(List<Event> events, String selectedCategory) {
  if (selectedCategory == 'Tümü' || selectedCategory.isEmpty) return events;

  return events.where((event) {
    final categoryName = event.category?.name ?? '';
    return categoryName.toLowerCase() == selectedCategory.toLowerCase();
  }).toList();
}
