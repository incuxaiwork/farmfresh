import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/cart_item_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    final success = ref.read(cartProvider.notifier).applyCoupon(code);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon "$code" applied successfully!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code'), backgroundColor: Color(0xFFE63946)),
      );
    }
  }

  Future<void> _checkout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    final createdOrder = await ref.read(orderProvider.notifier).createOrder(
      items: cartState.items,
      total: cartState.grandTotal,
      deliveryFee: cartState.deliveryFee,
    );

    if (!mounted) return;

    if (createdOrder != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #${createdOrder.orderNumber.isNotEmpty ? createdOrder.orderNumber : createdOrder.id} placed successfully!',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
        ),
      );
      ref.read(cartProvider.notifier).clearCart();
      context.go('/customer-main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order'), backgroundColor: Color(0xFFE63946)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

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
          child: Column(
            children: [
              // Custom AppBar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      cartState.itemCount > 0
                          ? 'My Basket (${cartState.itemCount})'
                          : 'My Basket',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF23312B),
                      ),
                    ),
                    if (cartState.items.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Clear Basket?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              content: Text('Remove all items from your shopping basket?', style: GoogleFonts.plusJakartaSans()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Clear All', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(cartProvider.notifier).clearCart();
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF0F3),
                          ),
                          child: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFFF4D6D), size: 18),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),

              // Body Content
              Expanded(
                child: cartState.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                    : cartState.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_off, size: 64, color: Color(0xFFFF4D6D)),
                                  const SizedBox(height: 12),
                                  Text(cartState.errorMessage!, textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () => ref.read(cartProvider.notifier).reload(),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : cartState.items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE8F5E9),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_basket_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Your Basket is Empty',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF23312B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Browse fresh farm products and add them to checkout',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF8D99AE),
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () => context.pop(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Browse Produce',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                color: const Color(0xFF2E7D32),
                                onRefresh: () => ref.read(cartProvider.notifier).reload(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  itemCount: cartState.items.length,
                                  itemBuilder: (context, index) {
                                    return _buildCartItemCard(cartState.items[index]);
                                  },
                                ),
                              ),
              ),

              // Coupon Promo block
              if (cartState.items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.05)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5EDE7).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5EDE7)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 40,
                          child: Center(
                            child: TextField(
                              controller: _couponController,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF23312B),
                              ),
                              decoration: InputDecoration(
                                hintText: cartState.couponCode != null
                                    ? 'Promo Applied: ${cartState.couponCode}'
                                    : 'Enter Promo Code (e.g. SAVE50)',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF647C72),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: cartState.couponCode != null
                            ? () {
                                ref.read(cartProvider.notifier).removeCoupon();
                                _couponController.clear();
                              }
                            : _applyCoupon,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cartState.couponCode != null
                                ? const Color(0xFFFFF0F3)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          child: Text(
                            cartState.couponCode != null ? 'Remove' : 'Apply',
                            style: GoogleFonts.plusJakartaSans(
                              color: cartState.couponCode != null
                                  ? const Color(0xFFFF4D6D)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price summary & checkout matching Demo App
                _buildPriceSummary(cartState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.product.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                      ),
                      errorWidget: (_, __, ___) => _productFallbackIcon(item),
                    )
                  : _productFallbackIcon(item),
            ),
          ),
          const SizedBox(width: 12),

          // Name, farm & price details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF23312B),
                  ),
                ),
                Text(
                  item.product.farmName,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF647C72),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${item.product.price.toStringAsFixed(2)} / ${item.product.weight}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF23312B),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    if (item.product.organic) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Item total: ₹${item.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: const Color(0xFF647C72),
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Column(
            children: [
              GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).increaseQuantity(item),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F8F4),
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  child: const Center(child: Icon(Icons.add, size: 12, color: Color(0xFF2E7D32))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (item.quantity > 1) {
                    ref.read(cartProvider.notifier).decreaseQuantity(item);
                  } else {
                    ref.read(cartProvider.notifier).deleteItemCompletely(item.product.id);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.quantity > 1 ? const Color(0xFFF1F8F4) : const Color(0xFFFFF0F3),
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  child: Center(
                    child: Icon(
                      item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                      size: 12,
                      color: item.quantity > 1 ? const Color(0xFF2E7D32) : const Color(0xFFFF4D6D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productFallbackIcon(CartItemModel item) {
    final cat = item.product.category.toLowerCase();
    IconData icon;
    if (cat.contains('veg')) {
      icon = Icons.spa;
    } else if (cat.contains('fruit')) {
      icon = Icons.apple;
    } else if (cat.contains('dairy')) {
      icon = Icons.egg;
    } else {
      icon = Icons.grain;
    }
    return Container(
      color: const Color(0xFFF1F8F4),
      child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
    );
  }

  Widget _buildPriceSummary(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, -5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _priceRow('Subtotal', '₹${cartState.subtotal.toStringAsFixed(2)}'),
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _priceRow(
              cartState.couponCode != null
                  ? 'Discount (${(cartState.discountPercent * 100).toInt()}% OFF)'
                  : 'Discount',
              '-₹${cartState.discountAmount.toStringAsFixed(2)}',
              valueColor: const Color(0xFFD04A02),
            ),
          ],
          const SizedBox(height: 6),
          _priceRow(
            'Delivery',
            cartState.deliveryFee == 0.0 ? 'FREE' : '₹${cartState.deliveryFee.toStringAsFixed(2)}',
            valueColor: cartState.deliveryFee == 0.0 ? const Color(0xFF2E7D32) : const Color(0xFF23312B),
          ),
          const SizedBox(height: 6),
          _priceRow(
            'Tax (5%)',
            '₹${cartState.tax.toStringAsFixed(2)}',
            valueColor: const Color(0xFF647C72),
          ),
          const Divider(height: 20, color: Color(0xFFECECEC)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
              Text(
                '₹${cartState.grandTotal.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
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
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Checkout Order',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF647C72),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF23312B),
          ),
        ),
      ],
    );
  }
}
