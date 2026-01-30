class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? salePrice;
  final List<String> images;
  final int stockLevel; // 0 = Out of stock
  final String status;  // 'in_stock', 'limited', 'sold_out'

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.salePrice,
    required this.images,
    required this.stockLevel,
    required this.status,
  });

  // Factory to create from Supabase (JSON)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] ?? '',
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      images: List<String>.from(json['images'] ?? []),
      stockLevel: json['stock_level'] as int,
      status: json['status'] as String,
    );
  }
}
