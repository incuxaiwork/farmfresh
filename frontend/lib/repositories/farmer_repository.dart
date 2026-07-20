import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/farmer_dashboard_model.dart';
import '../models/inventory_model.dart';
import '../models/earnings_model.dart';
import '../models/withdrawal_model.dart';
import '../models/notification_model.dart';
import '../models/bank_account_model.dart';
import '../models/user_model.dart';
import '../core/services/api_client.dart';

abstract class FarmerRepository {
  Future<FarmerDashboardModel> getDashboard();
  Future<FarmerStatisticsModel> getStatistics();

  Future<List<InventoryModel>> getInventory({int page = 1, int limit = 20});
  Future<InventoryModel> updateStock(String inventoryId, double quantity);
  Future<InventoryModel> addStock(String inventoryId, double quantity);
  Future<InventoryModel> removeStock(String inventoryId, double quantity);

  Future<EarningsModel> getEarnings();
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20});

  Future<List<WithdrawalModel>> getWithdrawals({int page = 1, int limit = 20});
  Future<WithdrawalModel> requestWithdrawal(double amount, {String? bankAccountId});
  Future<BankAccountModel> updateBankAccount(BankAccountModel account);

  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20});
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead();

  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? name, String? phone, String? farmName, String? farmAddress, String? avatar});
  Future<String> uploadAvatar(String filePath);
}

class PostgresFarmerRepository implements FarmerRepository {
  final ApiClient _apiClient;

  PostgresFarmerRepository(this._apiClient);

  @override
  Future<FarmerDashboardModel> getDashboard() async {
    try {
      final res = await _apiClient.dio.get('/farmer/dashboard');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return FarmerDashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return FarmerDashboardModel();
  }

  @override
  Future<FarmerStatisticsModel> getStatistics() async {
    try {
      final res = await _apiClient.dio.get('/farmer/statistics');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return FarmerStatisticsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return FarmerStatisticsModel.fromJson({});
  }

  @override
  Future<List<InventoryModel>> getInventory({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/inventory', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => InventoryModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<InventoryModel> updateStock(String inventoryId, double quantity) async {
    try {
      final res = await _apiClient.dio.patch('/inventory/$inventoryId', data: {'currentStock': quantity});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update stock');
    }
  }

  @override
  Future<InventoryModel> addStock(String inventoryId, double quantity) async {
    try {
      final res = await _apiClient.dio.patch('/inventory/$inventoryId/add', data: {'quantity': quantity});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to add stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to add stock');
    }
  }

  @override
  Future<InventoryModel> removeStock(String inventoryId, double quantity) async {
    try {
      final res = await _apiClient.dio.patch('/inventory/$inventoryId/remove', data: {'quantity': quantity});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to remove stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to remove stock');
    }
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final res = await _apiClient.dio.get('/farmer/earnings');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return EarningsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return EarningsModel(totalEarnings: 0, pendingWithdrawals: 0, completedWithdrawals: 0);
  }

  @override
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/farmer/transactions', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<WithdrawalModel>> getWithdrawals({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/withdrawals', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => WithdrawalModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<WithdrawalModel> requestWithdrawal(double amount, {String? bankAccountId}) async {
    try {
      final res = await _apiClient.dio.post('/withdrawals', data: {
        'amount': amount,
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return WithdrawalModel.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to request withdrawal');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to request withdrawal');
    }
  }

  @override
  Future<BankAccountModel> updateBankAccount(BankAccountModel account) async {
    try {
      final res = await _apiClient.dio.put('/farmer/bank-account', data: account.toJson());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return BankAccountModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update bank account');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update bank account');
    }
  }

  @override
  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/notifications', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.dio.patch('/notifications/$notificationId/read');
    } catch (_) {}
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await _apiClient.dio.patch('/notifications/read-all');
    } catch (_) {}
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final res = await _apiClient.dio.get('/auth/profile');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to load profile');
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone, String? farmName, String? farmAddress, String? avatar}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (farmName != null) data['farmName'] = farmName;
      if (farmAddress != null) data['farmAddress'] = farmAddress;
      if (avatar != null) data['avatar'] = avatar;

      final res = await _apiClient.dio.patch('/auth/profile', data: data);
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update profile');
    }
  }
  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        final res = await Dio().get(filePath, options: Options(responseType: ResponseType.bytes));
        multipartFile = MultipartFile.fromBytes(res.data, filename: 'avatar.png');
      } else {
        multipartFile = await MultipartFile.fromFile(filePath);
      }

      final formData = FormData.fromMap({
        'image': multipartFile,
      });
      final res = await _apiClient.dio.post('/auth/upload-avatar', data: formData);
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return res.data['data']['avatar'] as String;
        }
      }
      throw Exception('Failed to upload avatar');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to upload avatar');
    }
  }
}
