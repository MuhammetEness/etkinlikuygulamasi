import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/category.dart';

class CategoryService {
  static const String _baseUrl = 'https://backend.etkinlik.io/api/v2';
  static const String _apiKey = '5613922e0344b203b56313ebae6c1e62';

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
        'X-Etkinlik-Token': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Kategoriler alınamadı (${response.statusCode})');
    }
  }
}
