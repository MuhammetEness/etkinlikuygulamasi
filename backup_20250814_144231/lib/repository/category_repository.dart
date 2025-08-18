import '../models/category.dart';
import '../services/category/category_service.dart';

class CategoryRepository {
  final CategoryService _service = CategoryService();

  Future<List<Category>> getCategories() async {
    return await _service.fetchCategories();
  }
}
