import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/address_model.dart';
import '../../core/utils/app_snackbar.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  AddressModel? _selectedAddress;
  bool _isApplyHovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressProvider.notifier).loadAddresses();
    });
  }

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
      showAppSnackBar(
        context,
        'Coupon "$code" applied successfully!',
        type: SnackBarType.success,
      );
    } else {
      showAppSnackBar(
        context,
        'Invalid coupon code',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _checkout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    if (_selectedAddress == null) {
      showAppSnackBar(
        context,
        'Please select or add a delivery address first!',
        type: SnackBarType.error,
      );
      return;
    }

    final fullAddress = _selectedAddress!.fullAddress;

    final createdOrder = await ref.read(orderProvider.notifier).createOrder(
      items: cartState.items,
      total: cartState.grandTotal,
      deliveryFee: cartState.deliveryFee,
      address: fullAddress,
    );

    if (!mounted) return;

    if (createdOrder != null) {
      showAppSnackBar(
        context,
        'Order #${createdOrder.orderNumber.isNotEmpty ? createdOrder.orderNumber : createdOrder.id} placed successfully!',
        type: SnackBarType.success,
      );
      ref.read(cartProvider.notifier).clearCart();
      context.go('/customer-main');
    } else {
      showAppSnackBar(
        context,
        'Failed to place order',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final addressState = ref.watch(addressProvider);
    final defaultAddress = addressState.defaultAddress;

    if (_selectedAddress == null && defaultAddress != null) {
      _selectedAddress = defaultAddress;
    }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_offer_outlined, color: Color(0xFFE28C43), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Promo / Coupon Code',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          if (cartState.couponCode != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                              ),
                              child: Text(
                                '${cartState.couponCode} Applied!',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAF8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: cartState.couponCode != null
                                      ? const Color(0xFF2E7D32).withOpacity(0.3)
                                      : const Color(0xFFECECEC),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: TextField(
                                  controller: _couponController,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF23312B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: cartState.couponCode != null
                                        ? 'Active Code: ${cartState.couponCode}'
                                        : 'Enter code (e.g. SAVE50)',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF8D99AE),
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    filled: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          MouseRegion(
                            onEnter: (_) => setState(() => _isApplyHovered = true),
                            onExit: (_) => setState(() => _isApplyHovered = false),
                            child: GestureDetector(
                              onTap: cartState.couponCode != null
                                  ? () {
                                      ref.read(cartProvider.notifier).removeCoupon();
                                      _couponController.clear();
                                    }
                                  : _applyCoupon,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.all(_isApplyHovered ? 3.0 : 0.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: _isApplyHovered
                                        ? (cartState.couponCode != null ? const Color(0xFFFF4D6D).withOpacity(0.3) : const Color(0xFF2E7D32).withOpacity(0.3))
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  transform: Matrix4.identity()..scale(_isApplyHovered ? 1.03 : 1.0),
                                  transformAlignment: Alignment.center,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: cartState.couponCode != null
                                        ? null
                                        : LinearGradient(
                                            colors: _isApplyHovered
                                                ? [const Color(0xFF2E7D32), const Color(0xFF1B4332)]
                                                : [const Color(0xFFE28C43), const Color(0xFFF3A05B)],
                                          ),
                                    color: cartState.couponCode != null
                                        ? (_isApplyHovered ? const Color(0xFFFFCCD5) : const Color(0xFFFFF0F3))
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cartState.couponCode != null
                                            ? const Color(0xFFFF4D6D).withOpacity(_isApplyHovered ? 0.2 : 0.05)
                                            : (_isApplyHovered
                                                ? const Color(0xFF2E7D32).withOpacity(0.35)
                                                : const Color(0xFFE28C43).withOpacity(0.2)),
                                        offset: const Offset(0, 4),
                                        blurRadius: _isApplyHovered ? 12 : 8,
                                        spreadRadius: _isApplyHovered ? 2 : 0,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _isApplyHovered
                                          ? (cartState.couponCode != null ? const Color(0xFFFF4D6D) : const Color(0xFF2E7D32))
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cartState.couponCode != null ? 'Remove' : 'Apply',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: cartState.couponCode != null
                                          ? const Color(0xFFFF4D6D)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
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

                // Price summary & checkout matching Demo App
                _buildPriceSummary(cartState, addressState),
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

  Widget _buildPriceSummary(CartState cartState, AddressState addressState) {
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

          // Address Selection widget
          GestureDetector(
            onTap: () async {
              if (addressState.addresses.isEmpty) {
                context.push('/add-address');
              } else {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Delivery Address',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: addressState.addresses.length,
                              itemBuilder: (context, index) {
                                final addr = addressState.addresses[index];
                                return ListTile(
                                  title: Text(addr.street),
                                  subtitle: Text('${addr.city ?? ''}, ${addr.state ?? ''} - ${addr.zipCode ?? ''}'),
                                  trailing: _selectedAddress?.id == addr.id
                                      ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedAddress = addr;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/add-address');
                              },
                              icon: const Icon(Icons.add, color: Color(0xFF2E7D32)),
                              label: const Text('Add New Address', style: TextStyle(color: Color(0xFF2E7D32))),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFFE28C43), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: const Color(0xFF23312B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedAddress != null
                              ? '${_selectedAddress!.street}, ${_selectedAddress!.city ?? ""}'
                              : 'No address selected. Tap to add/select.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF647C72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF647C72), size: 20),
                ],
              ),
            ),
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
