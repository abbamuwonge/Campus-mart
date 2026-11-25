import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  OrderService(this._api);

  final ApiClient _api;

  /// POST /orders: a purchase request for an item.
  Future<Order> create(int itemId, {String? note}) async {
    final data = await _api.post('/orders', body: {
      'item_id': itemId,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return Order.fromJson(data as Map<String, dynamic>);
  }

  /// GET /orders/mine: requests I sent as a buyer.
  Future<List<Order>> mine() async => _list(await _api.get('/orders/mine'));

  /// GET /orders/received: requests other students sent for my items.
  Future<List<Order>> received() async => _list(await _api.get('/orders/received'));

  /// PATCH /orders/{id}/status. Buyer: cancelled. Seller: accepted, rejected or completed.
  Future<Order> setStatus(int id, String status) async {
    final data = await _api.patch('/orders/$id/status', body: {'status': status});
    return Order.fromJson(data as Map<String, dynamic>);
  }

  List<Order> _list(dynamic data) =>
      (data as List<dynamic>).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
}
