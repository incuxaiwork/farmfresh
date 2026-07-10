import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        const SnackBar(
          content: Text('Coupon SAVE50 applied! 50% discount active.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code'), backgroundColor: Colors.red),
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
            'Order #${createdOrder.id} placed! Verification OTP: ${createdOrder.otp}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      ref.read(cartProvider.notifier).clearCart();
      context.go('/customer-main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    if (cartState.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (cartState.errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text(cartState.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.read(cartProvider.notifier).reload(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (cartState.items.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Your Cart is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Browse products and add them to your cart', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push('/products'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('Browse Produce'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(cartState.itemCount),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(cartProvider.notifier).reload(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: cartState.items.length,
                itemBuilder: (context, index) {
                  return _buildCartItemCard(cartState.items[index]);
                },
              ),
            ),
          ),

          // Coupon section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: cartState.couponCode != null
                          ? 'Coupon Applied: ${cartState.couponCode}'
                          : 'Enter Promo Code (e.g. SAVE50)',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: cartState.couponCode != null
                      ? () {
                          ref.read(cartProvider.notifier).removeCoupon();
                          _couponController.clear();
                        }
                      : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartState.couponCode != null ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: Text(cartState.couponCode != null ? 'Remove' : 'Apply'),
                ),
              ],
            ),
          ),

          // Price summary & checkout
          _buildPriceSummary(cartState),
        ],
      ),
    );
  }

  AppBar _buildAppBar(int itemCount) {
    return AppBar(
      title: itemCount > 0
          ? Text('My Cart ($itemCount ${itemCount == 1 ? "item" : "items"})')
          : const Text('My Cart'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      actions: [
        if (itemCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text('This will remove all items from your cart.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(cartProvider.notifier).clearCart();
              }
            },
          ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItemModel item) {
    final hasImage = item.product.image.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Product thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: item.product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.green[50],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => _productFallbackIcon(item),
                      )
                    : _productFallbackIcon(item),
              ),
            ),
            const SizedBox(width: 12),
            // Name / farm / price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    item.product.farmName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)} / ${item.product.weight}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      if (item.product.origin.toLowerCase() == 'organic') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.eco, color: Colors.green, size: 14),
                      ],
                    ],
                  ),
                  Text(
                    'Item total: \$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () => ref.read(cartProvider.notifier).increaseQuantity(item),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    item.quantity > 1 ? Icons.remove_circle_outline : Icons.delete_outline,
                    color: item.quantity > 1 ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    if (item.quantity > 1) {
                      ref.read(cartProvider.notifier).decreaseQuantity(item);
                    } else {
                      ref.read(cartProvider.notifier).deleteItemCompletely(item.product.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
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
      color: Colors.green[50],
      child: Icon(icon, color: Colors.green, size: 32),
    );
  }

  Widget _buildPriceSummary(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', '\$${cartState.subtotal.toStringAsFixed(2)}'),
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _priceRow(
              cartState.couponCode != null
                  ? 'Discount (${(cartState.discountPercent * 100).toInt()}% OFF)'
                  : 'Discount',
              '-\$${cartState.discountAmount.toStringAsFixed(2)}',
              valueColor: Colors.orange,
            ),
          ],
          const SizedBox(height: 6),
          _priceRow(
            'Delivery',
            cartState.deliveryFee == 0.0 ? 'FREE' : '\$${cartState.deliveryFee.toStringAsFixed(2)}',
            valueColor: cartState.deliveryFee == 0.0 ? Colors.green : Colors.black,
          ),
          const SizedBox(height: 6),
          _priceRow(
            'Tax (5%)',
            '\$${cartState.tax.toStringAsFixed(2)}',
            valueColor: Colors.grey[700],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '\$${cartState.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Checkout Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black),
        ),
      ],
    );
  }
}
