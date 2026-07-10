class ProductModel {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String? discount; // e.g. '20% OFF'
  final String origin;
  final String category; // 'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Meat' etc.
  final String image; // Asset or network image link
  final String description;
  final String calories;
  final String protein;
  final String fat;
  final String weight;
  final double stock; // Quantity in kg, dozen, or bundles
  final String farmName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    this.discount,
    required this.origin,
    required this.category,
    required this.image,
    required this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.weight,
    required this.stock,
    required this.farmName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discount: json['discount'] as String?,
      origin: json['origin'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      calories: json['calories'] as String,
      protein: json['protein'] as String,
      fat: json['fat'] as String,
      weight: json['weight'] as String,
      stock: (json['stock'] as num).toDouble(),
      farmName: json['farmName'] as String,
    );
  }

  factory ProductModel.fromBackendJson(Map<String, dynamic> json) {
    final price = (json['price'] as num).toDouble();
    final discountPrice = json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null;
    final discountPct = discountPrice != null ? '${(((price - discountPrice) / price) * 100).round()}% OFF' : null;

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: discountPrice ?? price,
      originalPrice: price,
      discount: discountPct,
      origin: json['organic'] == true ? 'Organic' : 'Local',
      category: json['category'] != null ? json['category']['name'] as String : 'Fruits',
      image: json['images'] != null && (json['images'] as List).isNotEmpty ? json['images'][0]['imageUrl'] as String : '',
      description: json['description'] as String? ?? '',
      calories: '45 kcal',
      protein: '1.2 g',
      fat: '0.2 g',
      weight: json['unit'] as String? ?? '1 kg',
      stock: json['inventory'] != null ? (json['inventory']['currentStock'] as num).toDouble() : 50.0,
      farmName: json['farmer'] != null ? json['farmer']['farmName'] as String : 'Green Farms',
    );
  }

  /// Parses the slim product object embedded inside a cart item response.
  /// The cart item product does NOT include nested farmer/images — only basic fields.
  factory ProductModel.fromCartItemBackendJson(
    Map<String, dynamic> productJson,
    Map<String, dynamic> cartItemJson,
  ) {
    final price = (productJson['price'] as num?)?.toDouble() ?? (cartItemJson['unitPrice'] as num?)?.toDouble() ?? 0.0;
    final discountPrice = productJson['discountPrice'] != null ? (productJson['discountPrice'] as num).toDouble() : null;
    final discountPct = discountPrice != null && price > 0 ? '${(((price - discountPrice) / price) * 100).round()}% OFF' : null;

    return ProductModel(
      id: productJson['id'] as String? ?? cartItemJson['productId'] as String? ?? '',
      name: productJson['name'] as String? ?? 'Product',
      price: discountPrice ?? price,
      originalPrice: price,
      discount: discountPct,
      origin: 'Local',
      category: 'Produce',
      image: '',
      description: '',
      calories: '45 kcal',
      protein: '1.2 g',
      fat: '0.2 g',
      weight: productJson['unit'] as String? ?? '1 kg',
      stock: productJson['inventory'] != null
          ? ((productJson['inventory']['currentStock'] as num).toDouble() -
              (productJson['inventory']['reservedStock'] as num).toDouble())
          : 50.0,
      farmName: 'Farm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'discount': discount,
      'origin': origin,
      'category': category,
      'image': image,
      'description': description,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'weight': weight,
      'stock': stock,
      'farmName': farmName,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? discount,
    String? origin,
    String? category,
    String? image,
    String? description,
    String? calories,
    String? protein,
    String? fat,
    String? weight,
    double? stock,
    String? farmName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discount: discount ?? this.discount,
      origin: origin ?? this.origin,
      category: category ?? this.category,
      image: image ?? this.image,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      farmName: farmName ?? this.farmName,
    );
  }
}
