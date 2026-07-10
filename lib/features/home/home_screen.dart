import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final cartState = ref.watch(cartProvider);

    // Categories available
    final categories = productState.categories;

    // Filter products based on search query and category
    final filteredProducts = productState.products.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmFresh Marketplace'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  context.push('/cart');
                },
              ),
              if (cartState.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartState.items.fold(0, (sum, i) => sum + i.quantity)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: productState.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(productState.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(productProvider.notifier).loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : productState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => ref.read(productProvider.notifier).loadProducts(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products or farms...',
                            prefixIcon: const Icon(Icons.search, color: Colors.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Banner Carousel
                        SizedBox(
                          height: 120,
                          child: PageView(
                            children: [
                              _buildBannerCard('Save up to 50%', 'Direct from local farms to your home. Use code SAVE50.', Colors.green[100]!, Colors.green),
                              _buildBannerCard('Organic Fresh Crops', '100% certified pesticide-free vegetables.', Colors.blue[100]!, Colors.blue[800]!),
                              _buildBannerCard('Support Local Growers', 'Fair trade values paid directly to producers.', Colors.orange[100]!, Colors.orange[800]!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Categories
                        const Text('Popular Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((cat) {
                              final isActive = _selectedCategory == cat;
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(cat),
                                  selected: isActive,
                                  onSelected: (val) {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  },
                                  selectedColor: Colors.green[200],
                                  checkmarkColor: Colors.green[800],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Featured Deals Section
                        if (productState.featuredProducts.isNotEmpty) ...[
                          const Text('Featured Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productState.featuredProducts.length,
                              itemBuilder: (context, index) {
                                final prod = productState.featuredProducts[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _buildProductCard(context, prod),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Popular Products Section
                        if (productState.popularProducts.isNotEmpty) ...[
                          const Text('Popular Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productState.popularProducts.length,
                              itemBuilder: (context, index) {
                                final prod = productState.popularProducts[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _buildProductCard(context, prod),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Products List
                        const Text('Featured Fresh Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        filteredProducts.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Text('No products match your search or filter criteria.', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final prod = filteredProducts[index];
                                  return _buildProductCard(context, prod);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
      );
  }

  Widget _buildBannerCard(String title, String subtitle, Color bgColor, Color textColor) {
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.spa, size: 48, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return InkWell(
      onTap: () {
        context.push('/product-details', extra: product);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(
                        product.category == 'Vegetables'
                            ? Icons.spa
                            : product.category == 'Fruits'
                                ? Icons.apple
                                : product.category == 'Dairy'
                                    ? Icons.egg
                                    : Icons.grain,
                        size: 48,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  if (product.discount != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.discount!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.farmName, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${product.price.toStringAsFixed(2)} / ${product.weight}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          if (product.originalPrice > product.price)
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to Cart'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'Cart',
                                onPressed: () {
                                  context.push('/cart');
                                },
                              ),
                            ),
                          );
                        },
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
