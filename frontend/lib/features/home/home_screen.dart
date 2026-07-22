import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/category_icons.dart';
import '../../core/widgets/user_avatar_widget.dart';
import '../../models/product_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  final PageController _bannerPageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

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
              _buildBottomSheetListTile('All Products', const Color(0xFFE8F5E9), 'All'),
              _buildBottomSheetListTile('Fruits', const Color(0xFFFAD2E1), 'Fruits'),
              _buildBottomSheetListTile('Vegetables', const Color(0xFFEAF6EC), 'Vegetables'),
              _buildBottomSheetListTile('Grains & Millets', const Color(0xFFFFE5D9), 'Grains & Millets'),
              _buildBottomSheetListTile('Dairy', const Color(0xFFFFF1E6), 'Dairy'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetListTile(String title, Color bgColor, String category) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: CategoryIcons.getSvgWidget(category, size: 24),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(context);
        context.push('/products?category=$category');
      },
    );
  }

  void _showFilterBottomSheet() {
    String tempCategory = 'All';
    String tempSort = 'newest';
    bool tempOrganic = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort Products',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF647C72)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Category Selection
                  Text(
                    'Category',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Fruits', 'Vegetables', 'Dairy', 'Meat', 'Grains'].map((cat) {
                      final isSelected = tempCategory == cat;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF23312B),
                        ),
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: const Color(0xFFF2F6F3),
                        onSelected: (selected) {
                          setModalState(() {
                            tempCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Sort Options
                  Text(
                    'Sort By',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      {'label': 'Newest', 'val': 'newest'},
                      {'label': 'Price: Low to High', 'val': 'price_asc'},
                      {'label': 'Price: High to Low', 'val': 'price_desc'},
                      {'label': 'Highest Rated', 'val': 'rating'},
                    ].map((opt) {
                      final isSelected = tempSort == opt['val'];
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(opt['label']!),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF23312B),
                        ),
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: const Color(0xFFF2F6F3),
                        onSelected: (selected) {
                          setModalState(() {
                            tempSort = opt['val']!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Organic Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🌿', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Organic Only',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: tempOrganic,
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (val) {
                          setModalState(() {
                            tempOrganic = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final catParam = tempCategory == 'All' ? '' : tempCategory;
                        context.push(
                          '/products?category=$catParam&search=$_searchQuery',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    final wishlistIds = ref.watch(wishlistProvider);
    final wishlistCount = wishlistIds.length;
    final defaultAddr = addressState.defaultAddress;
    final locationLabel = defaultAddr != null
        ? '${defaultAddr.city ?? defaultAddr.street}, ${defaultAddr.state ?? defaultAddr.country ?? 'India'}'
        : 'Bengaluru, India';

    final allProducts = productState.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Derived lists
    final freshNearYou = allProducts.take(8).toList();
    final todayDeals = allProducts.where((p) => p.discount != null).toList();
    final organicPicks = allProducts.where((p) => p.organic == true).toList();
    
    // Unique farmers derived from products
    return Scaffold(
      backgroundColor: Colors.transparent, 
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
                          // Top Header
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
                              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.push('/addresses'),
                                      child: Row(
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
                                              Row(
                                                children: [
                                                  Text(
                                                    'Delivering to',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      color: const Color(0xFF647C72),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0xFF647C72)),
                                                ],
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
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => context.push('/notifications'),
                                          child: const Icon(Icons.notifications_outlined, color: Color(0xFF23312B), size: 26),
                                        ),
                                        const SizedBox(width: 12),
                                        // Wishlist heart icon with badge
                                        GestureDetector(
                                          onTap: () => context.push('/wishlist'),
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
                                                  child: Icon(Icons.favorite_border_rounded, color: Color(0xFFE63946), size: 18),
                                                ),
                                              ),
                                              if (wishlistCount > 0)
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
                                                      '$wishlistCount',
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
                                        UserAvatarWidget(
                                          user: user,
                                          size: 38,
                                          onTap: () => context.push('/profile'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                 const SizedBox(height: 16),
                                 // Search Bar (matches reference image)
                                 Container(
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFEAF3EB),
                                     borderRadius: BorderRadius.circular(28),
                                   ),
                                   padding: const EdgeInsets.symmetric(horizontal: 20),
                                   height: 52,
                                   child: Row(
                                     children: [
                                       Expanded(
                                         child: TextField(
                                           onChanged: (val) {
                                             setState(() {
                                               _searchQuery = val;
                                             });
                                           },
                                           decoration: InputDecoration(
                                             hintText: 'Search products...',
                                             hintStyle: GoogleFonts.plusJakartaSans(
                                               color: const Color(0xFF759584),
                                               fontSize: 15,
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
                                             fontSize: 15,
                                             fontWeight: FontWeight.w600,
                                           ),
                                         ),
                                       ),
                                        GestureDetector(
                                          onTap: _showFilterBottomSheet,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.tune_rounded, color: Color(0xFF567866), size: 24),
                                            ),
                                          ),
                                        ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),

                         const SizedBox(height: 16),

                         // Categories Section inside White Card Container (matches reference image)
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.circular(24),
                                   boxShadow: [
                                     BoxShadow(
                                       color: const Color(0xFF2E7D32).withOpacity(0.05),
                                       blurRadius: 12,
                                       offset: const Offset(0, 4),
                                     ),
                                   ],
                                 ),
                                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                   children: [
                                     _buildExactCategoryItem('All', true),
                                     _buildExactCategoryItem('Fruits', false),
                                     _buildExactCategoryItem('Vegetables', false),
                                     _buildExactCategoryItem('Meat', false),
                                     _buildExactCategoryItem('Dairy', false),
                                   ],
                                 ),
                               ),
                               const SizedBox(height: 24),

                               // Promo Banners Carousel (matches reference image)
                               SizedBox(
                                 height: 136,
                                 child: PageView(
                                   controller: _bannerPageController,
                                   padEnds: false,
                                   children: [
                                     _buildExactBannerCard(
                                       badge: 'FREE DELIVERY',
                                       title: 'Free Local Delivery',
                                       subtitle: 'On all fresh farm orders above \$20.00 / Rs. 1,600.00',
                                       bgColor: const Color(0xFF236B38),
                                       illustration: CategoryIcons.promoFreeDelivery,
                                     ),
                                     _buildExactBannerCard(
                                       badge: 'FARM TO TABLE',
                                       title: 'Support Local Farmers',
                                       subtitle: '100% organic, sourced directly from local farms',
                                       bgColor: const Color(0xFF181818),
                                       illustration: CategoryIcons.promoFreshHarvest,
                                     ),
                                   ],
                                 ),
                               ),
                               const SizedBox(height: 24),
                             ],
                           ),
                         ),  

                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildProductGrid(allProducts),
                          )
                        else ...[
                          // Fresh Near You
                          _buildHorizontalSection(
                            title: 'Fresh Near You',
                            products: freshNearYou,
                            onSeeAll: () => context.push('/products'),
                          ),

                          // Today's Deals
                          if (todayDeals.isNotEmpty)
                            _buildHorizontalSection(
                              title: "Today's Deals",
                              products: todayDeals,
                              onSeeAll: () => context.push('/products?discount=true'),
                            ),

                          // Organic Picks
                          if (organicPicks.isNotEmpty)
                            _buildHorizontalSection(
                              title: '🌿 Organic Picks',
                              products: organicPicks,
                              onSeeAll: () => context.push('/products?category=Organic'),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTapSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23312B),
          ),
        ),
        if (onTapSeeAll != null)
          GestureDetector(
            onTap: onTapSeeAll,
            child: Row(
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF647C72),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<ProductModel> products,
    required VoidCallback onSeeAll,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader(title, onTapSeeAll: onSeeAll),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Enough height for ProductCard
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final prod = products[index];
              return SizedBox(
                width: 160,
                child: ProductCard(
                  product: prod,
                  onTap: () {
                    context.push('/product-details/${prod.id}', extra: prod);
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }



  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No products match your search.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return ProductCard(
          product: prod,
          onTap: () {
            context.push('/product-details/${prod.id}', extra: prod);
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
    );
  }

  /// Category item widget with neat 3D real food photos and interactive hover animation
  Widget _buildExactCategoryItem(String name, bool isSelected) {
    final Map<String, Map<String, String>> categoryData = {
      'all': {
        'asset': 'assets/images/cat_all.jpg',
        'url': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300&auto=format&fit=crop&q=80',
      },
      'fruits': {
        'asset': 'assets/images/cat_fruits.jpg',
        'url': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&auto=format&fit=crop&q=80',
      },
      'vegetables': {
        'asset': 'assets/images/cat_vegetables.jpg',
        'url': 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=300&auto=format&fit=crop&q=80',
      },
      'meat': {
        'asset': 'assets/images/cat_meat.jpg',
        'url': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300&auto=format&fit=crop&q=80',
      },
      'dairy': {
        'asset': 'assets/images/cat_dairy.jpg',
        'url': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=300&auto=format&fit=crop&q=80',
      },
    };

    final data = categoryData[name.toLowerCase()] ?? {
      'asset': 'assets/images/cat_all.jpg',
      'url': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300&auto=format&fit=crop&q=80',
    };

    return _CategoryHoverItem(
      name: name,
      isSelected: isSelected,
      assetPath: data['asset']!,
      networkUrl: data['url']!,
      onTap: () {
        if (name == 'All') {
          context.push('/products');
        } else {
          context.push('/products?category=$name');
        }
      },
    );
  }

  /// Banner card widget matching the reference image
  Widget _buildExactBannerCard({
    required String badge,
    required String title,
    required String subtitle,
    required Color bgColor,
    required String illustration,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            height: 72,
            child: SvgPicture.asset(
              illustration,
              fit: BoxFit.contain,
            ),
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
    if (size.width <= 0 || size.height <= 24) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      size.width,
      size.height - 24,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CategoryHoverItem extends StatefulWidget {
  final String name;
  final bool isSelected;
  final String assetPath;
  final String networkUrl;
  final VoidCallback onTap;

  const _CategoryHoverItem({
    required this.name,
    required this.isSelected,
    required this.assetPath,
    required this.networkUrl,
    required this.onTap,
  });

  @override
  State<_CategoryHoverItem> createState() => _CategoryHoverItemState();
}

class _CategoryHoverItemState extends State<_CategoryHoverItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2E7D32);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered ? 1.12 : 1.0),
          transformAlignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? const Color(0xFFE4F3E8)
                      : (_isHovered ? const Color(0xFFEAF5ED) : const Color(0xFFF2F6F3)),
                  border: Border.all(
                    color: widget.isSelected
                        ? activeColor
                        : (_isHovered ? activeColor.withOpacity(0.5) : Colors.transparent),
                    width: widget.isSelected ? 2.5 : (_isHovered ? 2.0 : 0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? activeColor.withOpacity(0.25)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: _isHovered ? 12 : 6,
                      offset: Offset(0, _isHovered ? 5 : 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.networkUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: widget.isSelected ? const Color(0xFFE4F3E8) : const Color(0xFFF2F6F3),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: activeColor),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        widget.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) {
                          return const Center(
                            child: Icon(Icons.local_grocery_store, color: activeColor, size: 26),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: (widget.isSelected || _isHovered)
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: (widget.isSelected || _isHovered)
                      ? activeColor
                      : const Color(0xFF23312B),
                ),
                child: Text(widget.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
