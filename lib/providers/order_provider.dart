import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'app_providers.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;

  OrderNotifier(this._ref) : super(OrderState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _ref.read(orderRepositoryProvider).getOrders();
      state = OrderState(orders: list);
    } catch (e) {
      state = OrderState(errorMessage: e.toString());
    }
  }

  Future<OrderModel?> createOrder({
    required List<CartItemModel> items,
    required double total,
    required double deliveryFee,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      // Generate a random 4-digit OTP code for order security verification
      final otp = (1000 + (DateTime.now().millisecond % 9000)).toString();
      final newOrder = OrderModel(
        id: '', // Set by repository
        date: DateTime.now(),
        items: items,
        total: total,
        deliveryFee: deliveryFee,
        status: 'Pending',
        otp: otp,
      );
      final created = await _ref.read(orderRepositoryProvider).createOrder(newOrder);
      await loadOrders();
      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(orderRepositoryProvider).updateOrderStatus(orderId, status);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});
