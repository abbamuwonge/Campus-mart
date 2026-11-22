import '../models/item.dart';
import 'api_client.dart';

class FavoriteService {
  FavoriteService(this._api);

  final ApiClient _api;

  /// GET /favorites
  Future<List<Item>> list() async {
    final data = await _api.get('/favorites') as List<dynamic>;
    return data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /favorites
  Future<void> add(int itemId) async {
    await _api.post('/favorites', body: {'item_id': itemId});
  }

  /// DELETE /favorites/{item_id}
  Future<void> remove(int itemId) async {
    await _api.delete('/favorites/$itemId');
  }
}
