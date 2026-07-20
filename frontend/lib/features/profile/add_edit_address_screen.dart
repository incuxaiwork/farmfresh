import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/app_snackbar.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  bool _isDefault = false;
  bool _isSaving = false;
  bool _isLocating = false;

  bool get _isEditing => widget.address != null;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppSnackBar.show(context, 'Location services are disabled on your device.', isError: true);
        }
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            AppSnackBar.show(context, 'Location permissions were denied.', isError: true);
          }
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          AppSnackBar.show(context, 'Location permissions are permanently denied.', isError: true);
        }
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {'User-Agent': 'FarmFreshApp/1.0'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final road = address['road'] ?? address['pedestrian'] ?? address['suburb'] ?? address['neighbourhood'] ?? address['residential'] ?? '';
        final houseNumber = address['house_number'] ?? address['building'] ?? '';
        final streetParts = [houseNumber, road].where((s) => s.toString().trim().isNotEmpty).join(', ');

        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['state_district'] ?? '';
        final state = address['state'] ?? '';
        final postcode = address['postcode'] ?? '';
        final country = address['country'] ?? 'India';

        setState(() {
          if (_labelController.text.trim().isEmpty) {
            _labelController.text = 'Current Location';
          }
          if (streetParts.isNotEmpty) _streetController.text = streetParts;
          if (city.toString().isNotEmpty) _cityController.text = city.toString();
          if (state.toString().isNotEmpty) _stateController.text = state.toString();
          if (postcode.toString().isNotEmpty) _zipController.text = postcode.toString();
          if (country.toString().isNotEmpty) _countryController.text = country.toString();
        });

        if (mounted) {
          AppSnackBar.show(context, 'Current location filled successfully!');
        }
      } else {
        if (mounted) {
          AppSnackBar.show(context, 'Location acquired (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}). Please enter street details.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'Could not fetch current location address. Please enter details manually.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Widget _buildUseCurrentLocationButton() {
    return InkWell(
      onTap: _isLocating ? null : _useCurrentLocation,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLocating) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Fetching location...',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ] else ...[
              const Icon(Icons.my_location, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 10),
              Text(
                'Use Current Location',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label ?? '');
    _streetController =
        TextEditingController(text: address?.street ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _zipController = TextEditingController(text: address?.zipCode ?? '');
    _countryController =
        TextEditingController(text: address?.country ?? 'India');
    _phoneController =
        TextEditingController(text: address?.contactPhone ?? '');
    _isDefault = address?.isDefault ?? false;

    _labelController.addListener(_updatePreview);
    _streetController.addListener(_updatePreview);
    _cityController.addListener(_updatePreview);
    _stateController.addListener(_updatePreview);
    _zipController.addListener(_updatePreview);
    _countryController.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {});
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _isEditing ? 'Edit Address' : 'Add New Address',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveAddress,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A2E5C45),
                      offset: Offset(0, 10),
                      blurRadius: 30,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Use Current Location Button
                    _buildUseCurrentLocationButton(),
                    const SizedBox(height: 20),

                    // Label Field
                    TextFormField(
                      controller: _labelController,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Address Label (e.g. Home, Office)', Icons.label_important_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Label is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Street Field
                    TextFormField(
                      controller: _streetController,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Street address', Icons.location_on_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City / State Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('City', Icons.business_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('State', Icons.map_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Zip / Country Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _zipController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('PIN Code', Icons.pin_drop_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _countryController,
                            enabled: false,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF647C72),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration('Country', Icons.public_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Contact Phone (optional)', Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    
                    // Default Address Toggle
                    Row(
                      children: [
                        Switch(
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() => _isDefault = value);
                          },
                          activeColor: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Set as default shipping address',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF23312B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: Color(0xFFF3F3F3)),
                    
                    // Address Preview Card
                    Text(
                      'Preview Address:',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBF9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5EDE7)),
                      ),
                      child: Text(
                        _getPreviewAddress(),
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomButton(
                      text: 'Save Address',
                      onPressed: _saveAddress,
                      isLoading: _isSaving,
                      height: 48,
                    ),
                  ],
                ),
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

  String _getPreviewAddress() {
    final parts = <String>[];
    if (_streetController.text.isNotEmpty) {
      parts.add(_streetController.text);
    }
    final cityState = <String>[];
    if (_cityController.text.isNotEmpty) cityState.add(_cityController.text);
    if (_stateController.text.isNotEmpty) cityState.add(_stateController.text);
    if (cityState.isNotEmpty) parts.add(cityState.join(', '));
    if (_zipController.text.isNotEmpty) parts.add(_zipController.text);
    if (_countryController.text.isNotEmpty &&
        _countryController.text.toUpperCase() != 'INDIA') {
      parts.add(_countryController.text);
    }
    return parts.isNotEmpty ? parts.join('\n') : 'Complete the fields above to render preview.';
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final addressData = AddressModel(
      id: widget.address?.id ?? '',
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      country: _countryController.text.trim(),
      contactPhone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      isDefault: _isDefault,
    );

    bool success;
    if (_isEditing) {
      success = await ref
          .read(addressProvider.notifier)
          .updateAddress(widget.address!.id, addressData);
    } else {
      success = await ref
          .read(addressProvider.notifier)
          .addAddress(addressData);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Address updated successfully!' : 'Address added successfully!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      context.pop();
    }
  }
}
