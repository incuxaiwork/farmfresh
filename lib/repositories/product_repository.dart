import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';
import 'mock_db.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy});
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<List<String>> getCategories();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class PostgresProductRepository implements ProductRepository {
  final MockProductRepository _mockFallback = MockProductRepository();

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/products/featured'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((item) => ProductModel.fromBackendJson(item)).toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return _mockFallback.getFeaturedProducts();
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/products/popular'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((item) => ProductModel.fromBackendJson(item)).toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return _mockFallback.getPopularProducts();
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/categories'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return ['All', ...list.map((item) => item['name'] as String)];
        }
      }
    } catch (e) {
      // Fallback silently to static list
    }
    return ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains'];
  }

  @override
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy}) async {
    try {
      final query = <String, String>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (category != null && category != 'All') query['category'] = category;
      if (sortBy != null) query['sortBy'] = sortBy;

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/products').replace(queryParameters: query);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          if (list.isNotEmpty) {
            return list.map((item) => ProductModel.fromBackendJson(item)).toList();
          }
        }
      }
    } catch (e) {
      // Fallback silently to mock database if connection drops
    }
    return _mockFallback.getProducts(search: search, category: category);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    return _mockFallback.addProduct(product);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    return _mockFallback.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _mockFallback.deleteProduct(id);
  }
}

class MockProductRepository implements ProductRepository {
  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains'];
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDb.products.where((p) => p.discount != null).toList();
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDb.products.take(2).toList();
  }

  @override
  Future<List<ProductModel>> getProducts({String? search, String? category, String? sortBy}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<ProductModel>.from(MockDb.products);
    if (category != null && category != 'All') {
      results = results.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (search != null && search.isNotEmpty) {
      results = results.where((p) => p.name.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return results;
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newProduct = product.copyWith(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
    );
    MockDb.products.add(newProduct);
    return newProduct;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = MockDb.products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      MockDb.products[index] = product;
      return product;
    }
    throw Exception('Product not found');
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    MockDb.products.removeWhere((p) => p.id == id);
  }
}
