import '../models/event.dart';

List<Event> filterEventsThisWeek(List<Event> events) {
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));

  return events.where((event) {
    return event.date.isAfter(now) && event.date.isBefore(nextWeek);
  }).toList();
}
