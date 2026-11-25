import '../models/item.dart';
import 'api_client.dart';

class ItemService {
  ItemService(this._api);

  final ApiClient _api;

  /// GET /items. The backend returns 20 items per page, newest first.
  Future<List<Item>> list({String? query, int? categoryId, int page = 1}) async {
    final params = <String, String>{'page': '$page'};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (categoryId != null) params['category_id'] = '$categoryId';
    final data = await _api.get('/items?${Uri(queryParameters: params).query}') as List<dynamic>;
    return _items(data);
  }

  /// GET /users/me/items: all my listings, whatever their status.
  Future<List<Item>> mine() async {
    final data = await _api.get('/users/me/items') as List<dynamic>;
    return _items(data);
  }

  /// POST /items
  Future<Item> create({
    required int categoryId,
    required String title,
    required String description,
    required int price,
    required String condition,
    String? pickupLocation,
  }) async {
    final data = await _api.post('/items', body: _body(categoryId, title, description, price, condition, pickupLocation));
    return Item.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /items/{id}
  Future<Item> update(
    int id, {
    required int categoryId,
    required String title,
    required String description,
    required int price,
    required String condition,
    String? pickupLocation,
  }) async {
    final data = await _api.put('/items/$id', body: _body(categoryId, title, description, price, condition, pickupLocation));
    return Item.fromJson(data as Map<String, dynamic>);
  }

  /// PATCH /items/{id}/status with available, reserved or sold.
  Future<Item> setStatus(int id, String status) async {
    final data = await _api.patch('/items/$id/status', body: {'status': status});
    return Item.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE /items/{id}
  Future<void> delete(int id) async {
    await _api.delete('/items/$id');
  }

  /// POST /items/{id}/image
  Future<Item> uploadImage(int id, String filePath) async {
    final data = await _api.upload('/items/$id/image', filePath);
    return Item.fromJson(data as Map<String, dynamic>);
  }

  List<Item> _items(List<dynamic> data) =>
      data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> _body(int categoryId, String title, String description, int price, String condition, String? pickupLocation) {
    return {
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'item_condition': condition,
      if (pickupLocation != null && pickupLocation.isNotEmpty) 'pickup_location': pickupLocation,
    };
  }
}
