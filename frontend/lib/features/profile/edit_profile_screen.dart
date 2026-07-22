import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/custom_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedAvatar;
  bool _isSaving = false;

  static String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  static Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFE50914), // Netflix Red
      const Color(0xFF0071EB), // Blue
      const Color(0xFFF4B400), // Yellow
      const Color(0xFF0F9D58), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  void _showAvatarPicker() {
    final List<String> presetAvatars = [
      '', // Initials
      'https://api.dicebear.com/7.x/notionists/png?seed=Felix&backgroundColor=b6e3f4',
      'https://api.dicebear.com/7.x/notionists/png?seed=Aneka&backgroundColor=c0aede',
      'emoji:🍅',
      'emoji:🥦',
      'emoji:🥕',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose an Avatar',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: presetAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarUrl = presetAvatars[index];
                    final isInitials = avatarUrl.isEmpty;
                    final isEmoji = avatarUrl.startsWith('emoji:');
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = isInitials ? null : avatarUrl;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInitials || isEmoji ? _getAvatarColor(_nameController.text.trim().isEmpty ? 'U' : _nameController.text).withOpacity(isEmoji ? 0.2 : 1.0) : null,
                          border: Border.all(
                            color: _selectedAvatar == (isInitials ? null : avatarUrl)
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE5EDE7),
                            width: _selectedAvatar == (isInitials ? null : avatarUrl) ? 3 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isInitials
                            ? Text(
                                _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : isEmoji
                                ? Text(
                                    avatarUrl.substring(6),
                                    style: const TextStyle(fontSize: 32),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedAvatar = (user?.avatar != null && user!.avatar!.isNotEmpty)
        ? user.avatar
        : null;
    
    // Add listener to update avatar initials when name changes
    _nameController.addListener(() {
      if (_selectedAvatar == null) {
        setState(() {}); // Re-render the initials
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
            'Edit Profile',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF23312B)),
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
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Hero(
                          tag: 'profile-avatar',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _selectedAvatar == null ? _getAvatarColor(_nameController.text.trim().isEmpty ? 'User' : _nameController.text) : null,
                                    border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0F2E5C45),
                                        offset: Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: _selectedAvatar != null && _selectedAvatar!.isNotEmpty
                                    ? (_selectedAvatar!.startsWith('emoji:')
                                        ? Text(
                                            _selectedAvatar!.substring(6),
                                            style: const TextStyle(fontSize: 40),
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              _selectedAvatar!,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 90,
                                            ),
                                          ))
                                    : Text(
                                        _getInitials(_nameController.text.trim().isEmpty ? 'U' : _nameController.text),
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'Enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email address cannot be modified',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF8D99AE), fontWeight: FontWeight.w500),
                    ),
                    
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    if (authState.successMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6EC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.successMessage!,
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    CustomButton(
                      text: 'Save Profile Changes',
                      onPressed: _saveProfile,
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    ref.read(authProvider.notifier).clearMessages();

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          avatar: _selectedAvatar,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.pop();
      });
    }
  }
}
