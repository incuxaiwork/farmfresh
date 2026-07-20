import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/widgets/product_image_widget.dart';

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
  late final TextEditingController _imageController;
  late String _selectedCategory;
  bool _isOrganic = false;
  bool _isFeatured = false;
  bool _isSeasonal = false;
  bool _isSaving = false;

  XFile? _pickedImage;

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
    _imageController = TextEditingController(text: p?.image ?? '');
    _selectedCategory = p?.category ?? 'Vegetables';
    _isOrganic = p?.organic ?? false;
    _isFeatured = p?.featured ?? false;
    _isSeasonal = p?.seasonal ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickProductImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
        _imageController.text = pickedFile.path;
      });
    }
  }

  String _getDefaultCategoryImageUrl(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return 'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?auto=format&fit=crop&w=400&q=80';
      case 'vegetables':
        return 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=400&q=80';
      case 'meat':
        return 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=400&q=80';
      case 'dairy':
        return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80';
      case 'grains':
      case 'grains & millets':
        return 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=400&q=80';
      default:
        return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80';
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final categories = ref.read(categoryProvider).categories;
    final matchedCategory = categories.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCategory.toLowerCase(),
      orElse: () => categories.isNotEmpty ? categories.first : CategoryModel(id: '', name: '', slug: ''),
    );
    final categoryIdStr = matchedCategory.id;

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      originalPrice: widget.product?.originalPrice ?? double.parse(_priceController.text),
      stock: double.parse(_stockController.text),
      weight: _weightController.text.trim(),
      category: _selectedCategory,
      origin: _originController.text.trim(),
      organic: _isOrganic,
      featured: _isFeatured,
      seasonal: _isSeasonal,
      image: _imageController.text.trim().isNotEmpty
          ? _imageController.text.trim()
          : _getDefaultCategoryImageUrl(_selectedCategory),
      farmName: widget.product?.farmName ?? 'Green Valley Organic Farms',
      farmerId: widget.product?.farmerId,
      slug: widget.product?.slug ?? '',
      categoryId: categoryIdStr.isNotEmpty ? categoryIdStr : widget.product?.categoryId,
      status: widget.product?.status ?? 'PENDING_APPROVAL',
    );

    bool success;
    if (_isEditMode) {
      success = await ref.read(productProvider.notifier).updateProduct(product);
    } else {
      success = await ref.read(productProvider.notifier).addProduct(product);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      showAppSnackBar(
        context,
        _isEditMode ? 'Product updated successfully' : 'Product added successfully',
        type: SnackBarType.success,
      );
      context.pop();
    } else {
      showAppSnackBar(
        context,
        'Failed to save product',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
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
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Crop Details' : 'Add New Crop',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A2E5C45),
                  offset: Offset(0, 10),
                  blurRadius: 30,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Crop Name', Icons.spa_outlined),
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
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Description', Icons.description_outlined).copyWith(
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter crop description';
                      }
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
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
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF23312B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration('Price', Icons.currency_rupee).copyWith(
                            prefixText: '\u20B9 ',
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
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF23312B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration('Stock Qty', Icons.warehouse_outlined),
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
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Weight / Unit', Icons.scale_outlined).copyWith(
                      hintText: 'e.g. 1 kg, 500g, 1 dozen',
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF8D99AE), fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter weight or unit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoryState.categories.any((c) => c.name.toLowerCase() == _selectedCategory.toLowerCase())
                        ? categoryState.categories.firstWhere((c) => c.name.toLowerCase() == _selectedCategory.toLowerCase()).name
                        : (categoryState.categories.isNotEmpty ? categoryState.categories.first.name : _selectedCategory),
                    dropdownColor: Colors.white,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration('Category', Icons.category_outlined),
                    items: categoryState.categories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _originController,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Origin Location', Icons.location_on_outlined).copyWith(
                      hintText: 'e.g. Local Farm, Valley Region',
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF8D99AE), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageController,
                    readOnly: true,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF23312B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Product Image URL (Optional)', Icons.image_outlined).copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF2E7D32)),
                        tooltip: 'Upload Product Photo',
                        onPressed: _pickProductImage,
                      ),
                      hintText: 'Tap camera to upload',
                      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF8D99AE), fontSize: 12),
                    ),
                  ),
                  if (_pickedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ProductImageWidget(
                              imageUrl: _pickedImage!.path,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _pickedImage = null;
                                  _imageController.text = widget.product?.image ?? '';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Organic, Featured, Seasonal toggles
                  Material(
                    color: const Color(0xFFFAFBF9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE5EDE7)),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Organic Crop', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
                          subtitle: Text('Certified chemical-free farming', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72))),
                          value: _isOrganic,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (val) => setState(() => _isOrganic = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5EDE7)),
                        SwitchListTile(
                          title: Text('Featured Crop', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
                          subtitle: Text('Showcase on marketplace homepage', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72))),
                          value: _isFeatured,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (val) => setState(() => _isFeatured = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5EDE7)),
                        SwitchListTile(
                          title: Text('Seasonal Availability', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
                          subtitle: Text('Crop is harvested only seasonally', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72))),
                          value: _isSeasonal,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (val) => setState(() => _isSeasonal = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1FE28C43),
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Update Crop Listing' : 'Publish Crop Listing',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF647C72),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5EDE7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5EDE7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF647C72)),
      fillColor: const Color(0xFFFAFBF9),
      filled: true,
    );
  }
}