import '../core/services/api_client.dart';
import '../models/admin_dashboard_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

abstract class AdminRepository {
  Future<AdminDashboardModel> getDashboard();
  Future<List<Map<String, dynamic>>> getFarmers({String? kycStatus});
  Future<void> approveFarmer(String farmerProfileId);
  Future<void> rejectFarmer(String farmerProfileId);
  Future<void> suspendFarmer(String farmerProfileId);
  Future<List<ProductModel>> getProducts({String? status});
  Future<void> updateProductStatus(String productId, String status);
  Future<List<OrderModel>> getOrders({String? status});
  Future<List<UserModel>> getCustomers();
  Future<void> updateCustomerStatus(String customerId, String status);
  Future<List<UserModel>> getDeliveryPartners();
  Future<void> toggleDeliveryPartnerSuspension(String driverId, bool suspend);
  Future<void> assignDelivery(String orderId, String driverId);
}

class PostgresAdminRepository implements AdminRepository {
  final ApiClient _apiClient;

  PostgresAdminRepository(this._apiClient);

  @override
  Future<AdminDashboardModel> getDashboard() async {
    final res = await _apiClient.dio.get('/admin/dashboard');
    if (res.statusCode == 200 && res.data['success'] == true) {
      return AdminDashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to load admin dashboard');
  }

  @override
  Future<List<Map<String, dynamic>>> getFarmers({String? kycStatus}) async {
    final query = <String, dynamic>{};
    if (kycStatus != null) query['kycStatus'] = kycStatus;
    
    final res = await _apiClient.dio.get('/admin/farmers', queryParameters: query);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<void> approveFarmer(String farmerProfileId) async {
    await _apiClient.dio.patch('/admin/farmers/$farmerProfileId/approve');
  }

  @override
  Future<void> rejectFarmer(String farmerProfileId) async {
    await _apiClient.dio.patch('/admin/farmers/$farmerProfileId/reject');
  }

  @override
  Future<void> suspendFarmer(String farmerProfileId) async {
    await _apiClient.dio.patch('/admin/farmers/$farmerProfileId/suspend');
  }

  @override
  Future<List<ProductModel>> getProducts({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;

    final res = await _apiClient.dio.get('/admin/products', queryParameters: query);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((item) => ProductModel.fromBackendJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> updateProductStatus(String productId, String status) async {
    await _apiClient.dio.patch('/products/$productId/status', data: {'status': status});
  }

  @override
  Future<List<OrderModel>> getOrders({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;

    final res = await _apiClient.dio.get('/admin/orders', queryParameters: query);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((item) => OrderModel.fromBackendJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<UserModel>> getCustomers() async {
    final res = await _apiClient.dio.get('/admin/customers');
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> updateCustomerStatus(String customerId, String status) async {
    await _apiClient.dio.patch('/admin/customers/$customerId/status', data: {'status': status});
  }

  @override
  Future<List<UserModel>> getDeliveryPartners() async {
    final res = await _apiClient.dio.get('/admin/delivery-partners');
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data']['data'] as List? ?? [];
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> toggleDeliveryPartnerSuspension(String driverId, bool suspend) async {
    final action = suspend ? 'suspend' : 'activate';
    await _apiClient.dio.patch('/admin/delivery-partners/$driverId/$action');
  }

  @override
  Future<void> assignDelivery(String orderId, String driverId) async {
    await _apiClient.dio.post('/delivery/assign', data: {
      'orderId': orderId,
      'driverId': driverId,
    });
  }
}
