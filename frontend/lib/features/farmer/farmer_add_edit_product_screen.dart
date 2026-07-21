import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/utils/app_snackbar.dart';

String _suggestImage(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('tomato')) return 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=400';
  if (lower.contains('onion')) return 'https://images.unsplash.com/photo-1618512496248-a07fe83766a5?w=400';
  if (lower.contains('mango')) return 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400';
  if (lower.contains('rice')) return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400';
  if (lower.contains('apple')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400';
  if (lower.contains('carrot')) return 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400';
  if (lower.contains('milk')) return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400';
  if (lower.contains('egg')) return 'https://images.unsplash.com/photo-1516448424440-9dbca97779c1?w=400';
  if (lower.contains('banana')) return 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400';
  if (lower.contains('potato')) return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400';
  if (lower.contains('orange')) return 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=400';
  if (lower.contains('lemon')) return 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400';
  if (lower.contains('strawberry')) return 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400';
  if (lower.contains('grapes')) return 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400';
  if (lower.contains('watermelon')) return 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400';
  if (lower.contains('chili') || lower.contains('chilli')) return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400';
  if (lower.contains('cabbage')) return 'https://images.unsplash.com/photo-1582515073490-39981397c445?w=400';
  if (lower.contains('spinach')) return 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400';
  if (lower.contains('brinjal') || lower.contains('eggplant')) return 'https://images.unsplash.com/photo-1615484477778-ca3b77940c25?w=400';
  if (lower.contains('potato')) return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400';
  if (lower.contains('chicken')) return 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400';
  return 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400';
}

const _availabilityOptions = [
  {'value': 'ACTIVE', 'label': 'Active (Visible & Approved)'},
  {'value': 'IN_STOCK', 'label': 'In Stock'},
  {'value': 'OUT_OF_STOCK', 'label': 'Out of Stock'},
  {'value': 'HIDDEN', 'label': 'Hidden (Archived)'},
];

class FarmerAddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  const FarmerAddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<FarmerAddEditProductScreen> createState() => _FarmerAddEditProductScreenState();
}

