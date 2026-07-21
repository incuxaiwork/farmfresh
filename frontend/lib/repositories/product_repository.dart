import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../core/services/api_client.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<List<String>> getCategories();
  Future<ProductModel> addProduct(ProductModel product, {Uint8List? imageBytes, String? imageFilename});
  Future<ProductModel> updateProduct(ProductModel product, {Uint8List? imageBytes, String? imageFilename});
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> getFarmerProducts({int page = 1, int limit = 20, String? search, String? status});
  Future<String> uploadProductImageBytes(String productId, Uint8List imageBytes, String filename);
  Future<String> addProductImageUrls(String productId, List<String> imageUrls);
}

class PostgresProductRepository implements ProductRepository {
  final ApiClient _apiClient;
  final Map<String, String> _categoryNameToId = {};

  PostgresProductRepository(this._apiClient);

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final res = await _apiClient.dio.get('/products/featured');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error handled silently
    }
    return [];
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final res = await _apiClient.dio.get('/products/popular');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error handled silently
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final res = await _apiClient.dio.get('/categories');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _categoryNameToId.clear();
        for (var item in list) {
          final name = item['name'] as String;
          final id = item['id'] as String;
          _categoryNameToId[name] = id;
        }
        return ['All', ..._categoryNameToId.keys];
      }
    } catch (e) {
      // Error handled silently
    }
    return ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Meat'];
  }

  @override
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy}) async {
    try {
      final query = <String, String>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (category != null && category != 'All') {
        final catId = _categoryNameToId[category];
        if (catId != null) {
          query['categoryId'] = catId;
        } else {
          query['category'] = category;
        }
      }
      if (sortBy != null) query['sortBy'] = sortBy;

      final res = await _apiClient.dio.get('/products', queryParameters: query);

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (e) {
      // Error handled silently
    }
    return [];
  }

  @override
  Future<ProductModel> addProduct(ProductModel product, {Uint8List? imageBytes, String? imageFilename}) async {
    try {
      final res = await _apiClient.dio.post('/products', data: product.toCreatePayload());
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          final created = ProductModel.fromBackendJson(res.data['data']);
          final imgUrl = product.image;
          if (imgUrl.isNotEmpty) {
            try {
              if (imageBytes != null && imageBytes.isNotEmpty) {
                await uploadProductImageBytes(created.id, imageBytes, imageFilename ?? 'product_image.jpg');
              } else if (imgUrl.startsWith('http')) {
                await addProductImageUrls(created.id, [imgUrl]);
              }
            } catch (e) {
              print('[PRODUCT] Image upload after create failed: $e');
            }
          }
          return created;
        }
      }
      throw Exception('Failed to add product');
    } on DioException catch (e) {
      throw Exception(classifyDioError(e));
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product, {Uint8List? imageBytes, String? imageFilename}) async {
    try {
      final res = await _apiClient.dio.patch('/products/${product.id}', data: product.toCreatePayload());
      if (res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          final updated = ProductModel.fromBackendJson(res.data['data']);
          final imgUrl = product.image;
          if (imgUrl.isNotEmpty && imgUrl != updated.image) {
            try {
              if (imageBytes != null && imageBytes.isNotEmpty) {
                await uploadProductImageBytes(product.id, imageBytes, imageFilename ?? 'product_image.jpg');
              } else if (imgUrl.startsWith('http')) {
                await addProductImageUrls(product.id, [imgUrl]);
              }
            } catch (e) {
              print('[PRODUCT] Image upload after update failed: $e');
            }
          }
          return updated;
        }
      }
      throw Exception('Failed to update product');
    } on DioException catch (e) {
      throw Exception(classifyDioError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final res = await _apiClient.dio.delete('/products/$id');
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to delete product');
    }
  }

  @override
  Future<List<ProductModel>> getFarmerProducts({int page = 1, int limit = 20, String? search, String? status}) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (status != null) query['status'] = status;

      final res = await _apiClient.dio.get('/farmer/products', queryParameters: query);
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => ProductModel.fromBackendJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<String> uploadProductImageBytes(String productId, Uint8List imageBytes, String filename) async {
    try {
      final multipartFile = MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
      );
      final formData = FormData.fromMap({'image': multipartFile});
      final res = await _apiClient.dio.post('/products/$productId/upload-image', data: formData);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data['success'] == true && res.data['data'] != null) {
          final images = res.data['data']['images'] as List?;
          if (images != null && images.isNotEmpty) {
            return images[0]['imageUrl'] as String;
          }
        }
      }
      throw Exception('Failed to upload image');
    } on DioException catch (e) {
      throw Exception(classifyDioError(e));
    }
  }

  @override
  Future<String> addProductImageUrls(String productId, List<String> imageUrls) async {
    try {
      final res = await _apiClient.dio.post('/products/$productId/images', data: {'imageUrls': imageUrls});
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data['success'] == true && res.data['data'] != null) {
          final images = res.data['data']['images'] as List?;
          if (images != null && images.isNotEmpty) {
            return images[0]['imageUrl'] as String;
          }
        }
      }
      throw Exception('Failed to add product images');
    } on DioException catch (e) {
      throw Exception(classifyDioError(e));
    }
  }
}
