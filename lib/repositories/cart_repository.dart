import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';
import 'mock_db.dart';

/// Summary returned from GET /cart/summary
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
  final MockCartRepository _mockFallback = MockCartRepository();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/cart'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final cartData = data['data'];
          final items = cartData['items'] as List? ?? [];
          return items.map<CartItemModel>((item) {
            return CartItemModel.fromBackendJson(item as Map<String, dynamic>);
          }).toList();
        }
      }
    } catch (_) {
      // Fall through to mock
    }
    return _mockFallback.getCart();
  }

  @override
  Future<CartSummary> getCartSummary() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/summary'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final d = data['data'];
          return CartSummary(
            subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0,
            discount: (d['discount'] as num?)?.toDouble() ?? 0,
            tax: (d['tax'] as num?)?.toDouble() ?? 0,
            deliveryCharge: (d['deliveryCharge'] as num?)?.toDouble() ?? 0,
            grandTotal: (d['grandTotal'] as num?)?.toDouble() ?? 0,
          );
        }
      }
    } catch (_) {
      // Return zero summary on error
    }
    return const CartSummary();
  }

  @override
  Future<void> addItemToBackend(String productId, int quantity) async {
    try {
      await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/items'),
        headers: await _getHeaders(),
        body: json.encode({'productId': productId, 'quantity': quantity}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Silently fall through — local state already updated
    }
  }

  @override
  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    try {
      await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/items/$cartItemId'),
        headers: await _getHeaders(),
        body: json.encode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  @override
  Future<void> removeItemById(String cartItemId) async {
    try {
      await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/items/$cartItemId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  @override
  Future<void> updateCart(List<CartItemModel> items) async {
    // Kept for backwards compat; individual operations now use addItemToBackend / updateItemQuantity
    try {
      for (final item in items) {
        await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/cart/items'),
          headers: await _getHeaders(),
          body: json.encode({
            'productId': item.product.id,
            'quantity': item.quantity,
          }),
        ).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
    await _mockFallback.updateCart(items);
  }

  @override
  Future<void> clearCart() async {
    try {
      await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/clear'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
    await _mockFallback.clearCart();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock fallback (used when auth token is unavailable / offline)
// ─────────────────────────────────────────────────────────────────────────────

class MockCartRepository implements CartRepository {
  @override
  Future<List<CartItemModel>> getCart() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return List.from(MockDb.cartItems);
  }

  @override
  Future<CartSummary> getCartSummary() async {
    final items = MockDb.cartItems;
    final subtotal = items.fold(0.0, (s, i) => s + (i.product.price * i.quantity));
    final delivery = subtotal >= 20 ? 0.0 : 2.0;
    final tax = subtotal * 0.05;
    return CartSummary(
      subtotal: subtotal,
      discount: 0,
      tax: tax,
      deliveryCharge: delivery,
      grandTotal: subtotal + tax + delivery,
    );
  }

  @override
  Future<void> updateCart(List<CartItemModel> items) async {
    await Future.delayed(const Duration(milliseconds: 80));
    MockDb.cartItems
      ..clear()
      ..addAll(items);
  }

  @override
  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 80));
    MockDb.cartItems.clear();
  }

  @override
  Future<void> addItemToBackend(String productId, int quantity) async {}

  @override
  Future<void> updateItemQuantity(String cartItemId, int quantity) async {}

  @override
  Future<void> removeItemById(String cartItemId) async {}
}
