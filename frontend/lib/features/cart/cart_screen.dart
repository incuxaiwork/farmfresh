import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import '../../core/widgets/custom_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/product_provider.dart';
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
  bool _isLocatingAddress = false;

  Future<void> _useCurrentLocationForCart() async {
    setState(() => _isLocatingAddress = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showAppSnackBar(context, 'Location services are disabled on your device.', type: SnackBarType.error);
        }
        setState(() => _isLocatingAddress = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            showAppSnackBar(context, 'Location permissions were denied.', type: SnackBarType.error);
          }
          setState(() => _isLocatingAddress = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showAppSnackBar(context, 'Location permissions are permanently denied.', type: SnackBarType.error);
        }
        setState(() => _isLocatingAddress = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {'User-Agent': 'FarmFreshApp/1.0'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final road = address['road'] ?? address['pedestrian'] ?? address['suburb'] ?? address['neighbourhood'] ?? address['residential'] ?? '';
        final houseNumber = address['house_number'] ?? address['building'] ?? '';
        final streetParts = [houseNumber, road].where((s) => s.toString().trim().isNotEmpty).join(', ');

        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['state_district'] ?? '';
        final state = address['state'] ?? '';
        final postcode = address['postcode'] ?? '';
        final country = address['country'] ?? 'India';

        final newAddr = AddressModel(
          id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
          label: 'Current Location',
          street: streetParts.isNotEmpty ? streetParts : 'Current GPS Location',
          city: city.toString().isNotEmpty ? city.toString() : 'Current Area',
          state: state.toString().isNotEmpty ? state.toString() : '',
          zipCode: postcode.toString(),
          country: country.toString(),
          isDefault: true,
        );

        await ref.read(addressProvider.notifier).addAddress(newAddr);

        setState(() {
          _selectedAddress = newAddr;
        });

        if (mounted) {
          showAppSnackBar(context, 'Delivery address set to Current Location!', type: SnackBarType.success);
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Could not fetch location address. Please select address manually.', type: SnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingAddress = false);
      }
    }
  }

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
                          const SizedBox(height: 12),

                          // Quick Use Current Location Button
                          InkWell(
                            onTap: _isLocatingAddress
                                ? null
                                : () async {
                                    Navigator.pop(context);
                                    await _useCurrentLocationForCart();
                                  },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFA5D6A7)),
                              ),
                              child: Row(
                                children: [
                                  if (_isLocatingAddress)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 2),
                                    )
                                  else
                                    const Icon(Icons.my_location, color: Color(0xFF2E7D32), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Use Current Location',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                        Text(
                                          'Auto-detect via GPS',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: const Color(0xFF647C72),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFF2E7D32), size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
    final productState = ref.watch(productProvider);
    final recommendations = productState.products.isNotEmpty
        ? productState.products.take(6).toList()
        : [
            ProductModel(
              id: 'rec_mangoes',
              name: 'Fresh Alphonso Mangoes',
              price: 390.00,
              originalPrice: 450.00,
              origin: 'Ratnagiri',
              category: 'Fruits',
              image: 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=600&q=80',
              description: 'Sweet, organic Alphonso mangoes.',
              weight: '1 kg',
              stock: 50,
              farmName: 'Ratnagiri Farms',
              organic: true,
            ),
            ProductModel(
              id: 'rec_spinach',
              name: 'Fresh Farm Spinach',
              price: 35.00,
              originalPrice: 40.00,
              origin: 'Guntur',
              category: 'Vegetables',
              image: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=600&q=80',
              description: 'Iron-rich organic spinach leaves.',
              weight: '250g',
              stock: 80,
              farmName: 'Green Leaf Farms',
              organic: true,
            ),
            ProductModel(
              id: 'rec_honey',
              name: 'Himalayan Raw Honey',
              price: 340.00,
              originalPrice: 380.00,
              origin: 'Himalayas',
              category: 'Dairy & Honey',
              image: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
              description: 'Unprocessed forest honey from wild hives.',
              weight: '500g',
              stock: 40,
              farmName: 'Wild Bee Farms',
              organic: true,
            ),
            ProductModel(
              id: 'rec_apples',
              name: 'Kashmiri Red Apples',
              price: 195.00,
              originalPrice: 220.00,
              origin: 'Kashmir',
              category: 'Fruits',
              image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=600&q=80',
              description: 'Juicy, naturally sweet red apples.',
              weight: '1 kg',
              stock: 65,
              farmName: 'Valley Fresh Orchards',
              organic: true,
            ),
            ProductModel(
              id: 'rec_turmeric',
              name: 'Lakadong Turmeric',
              price: 105.00,
              originalPrice: 120.00,
              origin: 'Meghalaya',
              category: 'Spices & Herbs',
              image: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=600&q=80',
              description: 'High curcumin organic turmeric powder.',
              weight: '200g',
              stock: 60,
              farmName: 'Spice Garden Organics',
              organic: true,
            ),
          ];

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8F5E9),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You May Also Like',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF23312B),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Recommended fresh organic harvest for your basket',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF647C72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Text(
                    '100% Organic',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return Container(
                  width: 165,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8F1EC), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C2E5C45),
                        offset: Offset(0, 8),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Stack with Fresh Badge
                        Stack(
                          children: [
                            Container(
                              height: 105,
                              width: double.infinity,
                              color: const Color(0xFFF7FAF8),
                              child: item.image.isNotEmpty
                                  ? (item.image.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: item.image,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: const Color(0xFFEAF4EE),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 2),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => const Center(
                                            child: Icon(Icons.eco, color: Color(0xFF81C784), size: 36),
                                          ),
                                        )
                                      : const Center(child: Icon(Icons.eco, color: Color(0xFF81C784), size: 36)))
                                  : const Center(child: Icon(Icons.eco, color: Color(0xFF81C784), size: 36)),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Fresh',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Content Padding
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: const Color(0xFF23312B),
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.weight} • ${item.farmName}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF647C72),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                // Price & Quick Add Button Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${item.price.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (item.originalPrice > item.price)
                                          Text(
                                            '₹${item.originalPrice.toStringAsFixed(0)}',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF9E9E9E),
                                              fontSize: 10,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(cartProvider.notifier).addItem(item);
                                          showAppSnackBar(
                                            context,
                                            'Added ${item.name} to Basket!',
                                            type: SnackBarType.success,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x1F2E7D32),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.add, size: 12, color: Colors.white),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Add',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
          ),
        ],
      ),
    );
  }
}
