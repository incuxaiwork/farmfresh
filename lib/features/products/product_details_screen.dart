import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../models/cart_item_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/widgets/product_card.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final ProductModel? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final cartState = ref.watch(cartProvider);
    final productState = ref.watch(productProvider);

    final cartItem = cartState.items.firstWhere(
      (item) => item.product.id == product!.id,
      orElse: () => CartItemModel(product: product!, quantity: 0),
    );

    // Get related products from the same category
    final relatedProducts = productState.products
        .where((p) => p.category == product!.category && p.id != product!.id)
        .toList();

    final isOrganic = product!.organic;
    final hasDiscount = product!.originalPrice > product!.price;

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share Link copied to Clipboard!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to Wishlist (Placeholder)')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel (Using PageView)
            SizedBox(
              height: 250,
              width: double.infinity,
              child: PageView.builder(
                itemCount: 3, // Simulate multiple images carousel
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: product!.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.green[50],
                      child: const Icon(Icons.spa, size: 100, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product!.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green[100]!),
                              ),
                              child: Text(
                                product!.category,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${product!.price.toStringAsFixed(2)} / ${product!.weight}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700]),
                          ),
                          if (hasDiscount)
                            Text(
                              '₹${product!.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${product!.rating.toStringAsFixed(1)} (${product!.reviewCount} reviews)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      Text(product!.origin),
                      if (isOrganic) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.eco, color: Colors.green, size: 20),
                        const SizedBox(width: 4),
                        const Text('Organic', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  const Divider(height: 32),

                  // Crop Freshness & Timing badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailBadge('HARVESTED', 'Today'),
                      _buildDetailBadge('EXPIRES', 'in 7 Days'),
                      _buildDetailBadge('AVAILABILITY', product!.stock > 0 ? 'In Stock' : 'Out of Stock', color: product!.stock > 0 ? Colors.green : Colors.red),
                    ],
                  ),
                  const Divider(height: 32),

                  // Farmer business Card
                  const Text(
                    'Producer Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: const Icon(Icons.person, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product!.farmName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text('Local Verified Grower', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified KYC',
                              style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // Nutrition Info
                  const Text(
                    'Nutritional Value (Approx. per 100g)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutriBadge('Calories', product!.calories),
                      _buildNutriBadge('Protein', product!.protein),
                      _buildNutriBadge('Fat', product!.fat),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product!.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const Divider(height: 32),

                  // Related Products Section
                  if (relatedProducts.isNotEmpty) ...[
                    const Text(
                      'Related Fresh Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final prod = relatedProducts[index];
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            child: ProductCard(
                              product: prod,
                              onTap: () {
                                context.push('/product/${prod.id}', extra: prod);
                              },
                              onAddToCart: () {
                                ref.read(cartProvider.notifier).addItem(prod);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${prod.name} to Cart')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 32),
                  ],

                  // Action Buttons Row
                  Row(
                    children: [
                      if (cartItem.quantity > 0) ...[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 36, color: Colors.green),
                          onPressed: () {
                            ref.read(cartProvider.notifier).removeItem(product!.id);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: product!.stock <= 0 ? null : () {
                            ref.read(cartProvider.notifier).addItem(product!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${product!.name} to Cart!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            product!.stock <= 0
                                ? 'Out of Stock'
                                : (cartItem.quantity > 0 ? 'Add More' : 'Add to Cart'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Buy Now Button
                      ElevatedButton(
                        onPressed: product!.stock <= 0 ? null : () {
                          ref.read(cartProvider.notifier).addItem(product!);
                          context.push('/cart');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.green[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
