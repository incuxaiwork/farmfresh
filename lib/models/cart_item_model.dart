import 'product_model.dart';

class CartItemModel {
  final String? cartItemId; // Backend cart item UUID for PATCH /cart/items/:id and DELETE /cart/items/:id
  final ProductModel product;
  final int quantity;
  final double unitPrice;  // Price at time of adding to cart
  final double totalPrice; // unitPrice * quantity

  CartItemModel({
    this.cartItemId,
    required this.product,
    required this.quantity,
    double? unitPrice,
    double? totalPrice,
  })  : unitPrice = unitPrice ?? product.price,
        totalPrice = totalPrice ?? (product.price * quantity);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  /// Parse from the backend GET /cart response (items array inside cart object)
  factory CartItemModel.fromBackendJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    final product = productJson != null
        ? ProductModel.fromCartItemBackendJson(productJson, json)
        : _fallbackProduct(json);

    return CartItemModel(
      cartItemId: json['id'] as String?,
      product: product,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? product.price,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    );
  }

  static ProductModel _fallbackProduct(Map<String, dynamic> json) {
    return ProductModel(
      id: json['productId'] as String? ?? '',
      name: 'Unknown Product',
      price: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      origin: 'Local',
      category: 'Other',
      image: '',
      description: '',
      calories: '0 kcal',
      protein: '0 g',
      fat: '0 g',
      weight: '1 kg',
      stock: 100,
      farmName: 'Unknown Farm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    String? cartItemId,
    ProductModel? product,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return CartItemModel(
      cartItemId: cartItemId ?? this.cartItemId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
