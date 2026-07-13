import '../models/category_model.dart';
import '../core/services/api_client.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories({String? status});
  Future<CategoryModel> createCategory(Map<String, dynamic> data);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);
  Future<CategoryModel> updateCategoryStatus(String id, String status);
}

class PostgresCategoryRepository implements CategoryRepository {
  final ApiClient _apiClient;

  PostgresCategoryRepository(this._apiClient);

  @override
  Future<List<CategoryModel>> getCategories({String? status}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null) query['status'] = status;

      final res = await _apiClient.dio.get('/categories', queryParameters: query);
      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Return empty on failure — provider handles fallback
    }
    return [];
  }

  @override
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final res = await _apiClient.dio.post('/categories', data: data);
    if (res.statusCode == 201 && res.data['success'] == true) {
      return CategoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to create category');
  }

  @override
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final res = await _apiClient.dio.patch('/categories/$id', data: data);
    if (res.statusCode == 200 && res.data['success'] == true) {
      return CategoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to update category');
  }

  @override
  Future<void> deleteCategory(String id) async {
    final res = await _apiClient.dio.delete('/categories/$id');
    if (res.statusCode != 200) {
      throw Exception(res.data['message'] ?? 'Failed to delete category');
    }
  }

  @override
  Future<CategoryModel> updateCategoryStatus(String id, String status) async {
    final res = await _apiClient.dio.patch('/categories/$id/status', data: {'status': status});
    if (res.statusCode == 200 && res.data['success'] == true) {
      return CategoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to update category status');
  }
}
