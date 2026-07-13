import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';
import '../core/services/api_client.dart';

// Admin Repository provider registered into App Providers
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresAdminRepository(apiClient);
});

// Admin state container
class AdminState {
  final AdminDashboardModel dashboard;
  final List<Map<String, dynamic>> farmers;
  final List<ProductModel> products;
  final List<OrderModel> orders;
  final List<UserModel> customers;
  final List<UserModel> deliveryPartners;
  final bool isLoading;
  final String? errorMessage;

  AdminState({
    AdminDashboardModel? dashboard,
    this.farmers = const [],
    this.products = const [],
    this.orders = const [],
    this.customers = const [],
    this.deliveryPartners = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : dashboard = dashboard ?? AdminDashboardModel();

  AdminState copyWith({
    AdminDashboardModel? dashboard,
    List<Map<String, dynamic>>? farmers,
    List<ProductModel>? products,
    List<OrderModel>? orders,
    List<UserModel>? customers,
    List<UserModel>? deliveryPartners,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      dashboard: dashboard ?? this.dashboard,
      farmers: farmers ?? this.farmers,
      products: products ?? this.products,
      orders: orders ?? this.orders,
      customers: customers ?? this.customers,
      deliveryPartners: deliveryPartners ?? this.deliveryPartners,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref _ref;
  bool _mounted = true;

  AdminNotifier(this._ref) : super(AdminState());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadDashboard() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final db = await _ref.read(adminRepositoryProvider).getDashboard();
      if (_mounted) {
        state = state.copyWith(dashboard: db, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadFarmers({String? status}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(adminRepositoryProvider).getFarmers(kycStatus: status);
      if (_mounted) {
        state = state.copyWith(farmers: list, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> approveFarmer(String farmerProfileId) async {
    try {
      await _ref.read(adminRepositoryProvider).approveFarmer(farmerProfileId);
      await loadFarmers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectFarmer(String farmerProfileId) async {
    try {
      await _ref.read(adminRepositoryProvider).rejectFarmer(farmerProfileId);
      await loadFarmers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suspendFarmer(String farmerProfileId) async {
    try {
      await _ref.read(adminRepositoryProvider).suspendFarmer(farmerProfileId);
      await loadFarmers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadProducts({String? status}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(adminRepositoryProvider).getProducts(status: status);
      if (_mounted) {
        state = state.copyWith(products: list, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> approveProduct(String productId) async {
    try {
      await _ref.read(adminRepositoryProvider).updateProductStatus(productId, 'APPROVED');
      await loadProducts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectProduct(String productId) async {
    try {
      await _ref.read(adminRepositoryProvider).updateProductStatus(productId, 'REJECTED');
      await loadProducts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadOrders({String? status}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(adminRepositoryProvider).getOrders(status: status);
      if (_mounted) {
        state = state.copyWith(orders: list, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadCustomers() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(adminRepositoryProvider).getCustomers();
      if (_mounted) {
        state = state.copyWith(customers: list, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> toggleCustomerSuspension(String customerId, String currentStatus) async {
    try {
      final nextStatus = currentStatus == 'suspended' ? 'active' : 'suspended';
      await _ref.read(adminRepositoryProvider).updateCustomerStatus(customerId, nextStatus);
      await loadCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadDeliveryPartners() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _ref.read(adminRepositoryProvider).getDeliveryPartners();
      if (_mounted) {
        state = state.copyWith(deliveryPartners: list, isLoading: false);
      }
    } catch (e) {
      if (_mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> toggleDeliveryPartnerSuspension(String driverId, bool currentlySuspended) async {
    try {
      await _ref.read(adminRepositoryProvider).toggleDeliveryPartnerSuspension(driverId, !currentlySuspended);
      await loadDeliveryPartners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignDelivery(String orderId, String driverId) async {
    try {
      await _ref.read(adminRepositoryProvider).assignDelivery(orderId, driverId);
      await loadOrders();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});
