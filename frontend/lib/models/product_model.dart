class ProductModel {
  final String id;
  final String name;
  final String slug;
  final double price;
  final double originalPrice;
  final String? discount;
  final String origin;
  final String category;
  final String? categoryId;
  final String image;
  final String description;
  final String calories;
  final String protein;
  final String fat;
  final String weight;
  final double stock;
  final String farmName;
  final String? farmerId;
  final bool organic;
  final bool featured;
  final bool seasonal;
  final int viewCount;
  final int soldCount;
  final int reviewCount;
  final double rating;
  final String status;

  ProductModel({
    required this.id,
    required this.name,
    this.slug = '',
    required this.price,
    required this.originalPrice,
    this.discount,
    required this.origin,
    required this.category,
    this.categoryId,
    required this.image,
    required this.description,
    this.calories = '',
    this.protein = '',
    this.fat = '',
    required this.weight,
    required this.stock,
    required this.farmName,
    this.farmerId,
    this.organic = false,
    this.featured = false,
    this.seasonal = false,
    this.viewCount = 0,
    this.soldCount = 0,
    this.reviewCount = 0,
    this.rating = 0,
    this.status = 'APPROVED',
  });

  /// Creates a minimal fallback product when backend data is incomplete.
  factory ProductModel.fallback({required String id}) {
    return ProductModel(
      id: id,
      name: 'Unknown Product',
      price: 0,
      originalPrice: 0,
      origin: 'Local',
      category: 'Other',
      image: '',
      description: '',
      weight: '1 kg',
      stock: 0,
      farmName: 'Unknown Farm',
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = _toNum(json['price']);
    final originalPrice = json['originalPrice'] != null ? _toNum(json['originalPrice']) : price;
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      price: price,
      originalPrice: originalPrice,
      discount: json['discount'] as String?,
      origin: json['origin'] as String? ?? 'Local',
      category: json['category'] != null 
          ? (json['category'] is Map ? json['category']['name'] : json['category'].toString())
          : 'Produce',
      image: _extractPrimaryImage(json['images']) ?? (json['image'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      calories: json['calories'] as String? ?? '',
      protein: json['protein'] as String? ?? '',
      fat: json['fat'] as String? ?? '',
      weight: json['weight'] as String? ?? '1 kg',
      stock: _toNum(json['stock']),
      farmName: json['farmName'] as String? ?? '',
      farmerId: json['farmerId'] as String?,
      organic: json['organic'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      seasonal: json['seasonal'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      soldCount: json['soldCount'] as int? ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      rating: _toNum(json['rating']),
      status: json['status'] as String? ?? 'APPROVED',
    );
  }

  static double _toNum(dynamic v, [double fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  factory ProductModel.fromBackendJson(Map<String, dynamic> json) {
    final price = _toNum(json['price']);
    final discountPrice = json['discountPrice'] != null ? _toNum(json['discountPrice']) : null;
    final discountPct = discountPrice != null && price > 0
        ? '${(((price - discountPrice) / price) * 100).round()}% OFF'
        : null;

    final categoryData = json['category'] as Map<String, dynamic>?;
    final imagesList = json['images'] as List?;
    final inventoryData = json['inventory'] as Map<String, dynamic>?;
    final farmerData = json['farmer'] as Map<String, dynamic>?;

    final rawImage = imagesList != null && imagesList.isNotEmpty
        ? imagesList[0]['imageUrl'] as String? ?? ''
        : '';

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      price: discountPrice ?? price,
      originalPrice: price,
      discount: discountPct,
      origin: json['organic'] == true ? 'Organic' : 'Local',
      category: categoryData != null ? categoryData['name'] as String : 'Other',
      categoryId: json['categoryId'] as String?,
      image: _sanitizeImageUrl(rawImage),
      description: json['description'] as String? ?? '',
      weight: json['unit'] as String? ?? '1 kg',
      stock: inventoryData != null
          ? _toNum(inventoryData['currentStock'])
          : 50.0,
      farmName: farmerData != null ? farmerData['farmName'] as String : 'Farm',
      farmerId: json['farmerId'] as String?,
      organic: json['organic'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      seasonal: json['seasonal'] as bool? ?? false,
      viewCount: _toInt(json['viewCount']),
      soldCount: _toInt(json['soldCount']),
      reviewCount: _toInt(json['reviewCount']),
      rating: _toNum(json['rating']),
      status: json['status'] as String? ?? 'APPROVED',
    );
  }

  /// Replaces known-broken image URLs with working alternatives.
  static const Map<String, String> _brokenImageFixes = {
    'https://images.unsplash.com/photo-1627998826726-2580790757a6?w=500':
        'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500',
    'https://images.unsplash.com/photo-1571244856353-fb0b1f2efb4d?w=500':
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
    'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500':
        'https://images.unsplash.com/photo-1612630742789-cae0c79c5f13?w=500',
  };

  static String _sanitizeImageUrl(String url) {
    return _brokenImageFixes[url] ?? url;
  }

  factory ProductModel.fromCartItemBackendJson(
    Map<String, dynamic> productJson,
    Map<String, dynamic> cartItemJson,
  ) {
    final price = _toNum(productJson['price'], _toNum(cartItemJson['unitPrice'], 0.0));
    final discountPrice = productJson['discountPrice'] != null ? _toNum(productJson['discountPrice']) : null;
    final discountPct = discountPrice != null && price > 0 ? '${(((price - discountPrice) / price) * 100).round()}% OFF' : null;

    return ProductModel(
      id: productJson['id'] as String? ?? cartItemJson['productId'] as String? ?? '',
      name: productJson['name'] as String? ?? 'Product',
      slug: productJson['slug'] as String? ?? '',
      price: discountPrice ?? price,
      originalPrice: price,
      discount: discountPct,
      origin: 'Local',
      category: 'Produce',
      image: '',
      description: '',
      weight: productJson['unit'] as String? ?? '1 kg',
      stock: productJson['inventory'] != null
          ? (_toNum(productJson['inventory']['currentStock']) -
              _toNum(productJson['inventory']['reservedStock']))
          : 50.0,
      farmName: 'Farm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': originalPrice,
      'discountPrice': discount != null ? price : null,
      'unit': weight,
      'description': description,
      'categoryId': categoryId,
      'organic': organic,
      'featured': featured,
      'seasonal': seasonal,
    };
  }

  /// Converts to the JSON format expected by POST /products
  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'description': description,
      'price': originalPrice,
      if (discount != null) 'discountPrice': price,
      'unit': weight,
      'categoryId': categoryId,
      'organic': organic,
      'featured': featured,
      'seasonal': seasonal,
      'stock': stock,
    };
  }

  static String? _extractPrimaryImage(dynamic images) {
    if (images == null || images is! List || images.isEmpty) return null;
    try {
      final primary = images.firstWhere(
        (img) => img['isPrimary'] == true,
        orElse: () => images.first,
      );
      return primary['imageUrl'] as String?;
    } catch (e) {
      return null;
    }
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? slug,
    double? price,
    double? originalPrice,
    String? discount,
    String? origin,
    String? category,
    String? categoryId,
    String? image,
    String? description,
    String? calories,
    String? protein,
    String? fat,
    String? weight,
    double? stock,
    String? farmName,
    String? farmerId,
    bool? organic,
    bool? featured,
    bool? seasonal,
    int? viewCount,
    int? soldCount,
    int? reviewCount,
    double? rating,
    String? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discount: discount ?? this.discount,
      origin: origin ?? this.origin,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      farmName: farmName ?? this.farmName,
      farmerId: farmerId ?? this.farmerId,
      organic: organic ?? this.organic,
      featured: featured ?? this.featured,
      seasonal: seasonal ?? this.seasonal,
      viewCount: viewCount ?? this.viewCount,
      soldCount: soldCount ?? this.soldCount,
      reviewCount: reviewCount ?? this.reviewCount,
      rating: rating ?? this.rating,
      status: status ?? this.status,
    );
  }
}
