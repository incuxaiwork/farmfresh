import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../core/services/api_client.dart';

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresCategoryRepository(apiClient);
});

// State
class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final Ref _ref;
  bool _mounted = true;

  CategoryNotifier(this._ref) : super(const CategoryState()) {
    loadCategories();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadCategories({String? status}) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cats = await _ref
          .read(categoryRepositoryProvider)
          .getCategories(status: status);
      if (_mounted) {
        state = state.copyWith(categories: cats, isLoading: false);
      }
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    if (!_mounted) return false;
    try {
      await _ref.read(categoryRepositoryProvider).createCategory(data);
      await loadCategories();
      return true;
    } catch (e) {
      if (_mounted) state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    if (!_mounted) return false;
    try {
      await _ref.read(categoryRepositoryProvider).updateCategory(id, data);
      await loadCategories();
      return true;
    } catch (e) {
      if (_mounted) state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    if (!_mounted) return false;
    try {
      await _ref.read(categoryRepositoryProvider).deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      if (_mounted) state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateCategoryStatus(String id, String status) async {
    if (!_mounted) return false;
    try {
      await _ref.read(categoryRepositoryProvider).updateCategoryStatus(id, status);
      await loadCategories();
      return true;
    } catch (e) {
      if (_mounted) state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref);
});
