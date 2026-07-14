import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_providers.dart';

class FarmerEditProfileScreen extends ConsumerStatefulWidget {
  const FarmerEditProfileScreen({super.key});

  @override
  ConsumerState<FarmerEditProfileScreen> createState() =>
      _FarmerEditProfileScreenState();
}

class _FarmerEditProfileScreenState
    extends ConsumerState<FarmerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _farmNameController;
  late TextEditingController _farmAddressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _farmNameController = TextEditingController();
    _farmAddressController = TextEditingController();
    _loadFarmerProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _farmAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmerProfile() async {
    try {
      final profile =
          await ref.read(farmerRepositoryProvider).getProfile();
      if (mounted) {
        setState(() {
          _nameController.text = profile.name;
          _phoneController.text = profile.phone ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final farmerRepo = ref.read(farmerRepositoryProvider);
      await farmerRepo.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        farmName: _farmNameController.text.trim(),
        farmAddress: _farmAddressController.text.trim(),
      );

      await ref.read(authProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF4D6D),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
            'Edit Farm Profile',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
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
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F2E5C45),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://api.dicebear.com/7.x/adventurer/svg?seed=FarmerJoe',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Full Name', Icons.person_outline),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF647C72),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Email Address', Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    
                    // Farm Name Field
                    TextFormField(
                      controller: _farmNameController,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Farm Name', Icons.eco_outlined),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Farm name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Farm Address Field
                    TextFormField(
                      controller: _farmAddressController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF23312B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('Farm Address', Icons.location_on_outlined).copyWith(
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Farm address is required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Save Button
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1FE28C43),
                            offset: Offset(0, 8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Save Profile Changes',
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
