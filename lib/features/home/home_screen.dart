import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final cartState = ref.watch(cartProvider);
    final categories = productState.categories;

    final filteredProducts = productState.products.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('FarmFresh', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartState.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartState.items.fold(0, (sum, i) => sum + i.quantity)}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: productState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: () => ref.read(productProvider.notifier).loadProducts(),
              child: CustomScrollView(
                slivers: [
                  // Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search fresh produce...',
                          prefixIcon: const Icon(Icons.search, color: Colors.green),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),

                  // Banner Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 140,
                            child: PageView(
                              controller: _bannerController,
                              onPageChanged: (i) => setState(() => _currentBanner = i),
                              children: [
                                _buildBanner('Farm-to-Table Fresh', 'Locally grown, hand-picked produce delivered daily.', Colors.green, Icons.local_shipping),
                                _buildBanner('Organic Collection', 'Pesticide-free certified organic vegetables & fruits.', Colors.teal, Icons.eco),
                                _buildBanner('Weekly Deals', 'Save up to 30% on seasonal favorites this week.', Colors.orange.shade700, Icons.local_offer),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentBanner == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentBanner == i ? Colors.green : Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isActive = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              width: 72,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: isActive ? Colors.green : Colors.grey[200]!),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(cat),
                                      color: isActive ? Colors.white : Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat,
                                    style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.green : Colors.grey[700]),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Featured Deals
                  if (productState.featuredProducts.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Featured Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => context.push('/products'),
                              child: const Text('See All', style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: productState.featuredProducts.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 160,
                              child: _buildProductCard(productState.featuredProducts[index]),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // All Products Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        _selectedCategory == 'All' ? 'All Products' : _selectedCategory,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (filteredProducts.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No products found', style: TextStyle(color: Colors.grey))),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProductCard(filteredProducts[index]),
                          childCount: filteredProducts.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('fruit')) return Icons.apple;
    if (lower.contains('vegetable') || lower.contains('veg')) return Icons.eco;
    if (lower.contains('dairy') || lower.contains('egg')) return Icons.egg_alt;
    if (lower.contains('grain') || lower.contains('cereal')) return Icons.grain;
    if (lower.contains('herb') || lower.contains('spice')) return Icons.spa;
    if (lower.contains('beverage') || lower.contains('juice')) return Icons.local_cafe;
    return Icons.shopping_basket;
  }

  Widget _buildBanner(String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final hasImage = product.image.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/product-details', extra: product),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: Colors.green[50], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.green[50],
                                child: Icon(_getCategoryIcon(product.category), size: 40, color: Colors.green[300]),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            ),
                            child: Center(
                              child: Icon(_getCategoryIcon(product.category), size: 40, color: Colors.green[300]),
                            ),
                          ),
                  ),
                  if (product.discount != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(product.discount!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (product.organic)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product.farmName, style: TextStyle(fontSize: 10, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        if (product.rating > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text('${product.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                              ),
                              if (product.originalPrice > product.price)
                                Text(
                                  '₹${product.originalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 9, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(cartProvider.notifier).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
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
  }
}
