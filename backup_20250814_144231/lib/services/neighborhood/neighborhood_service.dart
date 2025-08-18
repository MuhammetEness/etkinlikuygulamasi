import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NeighborhoodService {
  static const String _baseUrl = 'https://backend.etkinlik.io/api/v2';
  static const String _apiKey = '5613922e0344b203b56313ebae6c1e62';

  Future<List<String>> fetchNeighborhoodsByDistrict(String districtName) async {
    try {
      debugPrint("=== SEMT YÜKLEME BAŞLADI ===");
      debugPrint("Aranan ilçe: $districtName");
      
      // İlçe ismini normalize et (büyük/küçük harf, boşluk vs.)
      final normalizedDistrictName = districtName.trim();
      debugPrint("Normalize edilmiş ilçe: $normalizedDistrictName");
      
      // Tüm şehirleri al ve içinde ilçe arayıp ID'sini bul, sonra semtleri çek
      final citiesUrl = '$_baseUrl/cities';
      debugPrint("Şehir API URL: $citiesUrl");
      final citiesResponse = await http.get(
        Uri.parse(citiesUrl),
        headers: {
          'Accept': 'application/json',
          'X-Etkinlik-Token': _apiKey,
        },
      );

      debugPrint("Şehir API yanıt kodu: ${citiesResponse.statusCode}");
      if (citiesResponse.statusCode == 200) {
        final cities = json.decode(citiesResponse.body);
        debugPrint("Şehir API yanıtı: $cities");
        
        if (cities is List && cities.isNotEmpty) {
          for (var city in cities) {
            final cityId = city['id'];
            final cityName = city['name']?.toString() ?? '';
            debugPrint("Şehir kontrol ediliyor: $cityName (ID: $cityId)");
            final districtsUrl = '$_baseUrl/cities/$cityId/districts';
            debugPrint("İlçe API URL: $districtsUrl");
            final districtsResponse = await http.get(
              Uri.parse(districtsUrl),
              headers: {
                'Accept': 'application/json',
                'X-Etkinlik-Token': _apiKey,
              },
            );
            if (districtsResponse.statusCode == 200) {
              final districts = json.decode(districtsResponse.body);
              if (districts is List && districts.isNotEmpty) {
                for (var district in districts) {
                  final districtNameFromAPI = district['name']?.toString() ?? '';
                  debugPrint("API'dan gelen ilçe: '$districtNameFromAPI' - Aranan: '$normalizedDistrictName'");
                  if (districtNameFromAPI.toLowerCase() == normalizedDistrictName.toLowerCase()) {
                    final int districtId = district['id'] is int
                        ? district['id'] as int
                        : int.tryParse(district['id'].toString()) ?? 0;
                    debugPrint("✅ İlçe bulundu: '$districtNameFromAPI' - ID: $districtId - Şehir: $cityName");
                    final neighborhoodUrl = '$_baseUrl/districts/$districtId/neighborhoods';
                    debugPrint("Semt API URL: $neighborhoodUrl");
                    final neighborhoodResponse = await http.get(
                      Uri.parse(neighborhoodUrl),
                      headers: {
                        'Accept': 'application/json',
                        'X-Etkinlik-Token': _apiKey,
                      },
                    );
                    debugPrint("Semt API yanıt kodu: ${neighborhoodResponse.statusCode}");
                    if (neighborhoodResponse.statusCode == 200) {
                      final decoded = json.decode(neighborhoodResponse.body);
                      if (decoded is List) {
                        final neighborhoods = decoded
                            .map((n) => n['name']?.toString() ?? "")
                            .where((name) => name.isNotEmpty)
                            .toList();
                        neighborhoods.sort();
                        debugPrint("✅ Dönen semtler: $neighborhoods");
                        debugPrint("✅ Semt sayısı: ${neighborhoods.length}");
                        return neighborhoods;
                      }
                    } else {
                      debugPrint("❌ Semt API hatası: ${neighborhoodResponse.statusCode} - ${neighborhoodResponse.body}");
                    }
                  }
                }
              }
            } else {
              debugPrint("❌ İlçe API hatası: ${districtsResponse.statusCode} - ${districtsResponse.body}");
            }
          }
          debugPrint("❌ İlçe hiçbir şehirde bulunamadı: $normalizedDistrictName");
        } else {
          debugPrint("❌ Şehir bulunamadı veya liste boş. Şehir listesi: $cities");
        }
      } else {
        debugPrint("❌ Şehir API hatası: ${citiesResponse.statusCode} - ${citiesResponse.body}");
      }
      return [];
    } catch (e) {
      debugPrint("❌ Semtler yüklenemedi: $e");
      return [];
    }
  }
}
