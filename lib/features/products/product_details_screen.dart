import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Custom Navigation bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0F2E5C45),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
                        ),
                      ),
                      Text(
                        'Product Details',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share Link copied to Clipboard!')),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0F2E5C45),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.share_outlined, color: Color(0xFF23312B), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Details Hero Image Overlapping
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              offset: Offset(0, 10),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CachedNetworkImage(
                            imageUrl: product!.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF1F8F4),
                              child: const Icon(Icons.spa, size: 80, color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Content sheet matching .details-content-sheet
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A2E5C45),
                        offset: Offset(0, -15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF23312B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product!.category.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
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
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF23312B),
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  '₹${product!.originalPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: const Color(0xFF647C72),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Origin & Eco badge row
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Color(0xFFE28C43), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            product!.origin,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF647C72),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (isOrganic) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.eco_outlined, color: Color(0xFF2E7D32), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Organic',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Divider(height: 32, color: Color(0xFFECECEC)),

                      // Crop Freshness & Timing badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailBadge('HARVESTED', 'Today'),
                          _buildDetailBadge('EXPIRES', 'in 7 Days'),
                          _buildDetailBadge(
                            'AVAILABILITY',
                            product!.stock > 0 ? 'In Stock' : 'Out of Stock',
                            color: product!.stock > 0 ? const Color(0xFF2E7D32) : const Color(0xFFE63946),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: Color(0xFFECECEC)),

                      // Producer Information
                      Text(
                        'Producer Information',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF4EF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x1AE28C43)),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF1E6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.agriculture, color: Color(0xFFE28C43)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product!.farmName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: const Color(0xFF23312B),
                                    ),
                                  ),
                                  Text(
                                    'Local Verified Grower',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF647C72),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6EC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Verified',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 32, color: Color(0xFFECECEC)),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product!.description,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF647C72),
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                      const Divider(height: 32, color: Color(0xFFECECEC)),

                      // Related Products Section
                      if (relatedProducts.isNotEmpty) ...[
                        Text(
                          'Related Fresh Products',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF23312B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: relatedProducts.length,
                            itemBuilder: (context, index) {
                              final prod = relatedProducts[index];
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 12),
                                child: ProductCard(
                                  product: prod,
                                  onTap: () {
                                    context.push('/product-details', extra: prod);
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
                        const Divider(height: 32, color: Color(0xFFECECEC)),
                      ],

                      // Bottom Counter and Add-to-cart row
                      Row(
                        children: [
                          if (cartItem.quantity > 0) ...[
                            GestureDetector(
                              onTap: () {
                                ref.read(cartProvider.notifier).removeItem(product!.id);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFECECEC)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove, color: Color(0xFF23312B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${cartItem.quantity}',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF23312B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                ref.read(cartProvider.notifier).addItem(product!);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFECECEC)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, color: Color(0xFF23312B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1FE28C43),
                                    offset: Offset(0, 8),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: product!.stock <= 0
                                    ? null
                                    : () {
                                        ref.read(cartProvider.notifier).addItem(product!);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Added ${product!.name} to Cart!'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  product!.stock <= 0
                                      ? 'Out of Stock'
                                      : (cartItem.quantity > 0 ? 'Add More' : 'Add to Basket'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildDetailBadge(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              color: const Color(0xFF647C72),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color ?? const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
