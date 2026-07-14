import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class FarmerProductsScreen extends ConsumerStatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  ConsumerState<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends ConsumerState<FarmerProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    var filtered = products;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((p) {
        final status = p.status.toUpperCase();
        switch (_selectedFilter) {
          case 'Approved':
            return status == 'APPROVED';
          case 'Pending':
            return status == 'PENDING_APPROVAL' || status == 'PENDING';
          case 'Rejected':
            return status == 'REJECTED';
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vegetables':
        return Icons.spa;
      case 'Fruits':
        return Icons.apple;
      case 'Dairy':
        return Icons.egg;
      case 'Grains':
        return Icons.grain;
      default:
        return Icons.category;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF2E7D32);
      case 'PENDING_APPROVAL':
      case 'PENDING':
        return const Color(0xFFE28C43);
      case 'REJECTED':
        return const Color(0xFFFF4D6D);
      default:
        return const Color(0xFF647C72);
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Approved';
      case 'PENDING_APPROVAL':
      case 'PENDING':
        return 'Pending';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Crop?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${product.name}"?', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(farmerProductsProvider.notifier).deleteProduct(product.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Product deleted' : 'Failed to delete product'),
                ),
              );
            },
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(farmerProductsProvider);
    final filteredProducts = _getFilteredProducts(productState.products);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'My Crops Inventory',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF23312B)),
            onPressed: () {
              context.push('/farmer-add-product');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search my crops...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF647C72)),
                    fillColor: const Color(0xFFE5EDE7),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Approved', 'Pending', 'Rejected'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2E7D32),
                          disabledColor: Colors.white,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white : const Color(0xFF23312B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : filteredProducts.isEmpty
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
                                child: const Icon(Icons.spa_outlined, color: Color(0xFF2E7D32), size: 28),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'All'
                                    ? 'No crops match your filters'
                                    : 'No crops added yet',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'All'
                                    ? 'Try adjusting search queries or chips filters'
                                    : 'Tap the button below to add your first fresh crop!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, height: 1.4),
                              ),
                              if (_searchQuery.isEmpty && _selectedFilter == 'All') ...[
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/farmer-add-product');
                                    },
                                    icon: const Icon(Icons.add, size: 16),
                                    label: Text(
                                      'Add First Crop',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2E7D32),
                        onRefresh: () async {
                          await ref.read(farmerProductsProvider.notifier).loadFarmerProducts();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final statusColor = _getStatusColor(product.status);

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
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Product Image / Fallback Icon
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: product.image.isNotEmpty
                                          ? Image.network(
                                              product.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: const Color(0xFFF1F8F4),
                                                child: Icon(
                                                  _getCategoryIcon(product.category),
                                                  color: const Color(0xFF2E7D32),
                                                  size: 24,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: const Color(0xFFF1F8F4),
                                              child: Icon(
                                                _getCategoryIcon(product.category),
                                                color: const Color(0xFF2E7D32),
                                                size: 24,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: const Color(0xFF23312B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getStatusText(product.status).toUpperCase(),
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: statusColor,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stock: ${product.stock.toStringAsFixed(0)}  •  ${product.weight}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF647C72),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${product.price.toStringAsFixed(2)}',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF23312B),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Edit & Delete Actions
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.push('/farmer-add-product', extra: product);
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF1F8F4),
                                          ),
                                          child: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32), size: 14),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => _confirmDelete(product),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFFF0F3),
                                          ),
                                          child: const Icon(Icons.delete_outline, color: Color(0xFFFF4D6D), size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
