import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/event.dart';

class EventService {
  static const String _baseUrl = 'https://backend.etkinlik.io/api/v2';
  static const String _apiKey = '5613922e0344b203b56313ebae6c1e62';

  Future<List<Event>> fetchEvents({int take = 20, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events?take=$take&skip=$skip'),
      headers: {
        'Accept': 'application/json',
        'X-Etkinlik-Token': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List items = decoded['items'];
      return items.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Etkinlikler alınamadı (${response.statusCode})');
    }
  }

  Future<List<Event>> fetchEventsByCategory(String category, {int take = 20, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events?take=$take&skip=$skip&category=$category'),
      headers: {
        'Accept': 'application/json',
        'X-Etkinlik-Token': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List items = decoded['items'];
      return items.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Kategoriye göre etkinlikler alınamadı (${response.statusCode})');
    }
  }
}
