import '../models/venue.dart';
import '../services/venue/venue_service.dart';

class VenueRepository {
  final VenueService _service = VenueService();

  Future<List<Venue>> getVenues() async {
    return await _service.fetchVenues();
  }
}
