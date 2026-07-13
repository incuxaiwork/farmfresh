import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class WishlistNotifier extends StateNotifier<List<String>> {
  WishlistNotifier() : super([]) {
    _loadWishlist();
  }

  static const _key = 'wishlist_product_ids';

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> toggleWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<String>.from(state);
    if (current.contains(productId)) {
      current.remove(productId);
    } else {
      current.add(productId);
    }
    await prefs.setStringList(_key, current);
    state = current;
  }

  bool isFavorited(String productId) {
    return state.contains(productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) {
  return WishlistNotifier();
});

// A derived provider that gets the actual ProductModel objects in the wishlist
final wishlistProductsProvider = Provider<List<ProductModel>>((ref) {
  final wishlistIds = ref.watch(wishlistProvider);
  final allProducts = ref.watch(productProvider).products;
  return allProducts.where((p) => wishlistIds.contains(p.id)).toList();
});
