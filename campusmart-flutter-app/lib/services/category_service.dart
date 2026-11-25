import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  CategoryService(this._api);

  final ApiClient _api;

  /// GET /categories
  Future<List<Category>> list() async {
    final data = await _api.get('/categories') as List<dynamic>;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }
}
