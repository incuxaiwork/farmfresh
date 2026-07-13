import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';

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

  bool get _isEditing => widget.address != null;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Address' : 'Add Address'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Label (e.g., Home, Work)',
                controller: _labelController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Label is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Street Address',
                controller: _streetController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'City',
                      controller: _cityController,
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
                    child: CustomTextField(
                      label: 'State',
                      controller: _stateController,
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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'PIN Code',
                      controller: _zipController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                          return 'Must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Country',
                      controller: _countryController,
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Contact Phone (optional)',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value);
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text('Set as default address'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Preview:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPreviewAddress(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditing ? 'Update Address' : 'Add Address',
                onPressed: _saveAddress,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
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
    return parts.isNotEmpty ? parts.join('\n') : 'Enter address details above';
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
          content:
              Text(_isEditing ? 'Address updated' : 'Address added'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }
}
