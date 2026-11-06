import 'category.dart';

/// Condition labels exactly as the prototype's "Condition" list, in the same order.
const List<String> kConditionOptions = ['Used - Good', 'Like new', 'New', 'Used - Fair'];

const Map<String, String> _apiToLabel = {
  'used good': 'Used - Good',
  'like new': 'Like new',
  'new': 'New',
  'used fair': 'Used - Fair',
};

String conditionToApi(String label) {
  for (final entry in _apiToLabel.entries) {
    if (entry.value == label) return entry.key;
  }
  return 'used good';
}

class Item {
  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.conditionApi,
    required this.status,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.sellerCampus,
    this.pickupLocation,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String description;
  final int price;
  final String conditionApi;
  final String status;
  final Category category;
  final int sellerId;
  final String sellerName;
  final String sellerCampus;
  final String? pickupLocation;
  final String? imageUrl;

  String get conditionLabel => _apiToLabel[conditionApi] ?? conditionApi;

  factory Item.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>;
    return Item(
      id: json['item_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      conditionApi: json['item_condition'] as String,
      status: json['status'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      sellerId: seller['user_id'] as int,
      sellerName: seller['full_name'] as String,
      sellerCampus: seller['campus'] as String,
      pickupLocation: json['pickup_location'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
