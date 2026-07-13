import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/admin_provider.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _selectedFilter = 'PENDING_APPROVAL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadProducts(status: _selectedFilter);
    });
  }

  void _loadProductsFiltered(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(adminProvider.notifier).loadProducts(status: filter);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final products = adminState.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Moderation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton('Pending', 'PENDING_APPROVAL'),
                _buildFilterButton('Approved', 'APPROVED'),
                _buildFilterButton('Rejected', 'REJECTED'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(
                        child: Text(
                          'No products in $_selectedFilter state',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final p = products[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CachedNetworkImage(
                                      imageUrl: p.image,
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      errorWidget: (c, u, e) => Container(
                                        color: Colors.green[50],
                                        child: const Icon(Icons.spa, color: Colors.green),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text('Farm: ${p.farmName}'),
                                        Text('Category: ${p.category}'),
                                        Text('Price: ₹${p.price.toStringAsFixed(2)} / ${p.weight}'),
                                        const SizedBox(height: 8),
                                        if (_selectedFilter == 'PENDING_APPROVAL')
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => _approveProduct(p.id),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                ),
                                                child: const Text('Approve'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () => _rejectProduct(p.id),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                ),
                                                child: const Text('Reject'),
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
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) _loadProductsFiltered(value);
      },
      selectedColor: Colors.green,
    );
  }

  void _approveProduct(String id) async {
    final ok = await ref.read(adminProvider.notifier).approveProduct(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Product Approved' : 'Failed to approve product'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _rejectProduct(String id) async {
    final ok = await ref.read(adminProvider.notifier).rejectProduct(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Product Rejected' : 'Failed to reject product'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
