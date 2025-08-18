import '../models/event.dart';

List<Event> filterEventsByVenue(List<Event> events, String searchTerm) {
  if (searchTerm.isEmpty) return events;

  return events.where((event) {
    final venueName = event.venue?.name ?? '';
    return venueName.toLowerCase().contains(searchTerm.toLowerCase());
  }).toList();
}
