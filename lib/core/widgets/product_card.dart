import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/wishlist_provider.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(widget.product.id);
    final hasDiscount = widget.product.originalPrice > widget.product.price;
    final isOrganic = widget.product.organic;
    final isOutOfStock = widget.product.stock <= 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F2E5C45),
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Crop Image & Badges
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.image,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF1F8F4),
                            child: const Icon(Icons.spa, color: Color(0xFF2E7D32), size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Organic Leaf / Discount Tag
                  if (isOrganic)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ORGANIC',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF2E7D32),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  else if (hasDiscount && widget.product.discount != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5D9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.product.discount!,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFD04A02),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist heart icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(!isWishlisted
                                  ? 'Saved ${widget.product.name} to wishlist!'
                                  : 'Removed ${widget.product.name} from wishlist.'),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? const Color(0xFFE63946) : const Color(0xFF647C72),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Out of Stock Overlay
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE63946),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'OUT OF STOCK',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details Block
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: const Color(0xFF23312B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.product.farmName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: const Color(0xFF647C72),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${widget.product.price.toStringAsFixed(2)} / ${widget.product.weight}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF23312B),
                                fontSize: 12,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '₹${widget.product.originalPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: const Color(0xFF647C72),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: isOutOfStock ? null : widget.onAddToCart,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFECECEC)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 12,
                              color: Color(0xFF23312B),
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
    );
  }
}
