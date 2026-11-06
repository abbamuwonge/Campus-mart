class Order {
  const Order({
    required this.id,
    required this.status,
    required this.priceAtOrder,
    required this.itemId,
    required this.itemTitle,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    this.note,
  });

  final int id;
  final String status; // pending, accepted, rejected, cancelled, completed
  final int priceAtOrder;
  final int itemId;
  final String itemTitle;
  final int buyerId;
  final String buyerName;
  final int sellerId;
  final String sellerName;
  final String? note;

  factory Order.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;
    final buyer = json['buyer'] as Map<String, dynamic>;
    final seller = json['seller'] as Map<String, dynamic>;
    return Order(
      id: json['order_id'] as int,
      status: json['status'] as String,
      priceAtOrder: (json['price_at_order'] as num).toInt(),
      note: json['note'] as String?,
      itemId: item['item_id'] as int,
      itemTitle: item['title'] as String,
      buyerId: buyer['user_id'] as int,
      buyerName: buyer['full_name'] as String,
      sellerId: seller['user_id'] as int,
      sellerName: seller['full_name'] as String,
    );
  }
}
