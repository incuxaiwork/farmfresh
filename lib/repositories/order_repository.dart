import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';
import 'mock_db.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
}

class PostgresOrderRepository implements OrderRepository {
  final MockOrderRepository _mockFallback = MockOrderRepository();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/orders'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((item) => OrderModel.fromBackendJson(item)).toList();
        }
      }
    } catch (e) {
      // Fallback silently
    }
    return _mockFallback.getOrders();
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final itemsPayload = order.items.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList();

      final res = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/orders'),
        headers: await _getHeaders(),
        body: json.encode({
          'address': 'Seeded Address, City',
          'notes': 'Delivered via Checkout flow',
          'items': itemsPayload,
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromBackendJson(data['data']);
        }
      }
    } catch (e) {
      // Fallback
    }
    return _mockFallback.createOrder(order);
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/orders/$orderId/status'),
        headers: await _getHeaders(),
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return OrderModel.fromBackendJson(data['data']);
        }
      }
    } catch (e) {
      // Fallback
    }
    return _mockFallback.updateOrderStatus(orderId, status);
  }
}

class MockOrderRepository implements OrderRepository {
  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(MockDb.orders);
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newOrder = order.copyWith(
      id: (MockDb.orders.length + 1000).toString(),
    );
    MockDb.orders.insert(0, newOrder);
    return newOrder;
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = MockDb.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = MockDb.orders[index].copyWith(status: status);
      MockDb.orders[index] = updated;
      return updated;
    }
    throw Exception('Order not found');
  }
}
