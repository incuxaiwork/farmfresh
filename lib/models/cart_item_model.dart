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

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
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
      unitPrice: _toDouble(json['unitPrice']) ?? product.price,
      totalPrice: _toDouble(json['totalPrice']),
    );
  }

  static ProductModel _fallbackProduct(Map<String, dynamic> json) {
    return ProductModel.fallback(id: json['productId'] as String? ?? '');
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
