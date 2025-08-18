import '../models/event.dart';

List<Event> filterEventsByCity(List<Event> events, String selectedCity) {
  if (selectedCity == 'Tümü' || selectedCity.isEmpty) return events;

  return events.where((event) {
    final cityName = event.venue?.city?.name ?? '';
    return cityName.toLowerCase() == selectedCity.toLowerCase();
  }).toList();
}
