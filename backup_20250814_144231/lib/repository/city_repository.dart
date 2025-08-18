import '../services/city/city_service.dart';

class CityRepository {
  final CityService _service = CityService();

  Future<List<String>> getCities() async {
    return await _service.fetchAllCities();
  }
}
