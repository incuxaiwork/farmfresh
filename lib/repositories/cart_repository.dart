import '../models/cart_item_model.dart';
import '../core/services/api_client.dart';

class CartSummary {
  final double subtotal;
  final double discount;
  final double tax;
  final double deliveryCharge;
  final double grandTotal;

  const CartSummary({
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.deliveryCharge = 0,
    this.grandTotal = 0,
  });
}

abstract class CartRepository {
  Future<List<CartItemModel>> getCart();
  Future<CartSummary> getCartSummary();
  Future<void> updateCart(List<CartItemModel> items);
  Future<void> clearCart();
  Future<void> addItemToBackend(String productId, int quantity);
  Future<void> updateItemQuantity(String cartItemId, int quantity);
  Future<void> removeItemById(String cartItemId);
}

class PostgresCartRepository implements CartRepository {
  final ApiClient _apiClient;

  PostgresCartRepository(this._apiClient);

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final res = await _apiClient.dio.get('/cart');

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final cartData = res.data['data'];
        final items = cartData['items'] as List? ?? [];
        return items.map<CartItemModel>((item) {
          return CartItemModel.fromBackendJson(item as Map<String, dynamic>);
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  @override
  Future<CartSummary> getCartSummary() async {
    try {
      final res = await _apiClient.dio.get('/cart/summary');

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final d = res.data['data'];
        return CartSummary(
          subtotal: _toDouble(d['subtotal']),
          discount: _toDouble(d['discount']),
          tax: _toDouble(d['tax']),
          deliveryCharge: _toDouble(d['deliveryCharge']),
          grandTotal: _toDouble(d['grandTotal']),
        );
      }
    } catch (_) {}
    return const CartSummary();
  }

  @override
  Future<void> addItemToBackend(String productId, int quantity) async {
    try {
      await _apiClient.dio.post('/cart/items', data: {
        'productId': productId,
        'quantity': quantity,
      });
    } catch (_) {}
  }

  @override
  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    try {
      await _apiClient.dio.patch('/cart/items/$cartItemId', data: {
        'quantity': quantity,
      });
    } catch (_) {}
  }

  @override
  Future<void> removeItemById(String cartItemId) async {
    try {
      await _apiClient.dio.delete('/cart/items/$cartItemId');
    } catch (_) {}
  }

  @override
  Future<void> updateCart(List<CartItemModel> items) async {
    try {
      for (final item in items) {
        await _apiClient.dio.post('/cart/items', data: {
          'productId': item.product.id,
          'quantity': item.quantity,
        });
      }
    } catch (_) {}
  }

  @override
  Future<void> clearCart() async {
    try {
      await _apiClient.dio.delete('/cart/clear');
    } catch (_) {}
  }
}
