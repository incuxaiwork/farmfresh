import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class FarmerProfileScreen extends ConsumerWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farmer Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Farmer Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Profile Card Info
            Container(
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
                        'https://api.dicebear.com/7.x/adventurer/svg?seed=FarmerJoe',
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
                    const SizedBox(height: 2),
                    Text(
                      user.phone!,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF647C72),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Farmer Partner'.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Farm Info
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Information',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F3F3)),
                  _InfoRow(
                    icon: Icons.eco_outlined,
                    label: 'Farm Name',
                    value: 'Green Valley Organic Farms',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Farm Address',
                    value: '18 Valley Road, local verifying zone',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Menu Options
            Container(
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
                  _MenuTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile Details',
                    onTap: () => context.push('/farmer-edit-profile'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F3F3)),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => context.push('/change-password'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F3F3)),
                  _MenuTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Withdrawals Payout',
                    onTap: () => context.push('/farmer-withdrawal'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F3F3)),
                  _MenuTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Settings',
                    onTap: () => context.push('/farmer-notifications'),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F3F3)),
                  _MenuTile(
                    icon: Icons.info_outlined,
                    title: 'About FarmFresh',
                    onTap: () {
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
                            'FarmFresh connects you directly with local farmers '
                            'for the freshest produce and dairy products.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72)),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Switch to Customer Mode
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).switchRole('Customer');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Switched to Customer Marketplace Mode',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                  context.go('/customer-main');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text(
                  'Switch to Customer Marketplace',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      content: Text('Are you sure you want to log out?', style: GoogleFonts.plusJakartaSans()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go('/login');
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: const Color(0xFF23312B),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
      onTap: onTap,
    );
  }
}
