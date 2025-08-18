import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DistrictService {
  static const String _baseUrl = 'https://backend.etkinlik.io/api/v2';
  static const String _apiKey = '5613922e0344b203b56313ebae6c1e62';

  Future<List<String>> fetchDistrictsByCity(String cityName) async {
    try {
      debugPrint("=== İLÇE YÜKLEME BAŞLADI ===");
      debugPrint("Aranan şehir: $cityName");
      
      // Şehir ismini normalize et (büyük/küçük harf, boşluk vs.)
      final normalizedCityName = cityName.trim();
      debugPrint("Normalize edilmiş şehir: $normalizedCityName");
      
      // Tüm şehirleri al
      final cityUrl = '$_baseUrl/cities';
      debugPrint("Şehir API URL: $cityUrl");
      
      final cityResponse = await http.get(
        Uri.parse(cityUrl),
        headers: {
          'Accept': 'application/json',
          'X-Etkinlik-Token': _apiKey,
        },
      );

      debugPrint("Şehir API yanıt kodu: ${cityResponse.statusCode}");
      if (cityResponse.statusCode == 200) {
        final cities = json.decode(cityResponse.body);
        debugPrint("Şehir API yanıtı: $cities");
        
        if (cities is List && cities.isNotEmpty) {
          // Tam eşleşme ara
          int? cityId;
          String foundCity = '';
          
          debugPrint("=== ŞEHİR EŞLEŞME KONTROLÜ ===");
          for (var city in cities) {
            final cityNameFromAPI = city['name']?.toString() ?? '';
            debugPrint("API'dan gelen şehir: '$cityNameFromAPI' - Aranan: '$normalizedCityName'");
            
            if (cityNameFromAPI == normalizedCityName) {
              cityId = city['id'];
              foundCity = cityNameFromAPI;
              debugPrint("✅ Tam eşleşme bulundu: '$cityNameFromAPI' - ID: $cityId");
              break;
            }
          }
          
          if (cityId == null) {
            // Tam eşleşme bulunamadıysa, büyük/küçük harf eşleşmesi ara
            debugPrint("❌ Tam eşleşme bulunamadı, büyük/küçük harf kontrolü yapılıyor...");
            for (var city in cities) {
              final cityNameFromAPI = city['name']?.toString() ?? '';
              if (cityNameFromAPI.toLowerCase() == normalizedCityName.toLowerCase()) {
                cityId = city['id'];
                foundCity = cityNameFromAPI;
                debugPrint("✅ Büyük/küçük harf eşleşmesi bulundu: '$cityNameFromAPI' - ID: $cityId");
                break;
              }
            }
          }
          
          if (cityId == null) {
            // Hâlâ bulunamadıysa, tüm şehirleri listele ve ilkini al
            debugPrint("❌ Eşleşme bulunamadı, tüm şehirler listeleniyor...");
            for (var city in cities) {
              final cityNameFromAPI = city['name']?.toString() ?? '';
              debugPrint("Mevcut şehir: '$cityNameFromAPI' - ID: ${city['id']}");
            }
            
            cityId = cities.first['id'];
            foundCity = cities.first['name']?.toString() ?? '';
            debugPrint("⚠️ Eşleşme bulunamadı, ilk şehir kullanılıyor: '$foundCity' - ID: $cityId");
          }
          
          debugPrint("🎯 Kullanılacak şehir: '$foundCity' - ID: $cityId");
          
          // Doğru API URL'i kullan: /cities/:id/districts
          final districtUrl = '$_baseUrl/cities/$cityId/districts';
          debugPrint("İlçe API URL: $districtUrl");
          
          final districtResponse = await http.get(
            Uri.parse(districtUrl),
            headers: {
              'Accept': 'application/json',
              'X-Etkinlik-Token': _apiKey,
            },
          );

      debugPrint("İlçe API yanıt kodu: ${districtResponse.statusCode}");
          if (districtResponse.statusCode == 200) {
            final decoded = json.decode(districtResponse.body);
            debugPrint("İlçe API yanıtı: $decoded");
            
            if (decoded is List) {
              final districts = decoded
                  .map((d) => d['name']?.toString() ?? "")
                  .where((name) => name.isNotEmpty)
                  .toList();
              districts.sort();
              debugPrint("✅ Dönen ilçeler: $districts");
              debugPrint("✅ İlçe sayısı: ${districts.length}");
              return districts;
            } else {
              debugPrint("❌ İlçe API yanıtı liste değil: $decoded");
            }
          } else {
            debugPrint("❌ İlçe API hatası: ${districtResponse.statusCode} - ${districtResponse.body}");
          }
        } else {
          debugPrint("❌ Şehir bulunamadı veya liste boş. Şehir listesi: $cities");
        }
      } else {
        debugPrint("❌ Şehir API hatası: ${cityResponse.statusCode} - ${cityResponse.body}");
      }
      return [];
    } catch (e) {
      debugPrint("❌ İlçeler yüklenemedi: $e");
      return [];
    }
  }
}
