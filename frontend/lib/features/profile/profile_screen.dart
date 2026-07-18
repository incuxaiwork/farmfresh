import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_image/crop_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/profile_image_provider.dart';
import '../core/widgets/profile_image_picker_dialog.dart';
import '../core/widgets/custom_button.dart';
import '../core/services/cloudinary_upload_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF2F8F4),
            const Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              children: [
                _buildProfileHeader(context, user, ref),
                const SizedBox(height: 20),
                _buildProfileMenu(context),
                const SizedBox(height: 20),
                _buildLogoutButton(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildProfileHeader(BuildContext context, dynamic user, WidgetRef ref) {
    final profileImage = ref.watch(profileImageProvider(user.id));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2E5C45),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  ProfileImagePickerDialog.show(
                    context,
                    userId: user.id,
                    onImageSelected: (base64Image, scale, dx, dy) {
                      ref.read(profileImageProvider(user.id).notifier).updateProfileImage(
                            base64Image,
                            scale: scale,
                            dx: dx,
                            dy: dy,
                          );
                      _uploadProfilePicture(context, ref, user.id, base64Image);
                    },
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                        child: profileImage != null && profileImage.image.startsWith('data:image')
                            ? Transform.translate(
                                offset: Offset(profileImage.dx, profileImage.dy),
                                child: Transform.scale(
                                  scale: profileImage.scale,
                                  child: Image.memory(
                                    base64Decode(profileImage.image.split(',')[1]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : (user.avatar != null && user.avatar!.isNotEmpty && !user.avatar!.contains('dicebear'))
                                ? Image.network(
                                    user.avatar!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    'https://api.dicebear.com/7.x/adventurer/svg?seed=${user.name}',
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF23312B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF647C72),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.phone != null && user.phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.phone!,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF647C72),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildProfileMenu(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2E5C45),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              _menuTile(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your name, phone number',
                onTap: () => context.push('/edit-profile'),
              ),
              const Divider(height: 1, color: Color(0xFFF3F3F3)),
              _menuTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => context.push('/change-password'),
              ),
              const Divider(height: 1, color: Color(0xFFF3F3F3)),
              _menuTile(
                context,
                icon: Icons.location_on_outlined,
                title: 'Delivery Addresses',
                subtitle: 'Manage your addresses',
                onTap: () => context.push('/addresses'),
              ),
              const Divider(height: 1, color: Color(0xFFF3F3F3)),
              _menuTile(
                context,
                icon: Icons.info_outlined,
                title: 'About FarmFresh',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, color: Color(0xFFF3F3F3)),
              _menuTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => _showPlaceholderPage(context, 'Terms & Conditions'),
              ),
              const Divider(height: 1, color: Color(0xFFF3F3F3)),
              _menuTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _showPlaceholderPage(context, 'Privacy Policy'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: const Color(0xFF23312B),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF647C72),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF647C72), size: 16),
      onTap: onTap,
    );
  }

  static Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return CustomButton(
      text: 'Log Out',
      icon: Icons.logout,
      isOutlined: true,
      backgroundColor: const Color(0xFFFF4D6D),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to log out?', style: GoogleFonts.plusJakartaSans()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF4D6D)),
                child: Text('Log Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        }
      },
    );
  }

  static void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FarmFresh',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.spa, color: Color(0xFF2E7D32), size: 32),
      ),
      children: [
        Text(
          'FarmFresh connects you directly with local farmers for the freshest produce and dairy products.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF647C72)),
        ),
      ],
    );
  }

  static void _showPlaceholderPage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page coming soon')),
    );
  }

  static Future<void> _uploadProfilePicture(
    BuildContext context, WidgetRef ref, String userId, String base64Image) async {
    try {
      final response = await ref.read(authRepositoryProvider).uploadProfilePicture(userId, base64Image);

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );

        ref.read(authProvider.notifier).clearMessages();
        
        if (context.mounted) {
          ref.read(authProvider.notifier).loadCurrentUser();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFFF4D6D),
        ),
      );
    }
  }
}