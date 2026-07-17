import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/widgets/custom_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/address_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../models/product_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  AddressModel? _selectedAddress;
  bool _isApplyHovered = false;
  bool _showPromoField = false;

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
          child: SingleChildScrollView(
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
              cartState.isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                    )
                  : cartState.errorMessage != null
                      ? SizedBox(
                          height: 200,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_off, size: 64, color: Color(0xFFFF4D6D)),
                                  const SizedBox(height: 12),
                                  Text(cartState.errorMessage!, textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    text: 'Retry',
                                    icon: Icons.refresh,
                                    onPressed: () => ref.read(cartProvider.notifier).reload(),
                                    width: 140,
                                    height: 44,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : cartState.items.isEmpty
                          ? SizedBox(
                              height: 350,
                              child: Center(
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
                                      CustomButton(
                                        text: 'Browse Produce',
                                        onPressed: () => context.pop(),
                                        width: 180,
                                        height: 46,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 312.0,
                              ),
                              child: RefreshIndicator(
                                color: const Color(0xFF2E7D32),
                                onRefresh: () => ref.read(cartProvider.notifier).reload(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.05)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPromoField = !_showPromoField;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_offer_outlined, color: Color(0xFFE28C43), size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Have a Promo Code?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: const Color(0xFF2E7D32),
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
                                        'Applied!',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Icon(
                                _showPromoField ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: const Color(0xFF2E7D32),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showPromoField)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                          child: Row(
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
                        ),
                    ],
                  ),
                ),
              ],

              // Price summary & checkout matching Demo App
              _buildPriceSummary(cartState, addressState),

              // You May Also Like Section
              if (cartState.items.isNotEmpty)
                _buildRecommendations(context, ref),
            ],
          ),
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
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: const [
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
                          CustomButton(
                            text: 'Add New Address',
                            icon: Icons.add,
                            isOutlined: true,
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/add-address');
                            },
                            height: 46,
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
          CustomButton(
            text: 'Checkout Order',
            onPressed: _checkout,
            height: 48,
          ),
        ],
      ),
    ),
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

  Widget _buildRecommendations(BuildContext context, WidgetRef ref) {
    final recommendations = [
      ProductModel(
        id: 'rec_honey',
        name: 'Fresh Organic Honey',
        price: 240.00,
        originalPrice: 280.00,
        origin: 'Himalayas',
        category: 'Grains & Millets',
        image: '',
        description: 'Pure, organic forest honey harvested raw.',
        weight: '250g',
        stock: 10,
        farmName: 'Sweet Nectar Farms',
        organic: true,
      ),
      ProductModel(
        id: 'rec_strawberries',
        name: 'Fresh Strawberries',
        price: 180.00,
        originalPrice: 200.00,
        origin: 'Mahabaleshwar',
        category: 'Fruits',
        image: '',
        description: 'Sweet, red strawberries picked fresh.',
        weight: '200g',
        stock: 15,
        farmName: 'Strawberry Fields',
        organic: true,
      ),
      ProductModel(
        id: 'rec_avocados',
        name: 'Organic Avocados',
        price: 320.00,
        originalPrice: 350.00,
        origin: 'Ooty',
        category: 'Vegetables',
        image: '',
        description: 'Rich, creamy Hass avocados grown organically.',
        weight: '2 units',
        stock: 8,
        farmName: 'Green Valley Farms',
        organic: true,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.recommend_outlined, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Text(
                  'You May Also Like',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF23312B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F8F4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.id == 'rec_honey'
                                  ? '🍯'
                                  : item.id == 'rec_strawberries'
                                      ? '🍓'
                                      : '🥑',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).addItem(item);
                              showAppSnackBar(
                                context,
                                'Added ${item.name} to Basket!',
                                type: SnackBarType.success,
                              );
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE8F5E9),
                              ),
                              child: const Icon(Icons.add, size: 12, color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        item.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: const Color(0xFF23312B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.farmName,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF647C72),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.price.toStringAsFixed(2)} / ${item.weight}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
