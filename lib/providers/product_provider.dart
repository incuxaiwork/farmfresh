import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import 'app_providers.dart';

class ProductState {
  final List<ProductModel> products;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> popularProducts;
  final List<String> categories;
  final bool isLoading;
  final String? errorMessage;

  ProductState({
    this.products = const [],
    this.featuredProducts = const [],
    this.popularProducts = const [],
    this.categories = const ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains'],
    this.isLoading = false,
    this.errorMessage,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? popularProducts,
    List<String>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final Ref _ref;

  ProductNotifier(this._ref) : super(ProductState()) {
    loadProducts();
  }

  Future<void> loadProducts({String? search, String? category, String? sortBy}) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(productRepositoryProvider);
      final list = await repo.getProducts(
        search: search,
        category: category,
        sortBy: sortBy,
      );
      final featured = await repo.getFeaturedProducts();
      final popular = await repo.getPopularProducts();
      final cats = await repo.getCategories();
      state = ProductState(
        products: list,
        featuredProducts: featured,
        popularProducts: popular,
        categories: cats,
      );
    } catch (e) {
      state = ProductState(errorMessage: e.toString());
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).addProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).updateProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).deleteProduct(id);
      await loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref);
});
