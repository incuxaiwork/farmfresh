import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0F2E5C45),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
                        ),
                      ),
                      Text(
                        'My Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF23312B),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                _buildProfileHeader(user),
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

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
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
              child: Image.network(
                'https://api.dicebear.com/7.x/adventurer/svg?seed=Lucky',
                fit: BoxFit.cover,
              ),
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
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
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
    );
  }

  Widget _menuTile(
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

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
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
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF4D6D),
          side: const BorderSide(color: Color(0xFFFF4D6D)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout, size: 16),
        label: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
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

  void _showPlaceholderPage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title page coming soon')),
    );
  }
}
