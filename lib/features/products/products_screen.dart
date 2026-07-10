import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isGridView = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'price_asc', 'price_desc', 'rating'
  bool _organicOnly = false;
  bool _seasonalOnly = false;

  int _currentPage = 1;
  final int _pageSize = 8;
  final List<ProductModel> _loadedProducts = [];
  bool _isLazyLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLazyLoading && _hasMore) {
        _loadNextPage();
      }
    }
  }

  void _fetchInitialData() async {
    setState(() {
      _currentPage = 1;
      _loadedProducts.clear();
      _hasMore = true;
      _isLazyLoading = false;
    });

    // Request fresh catalog query
    await ref.read(productProvider.notifier).loadProducts(
      search: _searchQuery,
      category: _selectedCategory,
      sortBy: _sortBy,
    );

    final productState = ref.read(productProvider);
    _applyLocalFiltersAndSorting(productState.products);
  }

  void _loadNextPage() async {
    setState(() {
      _isLazyLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600)); // Simulates network latency pagination

    final productState = ref.read(productProvider);
    final allItems = productState.products;

    _applyLocalFiltersAndSorting(allItems, append: true);
  }

  void _applyLocalFiltersAndSorting(List<ProductModel> allItems, {bool append = false}) {
    // 1. Filtering
    var filtered = allItems.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesOrganic = !_organicOnly || p.origin.toLowerCase() == 'organic';
      final matchesSeasonal = !_seasonalOnly || p.description.toLowerCase().contains('seasonal'); // fallback seasonal check
      return matchesCategory && matchesSearch && matchesOrganic && matchesSeasonal;
    }).toList();

    // 2. Sorting
    if (_sortBy == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'rating') {
      // Stub high ratings first
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    // 3. Pagination slicing
    final startIndex = append ? _loadedProducts.length : 0;
    var endIndex = startIndex + _pageSize;
    if (endIndex > filtered.length) {
      endIndex = filtered.length;
    }

    setState(() {
      if (!append) {
        _loadedProducts.clear();
      }
      if (startIndex < filtered.length) {
        _loadedProducts.addAll(filtered.sublist(startIndex, endIndex));
      }
      _hasMore = _loadedProducts.length < filtered.length;
      _isLazyLoading = false;
      _currentPage++;
    });
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSortOption(setSheetState, 'Newest', 'newest'),
                  _buildSortOption(setSheetState, 'Price: Low to High', 'price_asc'),
                  _buildSortOption(setSheetState, 'Price: High to Low', 'price_desc'),
                  _buildSortOption(setSheetState, 'Customer Rating', 'rating'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(StateSetter setSheetState, String title, String code) {
    final isSelected = _sortBy == code;
    return RadioListTile<String>(
      title: Text(title, style: TextStyle(color: isSelected ? Colors.green : Colors.black)),
      value: code,
      groupValue: _sortBy,
      activeColor: Colors.green,
      onChanged: (val) {
        setSheetState(() {
          _sortBy = val!;
        });
        setState(() {
          _sortBy = val!;
        });
        Navigator.pop(context);
        _fetchInitialData();
      },
    );
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _organicOnly = false;
                            _seasonalOnly = false;
                          });
                          setState(() {
                            _organicOnly = false;
                            _seasonalOnly = false;
                          });
                        },
                        child: const Text('Reset All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Organic Crops Only'),
                    subtitle: const Text('Certified chemical-free harvests'),
                    value: _organicOnly,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setSheetState(() {
                        _organicOnly = val;
                      });
                      setState(() {
                        _organicOnly = val;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Seasonal Deals'),
                    subtitle: const Text('Direct fresh seasonal picks'),
                    value: _seasonalOnly,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setSheetState(() {
                        _seasonalOnly = val;
                      });
                      setState(() {
                        _seasonalOnly = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchInitialData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply Filters'),
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
    final categories = productState.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Produce'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _openSortSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilterDrawer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter chips Header
          Container(
            color: Colors.green[50],
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _fetchInitialData();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search organic apples, spinach...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                // Horizontal category chips scroll
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: Colors.green,
                          textColor: isSelected ? Colors.white : Colors.black,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                              _fetchInitialData();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Body
          Expanded(
            child: productState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(productState.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchInitialData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : productState.isLoading && _currentPage == 1
                    ? const Center(child: CircularProgressIndicator())
                    : _loadedProducts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text('No crops match your filters.', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              _fetchInitialData();
                            },
                            child: _isGridView
                                ? GridView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.73,
                                    ),
                                    itemCount: _loadedProducts.length + (_hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _loadedProducts.length) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      final prod = _loadedProducts[index];
                                      return ProductCard(
                                        product: prod,
                                        onTap: () {
                                          context.push('/product-details', extra: prod);
                                        },
                                        onAddToCart: () {
                                          ref.read(cartProvider.notifier).addItem(prod);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Added ${prod.name} to Cart')),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(12),
                                    itemCount: _loadedProducts.length + (_hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _loadedProducts.length) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      final prod = _loadedProducts[index];
                                      return _buildListProductCard(prod);
                                    },
                                  ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildListProductCard(ProductModel prod) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          context.push('/product-details', extra: prod);
        },
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CachedNetworkImage(
                imageUrl: prod.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => Container(color: Colors.green[50], child: const Icon(Icons.spa, color: Colors.green)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (prod.origin.toLowerCase() == 'organic')
                          const Icon(Icons.eco, color: Colors.green, size: 16),
                      ],
                    ),
                    Text(prod.farmName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text('\$${prod.price.toStringAsFixed(2)} / ${prod.weight}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.green),
                          onPressed: prod.stock <= 0 ? null : () {
                            ref.read(cartProvider.notifier).addItem(prod);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${prod.name} to Cart')));
                          },
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
