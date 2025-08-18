import '../models/event.dart';

List<Event> filterByCity(List<Event> events, String selectedCity) {
  if (selectedCity.isEmpty || selectedCity == 'Tümü') return events;
  return events.where((e) => (e.venue?.city?.name ?? '').toLowerCase() == selectedCity.toLowerCase()).toList();
}

List<Event> filterByCategory(List<Event> events, String selectedCategory) {
  if (selectedCategory.isEmpty || selectedCategory == 'Tümü') return events;
  return events.where((e) => (e.category?.name ?? '').toLowerCase() == selectedCategory.toLowerCase()).toList();
}

List<Event> filterThisWeek(List<Event> events) {
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  return events.where((e) => e.date.isAfter(now) && e.date.isBefore(nextWeek)).toList();
}

List<Event> filterByVenue(List<Event> events, String searchTerm) {
  if (searchTerm.isEmpty) return events;
  return events.where((e) => (e.venue?.name ?? '').toLowerCase().contains(searchTerm.toLowerCase())).toList();
}
