import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistProducts = ref.watch(wishlistProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: wishlistProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.green[200]),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Wishlist is Empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore fresh products and add them to your wishlist.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistProducts.length,
              itemBuilder: (context, index) {
                final prod = wishlistProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      context.push('/product-details', extra: prod);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: prod.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.green[50],
                              child: const Icon(Icons.spa, color: Colors.green),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      prod.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                                      onPressed: () {
                                        ref.read(wishlistProvider.notifier).toggleWishlist(prod.id);
                                      },
                                    ),
                                  ],
                                ),
                                Text(prod.farmName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${prod.price.toStringAsFixed(2)} / ${prod.weight}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart, color: Colors.green, size: 20),
                                      onPressed: prod.stock <= 0
                                          ? null
                                          : () {
                                              ref.read(cartProvider.notifier).addItem(prod);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Added ${prod.name} to Cart')),
                                              );
                                            },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
