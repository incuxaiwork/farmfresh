import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Farmer specific controllers
  final _farmNameController = TextEditingController();
  final _farmAddressController = TextEditingController();
  final _governmentIdController = TextEditingController();
  final _bankAccountController = TextEditingController();

  // Delivery specific controllers
  final _licenseController = TextEditingController();
  final _vehicleTypeController = TextEditingController(text: 'Two-Wheeler');
  final _vehicleNumberController = TextEditingController();

  String _selectedRole = 'Customer';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _farmNameController.dispose();
    _farmAddressController.dispose();
    _governmentIdController.dispose();
    _bankAccountController.dispose();
    _licenseController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
      _phoneController.text.trim(),
      farmName: _selectedRole == 'Farmer' ? _farmNameController.text.trim() : null,
      farmAddress: _selectedRole == 'Farmer' ? _farmAddressController.text.trim() : null,
      governmentId: _selectedRole == 'Farmer' ? _governmentIdController.text.trim() : null,
      bankAccountDetails: _selectedRole == 'Farmer' ? _bankAccountController.text.trim() : null,
      drivingLicenseNumber: _selectedRole == 'Delivery Partner' ? _licenseController.text.trim() : null,
      vehicleType: _selectedRole == 'Delivery Partner' ? _vehicleTypeController.text.trim() : null,
      vehicleNumber: _selectedRole == 'Delivery Partner' ? _vehicleNumberController.text.trim() : null,
    );

    if (success) {
      if (!mounted) return;
      final role = _selectedRole.toLowerCase();
      if (role == 'farmer') {
        context.go('/farmer-main');
      } else if (role == 'delivery partner') {
        context.go('/delivery-main');
      } else {
        context.go('/customer-main');
      }
    } else {
      if (!mounted) return;
      final error = ref.read(authProvider).errorMessage ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join FarmFresh Today',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register to shop fresh, sell crops, or deliver orders',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Role Selector Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Register As',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Customer', child: Text('Customer Marketplace')),
                    DropdownMenuItem(value: 'Farmer', child: Text('Farmer Partner')),
                    DropdownMenuItem(value: 'Delivery Partner', child: Text('Delivery Partner')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Farmer Specific Fields
                if (_selectedRole == 'Farmer') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Farm Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  TextFormField(
                    controller: _farmNameController,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.agriculture_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Farmer' && (value == null || value.trim().isEmpty)) {
                        return 'Farm name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _farmAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Farm Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Farmer' && (value == null || value.trim().isEmpty)) {
                        return 'Farm address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _governmentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Government Tax ID / License',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Farmer' && (value == null || value.trim().isEmpty)) {
                        return 'Government ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Account Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Farmer' && (value == null || value.trim().isEmpty)) {
                        return 'Bank account details are required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Delivery Specific Fields
                if (_selectedRole == 'Delivery Partner') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Vehicle & License Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: 'Driving License Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_membership_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Delivery Partner' && (value == null || value.trim().isEmpty)) {
                        return 'Driving License is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _vehicleTypeController.text,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pedal_bike_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Two-Wheeler', child: Text('Two-Wheeler (Motorcycle/Scooter)')),
                      DropdownMenuItem(value: 'Three-Wheeler', child: Text('Three-Wheeler (Auto)')),
                      DropdownMenuItem(value: 'Four-Wheeler', child: Text('Four-Wheeler (Mini Truck)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _vehicleTypeController.text = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Number Plate',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'Delivery Partner' && (value == null || value.trim().isEmpty)) {
                        return 'Vehicle number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),
                
                // Sign Up button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Register as $_selectedRole', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
