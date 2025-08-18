import '../models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> extractCitiesFromEvents(List<Event> events) {
  final cities = <String>{};
  for (var event in events) {
    final cityName = event.venue?.city?.name ?? '';
    if (cityName.isNotEmpty) {
      cities.add(cityName);
    }
  }
  final sorted = cities.toList()..sort();
  sorted.insert(0, 'Tümü');
  return sorted;
}

Future<void> saveSelectedCity(String city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selected_city', city);
}

Future<String?> getSelectedCity() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selected_city');
}
