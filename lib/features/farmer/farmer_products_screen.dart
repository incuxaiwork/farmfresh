import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class FarmerProductsScreen extends ConsumerStatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  ConsumerState<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends ConsumerState<FarmerProductsScreen> {
  void _deleteProduct(String id) async {
    final success = await ref.read(productProvider.notifier).deleteProduct(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    }
  }

  void _showAddEditProductSheet([ProductModel? product]) {
    final isEdit = product != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final originController = TextEditingController(text: product?.origin ?? 'Santorini Farms');
    final weightController = TextEditingController(text: product?.weight ?? '1 kg');
    final descriptionController = TextEditingController(
      text: product?.description ?? 'Fresh organic harvest grown locally.',
    );
    String selectedCategory = product?.category ?? 'Vegetables';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Edit Harvest Product' : 'Add New Harvest crop',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Crop / Product Name', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Price ($)', border: OutlineInputBorder()),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Enter price' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Stock Qty', border: OutlineInputBorder()),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Enter stock' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
                            DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
                            DropdownMenuItem(value: 'Dairy', child: Text('Dairy')),
                            DropdownMenuItem(value: 'Grains', child: Text('Grains')),
                          ],
                          onChanged: (val) {
                            if (val != null) selectedCategory = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          decoration: const InputDecoration(labelText: 'Weight Unit', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Enter unit' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: originController,
                    decoration: const InputDecoration(labelText: 'Farm Origin', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Enter origin' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final prod = ProductModel(
                        id: product?.id ?? '',
                        name: nameController.text,
                        price: double.parse(priceController.text),
                        originalPrice: product?.originalPrice ?? double.parse(priceController.text),
                        discount: product?.discount,
                        origin: originController.text,
                        category: selectedCategory,
                        image: product?.image ?? 'assets/cherry_tomatoes.jpg',
                        description: descriptionController.text,
                        calories: product?.calories ?? '30 kcal',
                        protein: product?.protein ?? '1g',
                        fat: product?.fat ?? '0.1g',
                        weight: weightController.text,
                        stock: double.parse(stockController.text),
                        farmName: originController.text,
                      );

                      bool success;
                      if (isEdit) {
                        success = await ref.read(productProvider.notifier).updateProduct(prod);
                      } else {
                        success = await ref.read(productProvider.notifier).addProduct(prod);
                      }

                      if (!mounted) return;
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEdit ? 'Harvest updated!' : 'Crop published to Marketplace!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Operation failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEdit ? 'Update Product' : 'Add Harvest to Marketplace'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products Catalog'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditProductSheet(),
          ),
        ],
      ),
      body: productState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productState.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.agriculture_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Products Catalogued', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Add your first crop harvest to start selling!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: productState.products.length,
                  itemBuilder: (context, index) {
                    final prod = productState.products[index];
                    final inStock = prod.stock > 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: inStock ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            prod.category == 'Vegetables'
                                ? Icons.spa
                                : prod.category == 'Fruits'
                                    ? Icons.apple
                                    : prod.category == 'Dairy'
                                        ? Icons.egg
                                        : Icons.grain,
                            color: inStock ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stock: ${prod.stock} (${prod.weight})'),
                            Text('Price: \$${prod.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditProductSheet(prod),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(prod.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
