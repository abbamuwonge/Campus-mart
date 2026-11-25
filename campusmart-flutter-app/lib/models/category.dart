class Category {
  const Category({required this.id, required this.name, required this.icon});

  final int id;
  final String name;
  final String icon; // emoji shown on items of this category

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'] as int,
      name: json['name'] as String,
      icon: (json['icon'] as String?) ?? '📦',
    );
  }
}