class _FarmerAddEditProductScreenState extends ConsumerState<FarmerAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();

  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String _availabilityStatus = 'IN_STOCK';
  String _imageUrl = '';
  String _currency = '\u20B9';
  bool _isSaving = false;
  bool _generatingDesc = false;
  bool _isUploadingImage = false;
  Uint8List? _pickedImageBytes;
  String? _pickedImageFilename;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.originalPrice.toStringAsFixed(2);
      _stockController.text = p.stock.toStringAsFixed(0);
      _unitController.text = p.weight;
      _selectedCategoryName = p.category;
      _selectedCategoryId = p.categoryId ?? '';
      _imageUrl = p.image;

      if (p.stock <= 0) {
        _availabilityStatus = 'OUT_OF_STOCK';
      } else if (p.status == 'ARCHIVED') {
        _availabilityStatus = 'HIDDEN';
      } else {
        _availabilityStatus = 'IN_STOCK';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    if (value.length > 2 && _pickedImageBytes == null && (_imageUrl.isEmpty || _imageUrl.startsWith('https://images.unsplash.com'))) {
      setState(() {
        _imageUrl = _suggestImage(value);
      });
    }
  }

  void _handleAutoGenerateDescription() {
    if (_nameController.text.trim().isEmpty) {
      showAppSnackBar(context, 'Please enter a product name first', type: SnackBarType.error);
      return;
    }
    setState(() => _generatingDesc = true);
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      final name = _nameController.text.trim();
      _descriptionController.text =
          'Fresh organic $name, hand-harvested directly from local farms. Naturally grown without harmful chemical pesticides, rich in essential vitamins, minerals, and flavor. Ideal for healthy daily meals, salads, or cooking.';
      setState(() => _generatingDesc = false);
      showAppSnackBar(context, 'Description generated successfully!', type: SnackBarType.success);
    });
  }

  static const _allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
  static const _maxFileSize = 5 * 1024 * 1024; // 5MB

  Future<void> _pickProductImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';

      if (!_allowedMimeTypes.contains(mimeType)) {
        if (mounted) {
          showAppSnackBar(
            context,
            'Unsupported file type. Please choose JPG, PNG, or WebP.',
            type: SnackBarType.error,
          );
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      if (bytes.length > _maxFileSize) {
        if (mounted) {
          showAppSnackBar(
            context,
            'File too large. Maximum size is 5MB.',
            type: SnackBarType.error,
          );
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      final ext = pickedFile.name.split('.').last.toLowerCase();
      final filename = 'product_${DateTime.now().millisecondsSinceEpoch}.$ext';

      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageFilename = filename;
        _imageUrl = '';
        _isUploadingImage = false;
      });

      if (mounted) {
        showAppSnackBar(context, 'Image selected successfully', type: SnackBarType.success);
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        showAppSnackBar(context, 'Failed to pick image: $e', type: SnackBarType.error);
      }
    }
  }

  String _resolveCategoryId(List categories) {
    if (_selectedCategoryId.isNotEmpty) return _selectedCategoryId;
    for (final c in categories) {
      if (c.name.toLowerCase() == _selectedCategoryName.toLowerCase()) {
        return c.id;
      }
    }
    return categories.isNotEmpty ? categories.first.id : '';
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final categories = ref.read(categoryProvider).categories;
    final catId = _resolveCategoryId(categories);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      originalPrice: widget.product?.originalPrice ?? (double.tryParse(_priceController.text) ?? 0),
      stock: double.tryParse(_stockController.text) ?? 0,
      weight: _unitController.text.trim(),
      category: _selectedCategoryName.isNotEmpty
          ? _selectedCategoryName
          : (categories.isNotEmpty ? categories.first.name : ''),
      origin: widget.product?.origin ?? '',
      organic: widget.product?.organic ?? false,
      featured: widget.product?.featured ?? false,
      seasonal: widget.product?.seasonal ?? false,
      image: _imageUrl.isNotEmpty ? _imageUrl : _suggestImage(_nameController.text),
      farmName: widget.product?.farmName ?? '',
      farmerId: widget.product?.farmerId,
      slug: widget.product?.slug ?? '',
      categoryId: catId.isNotEmpty ? catId : widget.product?.categoryId,
      status: widget.product?.status ?? 'PENDING_APPROVAL',
    );

    bool success;
    if (_isEditMode) {
      success = await ref.read(productProvider.notifier).updateProduct(
        product,
        imageBytes: _pickedImageBytes,
        imageFilename: _pickedImageFilename,
      );
    } else {
      success = await ref.read(productProvider.notifier).addProduct(
        product,
        imageBytes: _pickedImageBytes,
        imageFilename: _pickedImageFilename,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showAppSnackBar(
        context,
        _isEditMode ? 'Product updated successfully' : 'Product created successfully',
        type: SnackBarType.success,
      );
      context.pop();
    } else {
      showAppSnackBar(context, 'Failed to save product', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2F8F4), Color(0xFFE6F2EA)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Text(
                _isEditMode ? 'Modify Product Details' : 'Add New Product Crop',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20, color: const Color(0xFF23312B)),
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 10),
                  blurRadius: 30,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    icon: Icons.spa_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                    onChanged: _onNameChanged,
                  ),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildPriceField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStockField()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _unitController,
                    label: 'Unit Size',
                    icon: Icons.scale_outlined,
                    hint: 'e.g. 1 kg, 500 g, 1 Dozen',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Unit size is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(categories),
                  const SizedBox(height: 16),
                  _buildAvailabilityDropdown(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removePickedImage() {
    setState(() {
      _pickedImageBytes = null;
      _pickedImageFilename = null;
      _imageUrl = _suggestImage(_nameController.text);
    });
  }

  Widget _buildImageSection() {
    final hasPickedBytes = _pickedImageBytes != null && _pickedImageBytes!.isNotEmpty;
    final hasNetworkUrl = _imageUrl.isNotEmpty && _imageUrl.startsWith('http');
    final hasImage = hasPickedBytes || hasNetworkUrl;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE7), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Cover Image',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 4),
          Text(
            hasImage ? 'Image selected — tap remove to replace' : 'Auto-suggested from name, or choose a custom file',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72)),
          ),
          const SizedBox(height: 12),
          // Image preview with remove button
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EDE7)),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image content
                if (hasPickedBytes)
                  Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                else if (hasNetworkUrl)
                  Image.network(
                    _imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)));
                    },
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                else
                  _imagePlaceholder(),
                // Remove button (top-right)
                if (hasImage)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removePickedImage,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                // Loading overlay
                if (_isUploadingImage)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Choose file button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploadingImage ? null : _pickProductImage,
              icon: _isUploadingImage
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF10B981)))
                  : Icon(hasImage ? Icons.swap_horiz : Icons.photo_camera_outlined, size: 16),
              label: Text(
                _isUploadingImage
                    ? 'Selecting...'
                    : hasImage
                        ? 'Replace Image'
                        : 'Choose file',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F7F5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 40, color: const Color(0xFF8D99AE).withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text('No image selected', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF8D99AE))),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Product Description', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF647C72))),
            TextButton.icon(
              onPressed: _generatingDesc ? null : _handleAutoGenerateDescription,
              icon: _generatingDesc
                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF10B981)))
                  : const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF10B981)),
              label: Text(
                _generatingDesc ? 'Generating...' : 'Auto-generate',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF10B981)),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 13, fontWeight: FontWeight.w600),
          decoration: _inputDecoration('Describe your product...', null),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Description is required';
            if (value.trim().length < 10) return 'Description must be at least 10 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 13, fontWeight: FontWeight.w600),
      decoration: _inputDecoration('Price', null).copyWith(
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currency,
              isDense: true,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF23312B)),
              items: const [
                DropdownMenuItem(value: '\u20B9', child: Text('\u20B9')),
                DropdownMenuItem(value: '\$', child: Text('\$')),
                DropdownMenuItem(value: '\u20AC', child: Text('\u20AC')),
                DropdownMenuItem(value: '\u00A3', child: Text('\u00A3')),
              ],
              onChanged: (v) => setState(() => _currency = v ?? '\u20B9'),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid';
        if ((double.tryParse(value) ?? 0) <= 0) return 'Must be > 0';
        return null;
      },
    );
  }

  Widget _buildStockField() {
    return TextFormField(
      controller: _stockController,
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 13, fontWeight: FontWeight.w600),
      decoration: _inputDecoration('Stock Level', Icons.warehouse_outlined),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid';
        if ((double.tryParse(value) ?? 0) < 0) return 'Must be >= 0';
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(List categories) {
    final validValue = categories.any((c) => c.name == _selectedCategoryName)
        ? _selectedCategoryName
        : (categories.isNotEmpty ? categories.first.name : null);

    if (validValue != null && validValue != _selectedCategoryName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedCategoryName = validValue);
      });
    }

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      dropdownColor: Colors.white,
      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontWeight: FontWeight.w700, fontSize: 13),
      decoration: _inputDecoration('Category', Icons.category_outlined),
      items: categories.map<DropdownMenuItem<String>>((c) {
        return DropdownMenuItem<String>(value: c.name, child: Text(c.name));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategoryName = val);
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Category is required' : null,
    );
  }

  Widget _buildAvailabilityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _availabilityStatus,
      dropdownColor: Colors.white,
      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontWeight: FontWeight.w700, fontSize: 13),
      decoration: _inputDecoration('Availability Status', Icons.visibility_outlined),
      items: _availabilityOptions.map<DropdownMenuItem<String>>((opt) {
        return DropdownMenuItem<String>(value: opt['value'], child: Text(opt['label']!));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _availabilityStatus = val);
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), offset: const Offset(0, 8), blurRadius: 16),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                _isEditMode ? 'Save Product' : 'Save Product',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12, fontWeight: FontWeight.w500),
      hintText: null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5EDE7))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5EDE7))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF647C72), size: 20) : null,
      fillColor: const Color(0xFFFAFBF9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _inputDecorationWithHint(String label, IconData? icon, String? hint) {
    return _inputDecoration(label, icon).copyWith(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF8D99AE), fontSize: 12),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF23312B), fontSize: 13, fontWeight: FontWeight.w600),
      decoration: _inputDecorationWithHint(label, icon, hint),
      validator: validator,
    );
  }
}
