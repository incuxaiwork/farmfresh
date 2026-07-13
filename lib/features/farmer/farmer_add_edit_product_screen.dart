import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';

class FarmerAddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product;

  const FarmerAddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<FarmerAddEditProductScreen> createState() => _FarmerAddEditProductScreenState();
}

class _FarmerAddEditProductScreenState extends ConsumerState<FarmerAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _weightController;
  late final TextEditingController _originController;
  late final TextEditingController _imageUrlController;
  
  String? _selectedCategoryId;
  bool _isOrganic = false;
  bool _isFeatured = false;
  bool _isSeasonal = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.originalPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toStringAsFixed(0) : '');
    _weightController = TextEditingController(text: p?.weight ?? '');
    _originController = TextEditingController(text: p?.origin ?? '');
    _imageUrlController = TextEditingController(text: p?.image ?? '');
    _selectedCategoryId = p?.categoryId;
    _isOrganic = p?.organic ?? false;
    _isFeatured = p?.featured ?? false;
    _isSeasonal = p?.seasonal ?? false;

    Future.microtask(() {
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final cats = ref.read(categoryProvider).categories;
    final catName = cats.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => cats.first).name;

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      originalPrice: widget.product?.originalPrice ?? double.parse(_priceController.text),
      stock: double.parse(_stockController.text),
      weight: _weightController.text.trim(),
      category: catName,
      origin: _originController.text.trim(),
      organic: _isOrganic,
      featured: _isFeatured,
      seasonal: _isSeasonal,
      image: _imageUrlController.text.trim(),
      farmName: widget.product?.farmName ?? '',
      farmerId: widget.product?.farmerId,
      slug: widget.product?.slug ?? '',
      categoryId: _selectedCategoryId,
      status: widget.product?.status ?? 'APPROVED',
    );

    bool success;
    if (_isEditMode) {
      success = await ref.read(farmerProductsProvider.notifier).updateProduct(product);
    } else {
      success = await ref.read(farmerProductsProvider.notifier).addProduct(product);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Product updated successfully' : 'Product added successfully')),
      );
      context.pop();
    } else {
      final error = ref.read(farmerProductsProvider).errorMessage ?? 'Failed to save product';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(categoryProvider);

    // Auto-select first category if edit mode doesn't specify one
    if (_selectedCategoryId == null && catState.categories.isNotEmpty) {
      _selectedCategoryId = catState.categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight / Unit',
                hintText: 'e.g. 1 kg, 500g, 1 dozen',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter weight or unit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Image URL Field
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Product Image URL',
                hintText: 'e.g. https://images.unsplash.com/...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown for Categories from Backend
            if (catState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (catState.categories.isEmpty)
              const Text('No categories available from backend')
            else
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: catState.categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategoryId = val);
                  }
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origin',
                hintText: 'e.g. Local Farm, Valley Region',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Organic'),
                    subtitle: const Text('Certified organic product'),
                    value: _isOrganic,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _isOrganic = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Featured'),
                    subtitle: const Text('Show on homepage'),
                    value: _isFeatured,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _isFeatured = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Seasonal'),
                    subtitle: const Text('Available seasonally'),
                    value: _isSeasonal,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _isSeasonal = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Product' : 'Save Product',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
