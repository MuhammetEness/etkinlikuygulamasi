import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CityService {
  static const String _baseUrl = 'https://backend.etkinlik.io/api/v2';
  static const String _apiKey = '5613922e0344b203b56313ebae6c1e62';

  Future<List<String>> fetchAllCities() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cities?take=100'),
        headers: {
          'Accept': 'application/json',
          'X-Etkinlik-Token': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is! List) {
          throw Exception("API formatı beklenenden farklı: $decoded");
        }

        final cities = decoded
            .map((c) => c['name']?.toString() ?? "")
            .where((name) => name.isNotEmpty)
            .toList();

        cities.sort();
        return cities;
      } else {
        throw Exception('Şehirler alınamadı (${response.statusCode})');
      }
    } catch (e) {
    debugPrint("Şehirler yüklenemedi: $e");
      rethrow;
    }
  }
}
