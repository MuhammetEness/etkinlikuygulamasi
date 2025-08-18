import '../models/event.dart';
import '../services/event/event_service.dart';

class EventRepository {
  final EventService _service = EventService();

  Future<List<Event>> getEvents() async {
    return await _service.fetchEvents();
  }
}
