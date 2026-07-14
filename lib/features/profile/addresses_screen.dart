import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/address_provider.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addressProvider.notifier).loadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);

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
            'My Addresses',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1FE28C43),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/add-address'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: addressState.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : addressState.addresses.isEmpty
                ? _buildEmptyState()
                : _buildAddressList(addressState),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF6EC),
              ),
              child: const Icon(Icons.location_off_outlined, size: 28, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses added',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a delivery address to get local crops shipped.',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
            ),
            const SizedBox(height: 24),
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-address'),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  'Add New Address',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(AddressState addressState) {
    final addresses = addressState.addresses;

    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: () =>
          ref.read(addressProvider.notifier).loadAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          final isDefault = address.isDefault;

          return Dismissible(
            key: Key(address.id),
            direction: address.isDefault
                ? DismissDirection.none
                : DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Address', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  content: Text('Are you sure you want to delete this delivery address?', style: GoogleFonts.plusJakartaSans()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              ref.read(addressProvider.notifier).deleteAddress(address.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address deleted successfully', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D6D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A2E5C45),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDefault ? const Color(0xFFE8F5E9) : const Color(0xFFFAFBF9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAddressIcon(address.label),
                    color: isDefault ? const Color(0xFF2E7D32) : const Color(0xFF647C72),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.label,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF2E7D32),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    address.fullAddress,
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF647C72), size: 20),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF23312B)),
                          const SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 8),
                            Text('Set as Default', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/edit-address', extra: address);
                    } else if (value == 'default') {
                      ref
                          .read(addressProvider.notifier)
                          .setDefault(address.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Default address updated!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getAddressIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('home')) return Icons.home_outlined;
    if (lower.contains('work') || lower.contains('office')) return Icons.work_outline;
    return Icons.location_on_outlined;
  }
}
