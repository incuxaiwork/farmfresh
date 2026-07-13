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
  bool _mounted = true;

  ProductNotifier(this._ref) : super(ProductState()) {
    loadProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadProducts({String? search, String? category, String? sortBy}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(productRepositoryProvider);
      final list = await repo.getProducts(
        search: search,
        category: category,
        sortBy: sortBy,
      );
      if (!_mounted) return;
      final featured = await repo.getFeaturedProducts();
      if (!_mounted) return;
      final popular = await repo.getPopularProducts();
      if (!_mounted) return;
      final cats = await repo.getCategories();
      if (!_mounted) return;
      state = ProductState(
        products: list,
        featuredProducts: featured,
        popularProducts: popular,
        categories: cats,
      );
    } catch (e) {
      if (_mounted) {
        state = ProductState(errorMessage: e.toString());
      }
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).addProduct(product);
      if (_mounted) {
        await loadProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).updateProduct(product);
      if (_mounted) {
        await loadProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).deleteProduct(id);
      if (_mounted) {
        await loadProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref);
});

class FarmerProductsNotifier extends StateNotifier<ProductState> {
  final Ref _ref;
  bool _mounted = true;

  FarmerProductsNotifier(this._ref) : super(ProductState()) {
    loadFarmerProducts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadFarmerProducts({String? search, String? status}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(productRepositoryProvider);
      final list = await repo.getFarmerProducts(
        search: search,
        status: status,
      );
      if (!_mounted) return;
      state = ProductState(
        products: list,
      );
    } catch (e) {
      if (_mounted) {
        state = ProductState(errorMessage: e.toString());
      }
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).addProduct(product);
      if (_mounted) {
        await loadFarmerProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).updateProduct(product);
      if (_mounted) {
        await loadFarmerProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(productRepositoryProvider).deleteProduct(id);
      if (_mounted) {
        await loadFarmerProducts();
      }
      return true;
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }
}

final farmerProductsProvider = StateNotifierProvider<FarmerProductsNotifier, ProductState>((ref) {
  return FarmerProductsNotifier(ref);
});

