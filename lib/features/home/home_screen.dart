import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_image_provider.dart';
import '../../core/utils/app_snackbar.dart';
import 'dart:convert';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  void _showCategoryBottomSheet() {
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
                'Select Category',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Text('🌱'),
                ),
                title: Text('All Products', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products?category=All');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFAD2E1),
                  child: Text('🍎'),
                ),
                title: Text('Fruits', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products?category=Fruits');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF6EC),
                  child: Text('🥕'),
                ),
                title: Text('Vegetables', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products?category=Vegetables');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE5D9),
                  child: Text('🌾'),
                ),
                title: Text('Grains & Millets', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products?category=Grains & Millets');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF1E6),
                  child: Text('🥛'),
                ),
                title: Text('Dairy', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/products?category=Dairy');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final addressState = ref.watch(addressProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profileImage = user != null ? ref.watch(profileImageProvider(user.id)) : null;
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.itemCount;
    final defaultAddr = addressState.defaultAddress;
    final locationLabel = defaultAddr != null
        ? '${defaultAddr.city ?? defaultAddr.street}, ${defaultAddr.state ?? defaultAddr.country ?? 'India'}'
        : 'Bengaluru, India';

    // Filter products based on search query and category (using broad substring match)
    final filteredProducts = productState.products.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // transparent to let the gradient shell show through
      body: productState.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Color(0xFFE63946)),
                    const SizedBox(height: 12),
                    Text(productState.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(productProvider.notifier).loadProducts(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE28C43),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : productState.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : RefreshIndicator(
                  color: const Color(0xFF2E7D32),
                  onRefresh: () => ref.read(productProvider.notifier).loadProducts(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top curved U-shape background container with custom gradient
                          ClipPath(
                            clipper: UHeaderClipper(),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFEBF3EE),
                                    Color(0xFFFCF5EF),
                                    Color(0xFFE8F0FE),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 48.0),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Custom location & user header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
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
                                          child: const Icon(Icons.location_on, color: Color(0xFFE28C43), size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Location',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                color: const Color(0xFF647C72),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              locationLabel,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF23312B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Shopping Cart button with badge counter
                                        GestureDetector(
                                          onTap: () {
                                            context.push('/cart');
                                          },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x0F2E5C45),
                                                      offset: Offset(0, 2),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32), size: 18),
                                                ),
                                              ),
                                              if (cartItemCount > 0)
                                                Positioned(
                                                  top: -2,
                                                  right: -2,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(3),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFE63946),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 14,
                                                      minHeight: 14,
                                                    ),
                                                    child: Text(
                                                      '$cartItemCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // User profile avatar
                                        GestureDetector(
                                          onTap: () {
                                            context.push('/profile');
                                          },
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x0F2E5C45),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: profileImage != null && profileImage.image.startsWith('data:image')
                                                  ? Transform.translate(
                                                      offset: Offset(profileImage.dx, profileImage.dy),
                                                      child: Transform.scale(
                                                        scale: profileImage.scale,
                                                        child: Image.memory(
                                                          base64Decode(profileImage.image.split(',')[1]),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  : Image.network(
                                                      'https://api.dicebear.com/7.x/adventurer/svg?seed=Lucky',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E7D32).withOpacity(0.06),
                                        offset: const Offset(0, 4),
                                        blurRadius: 16,
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.12), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  height: 52,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, color: Color(0xFF2E7D32), size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (val) {
                                            setState(() {
                                              _searchQuery = val;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search fresh products...',
                                            hintStyle: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF647C72),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            filled: false,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                            isDense: true,
                                          ),
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF1B2E25),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showCategoryBottomSheet,
                                        child: const Icon(Icons.category_outlined, color: Color(0xFF647C72), size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Category Pills Scroll Block
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCategoryPill('All', '🌱', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                                    _buildCategoryPill('Fruits', '🍎', const Color(0xFFFAD2E1), const Color(0xFFC9184A)),
                                    _buildCategoryPill('Vegetables', '🥕', const Color(0xFFEAF6EC), const Color(0xFF2E7D32)),
                                    _buildCategoryPill('Meat', '🥩', const Color(0xFFFFE5D9), const Color(0xFFD04A02)),
                                    _buildCategoryPill('Dairy', '🥛', const Color(0xFFFFF1E6), const Color(0xFFE28C43)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                          // Rest of the content wrapped in padding
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // Promo Banners Carousel
                                SizedBox(
                                  height: 120,
                                  child: PageView(
                                    children: [
                                      _buildPromoCard(
                                        badge: 'OFFER',
                                        title: '50% Off First Harvest',
                                        subtitle: 'Use coupon code SAVE50 at checkout!',
                                        emoji: '🎉',
                                        bgColor: const Color(0xFFFAF4EF),
                                        accentColor: const Color(0xFFE28C43),
                                      ),
                                      _buildPromoCard(
                                        badge: 'FREE DELIVERY',
                                        title: 'Free Local Delivery',
                                        subtitle: 'On fresh orders above ₹1600.00',
                                        emoji: '🚚',
                                        bgColor: const Color(0xFFEAF3EE),
                                        accentColor: const Color(0xFF2E7D32),
                                      ),
                                      _buildPromoCard(
                                        badge: 'FARM TO DOOR',
                                        title: 'Support Local Farmers',
                                        subtitle: '100% organic directly from local fields.',
                                        emoji: '👩‍🌾',
                                        bgColor: const Color(0xFF1E2C26),
                                        accentColor: const Color(0xFFFFF1E6),
                                        isDark: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Popular Items Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Popular Items',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF23312B),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.push('/products');
                                      },
                                      child: Text(
                                        'See All',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF647C72),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Products Grid
                                filteredProducts.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 40),
                                          child: Text(
                                            'No products match your search or filter criteria.',
                                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)),
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 0.78,
                                        ),
                                        itemCount: filteredProducts.length,
                                        itemBuilder: (context, index) {
                                          final prod = filteredProducts[index];
                                          return ProductCard(
                                            product: prod,
                                            onTap: () {
                                              context.push('/product-details', extra: prod);
                                            },
                                            onAddToCart: () {
                                              ref.read(cartProvider.notifier).addItem(prod);
                                              showAppSnackBar(
                                                context,
                                                'Added ${prod.name} to Cart',
                                                type: SnackBarType.success,
                                                actionLabel: 'Cart',
                                                onAction: () {
                                                  context.push('/cart');
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                const SizedBox(height: 24),
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

  Widget _buildCategoryPill(String name, String emoji, Color iconBgColor, Color activeColor) {
    final isActive = _selectedCategory.toLowerCase() == name.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = name;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor.withOpacity(0.15) : const Color(0xFFF1F8F4),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
              color: isActive ? activeColor : const Color(0xFF1B2E25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String badge,
    required String title,
    required String subtitle,
    required String emoji,
    required Color bgColor,
    required Color accentColor,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFE28C43) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isDark ? Colors.white70 : const Color(0xFF647C72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }
}

class UHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    if (size.width <= 0 || size.height <= 40) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15, // Dips down in the center to create a premium U-shape arc
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
