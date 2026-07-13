import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';
import 'app_providers.dart';

class CartState {
  final List<CartItemModel> items;
  final String? couponCode;
  final double discountPercent; // applied via coupon e.g. 0.50
  final bool isLoading;
  final String? errorMessage;

  // Backend-computed totals (from GET /cart/summary)
  final double backendSubtotal;
  final double backendDiscount;
  final double backendTax;
  final double backendDeliveryCharge;
  final double backendGrandTotal;
  final bool hasFetchedSummary;

  CartState({
    this.items = const [],
    this.couponCode,
    this.discountPercent = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.backendSubtotal = 0,
    this.backendDiscount = 0,
    this.backendTax = 0,
    this.backendDeliveryCharge = 0,
    this.backendGrandTotal = 0,
    this.hasFetchedSummary = false,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // ── Local fallback calculations (used when summary hasn't loaded) ─────────
  double get localSubtotal => items.fold(0.0, (s, i) => s + (i.product.price * i.quantity));

  double get localDeliveryFee => items.isEmpty ? 0.0 : (localSubtotal >= 30.0 ? 0.0 : 5.00);

  double get localDiscountAmount => localSubtotal * discountPercent;

  double get localTax => (localSubtotal - localDiscountAmount) * 0.05;

  double get localGrandTotal {
    final val = localSubtotal - localDiscountAmount + localDeliveryFee + localTax;
    return val < 0 ? 0.0 : val;
  }

  // ── Public getters: prefer backend values when available ──────────────────
  double get subtotal => hasFetchedSummary ? backendSubtotal : localSubtotal;
  double get discountAmount => hasFetchedSummary ? backendDiscount : localDiscountAmount;
  double get tax => hasFetchedSummary ? backendTax : localTax;
  double get deliveryFee => hasFetchedSummary ? backendDeliveryCharge : localDeliveryFee;
  double get grandTotal => hasFetchedSummary ? backendGrandTotal : localGrandTotal;

  // Legacy compat alias used in checkout
  double get total => grandTotal;

  CartState copyWith({
    List<CartItemModel>? items,
    String? couponCode,
    double? discountPercent,
    bool? isLoading,
    String? errorMessage,
    double? backendSubtotal,
    double? backendDiscount,
    double? backendTax,
    double? backendDeliveryCharge,
    double? backendGrandTotal,
    bool? hasFetchedSummary,
  }) {
    return CartState(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discountPercent: discountPercent ?? this.discountPercent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      backendSubtotal: backendSubtotal ?? this.backendSubtotal,
      backendDiscount: backendDiscount ?? this.backendDiscount,
      backendTax: backendTax ?? this.backendTax,
      backendDeliveryCharge: backendDeliveryCharge ?? this.backendDeliveryCharge,
      backendGrandTotal: backendGrandTotal ?? this.backendGrandTotal,
      hasFetchedSummary: hasFetchedSummary ?? this.hasFetchedSummary,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref _ref;
  bool _mounted = true;

  CartNotifier(this._ref) : super(CartState()) {
    _loadCart();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  CartRepository get _repo => _ref.read(cartRepositoryProvider);

  Future<void> _loadCart() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repo.getCart();
      if (_mounted) {
        state = state.copyWith(items: items, isLoading: false);
        await _refreshSummary();
      }
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load cart. Please try again.',
        );
      }
    }
  }

  Future<void> reload() => _loadCart();

  Future<void> _refreshSummary() async {
    if (!_mounted) return;
    try {
      final summary = await _repo.getCartSummary();
      if (_mounted) {
        state = state.copyWith(
          backendSubtotal: summary.subtotal,
          backendDiscount: summary.discount,
          backendTax: summary.tax,
          backendDeliveryCharge: summary.deliveryCharge,
          backendGrandTotal: summary.grandTotal,
          hasFetchedSummary: true,
        );
      }
    } catch (_) {
      // Fall back to local calculations — no state update needed
    }
  }

  Future<void> addItem(ProductModel product) async {
    if (!_mounted) return;
    // Optimistic UI update first
    final index = state.items.indexWhere((item) => item.product.id == product.id);
    List<CartItemModel> newList;
    if (index != -1) {
      newList = List.from(state.items);
      newList[index] = newList[index].copyWith(quantity: newList[index].quantity + 1);
    } else {
      newList = [...state.items, CartItemModel(product: product, quantity: 1)];
    }
    if (_mounted) {
      state = state.copyWith(items: newList, hasFetchedSummary: false);
    }

    // Sync to backend then refresh totals
    await _repo.addItemToBackend(product.id, 1);
    if (_mounted) {
      await _refreshSummary();
    }
  }

  Future<void> increaseQuantity(CartItemModel item) async {
    await _updateQuantity(item, item.quantity + 1);
  }

  Future<void> decreaseQuantity(CartItemModel item) async {
    if (item.quantity <= 1) {
      await removeItem(item.product.id);
    } else {
      await _updateQuantity(item, item.quantity - 1);
    }
  }

  Future<void> _updateQuantity(CartItemModel item, int newQty) async {
    if (!_mounted) return;
    final index = state.items.indexWhere((i) => i.product.id == item.product.id);
    if (index == -1) return;

    final newList = List<CartItemModel>.from(state.items);
    newList[index] = newList[index].copyWith(quantity: newQty);
    if (_mounted) {
      state = state.copyWith(items: newList, hasFetchedSummary: false);
    }

    // Use per-item PATCH if we have the cart item ID, else fall back to full POST
    if (item.cartItemId != null) {
      await _repo.updateItemQuantity(item.cartItemId!, newQty);
    } else {
      await _repo.addItemToBackend(item.product.id, newQty);
    }
    if (_mounted) {
      await _refreshSummary();
    }
  }

  Future<void> removeItem(String productId) async {
    if (!_mounted) return;
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;

    final item = state.items[index];
    if (item.quantity > 1) {
      await decreaseQuantity(item);
      return;
    }
    await deleteItemCompletely(productId);
  }

  Future<void> deleteItemCompletely(String productId) async {
    if (!_mounted) return;
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;

    final item = state.items[index];
    final newList = List<CartItemModel>.from(state.items)..removeAt(index);
    if (_mounted) {
      state = state.copyWith(items: newList, hasFetchedSummary: false);
    }

    if (item.cartItemId != null) {
      await _repo.removeItemById(item.cartItemId!);
    } else {
      await _repo.updateCart(newList);
    }
    if (_mounted) {
      await _refreshSummary();
    }
  }

  bool applyCoupon(String code) {
    if (!_mounted) return false;
    if (code.trim().isEmpty) return false;
    state = state.copyWith(couponCode: code.trim().toUpperCase(), discountPercent: 0.0, hasFetchedSummary: false);
    return true;
  }

  void removeCoupon() {
    if (!_mounted) return;
    state = state.copyWith(couponCode: null, discountPercent: 0.0, hasFetchedSummary: false);
    _refreshSummary();
  }

  Future<void> clearCart() async {
    if (!_mounted) return;
    state = CartState();
    await _repo.clearCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
