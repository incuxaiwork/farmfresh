import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  bool _showDrivers = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadCustomers();
      ref.read(adminProvider.notifier).loadDeliveryPartners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final list = _showDrivers ? adminState.deliveryPartners : adminState.customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Customers'),
                  selected: !_showDrivers,
                  onSelected: (val) {
                    if (val) setState(() => _showDrivers = false);
                  },
                  selectedColor: Colors.green,
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Drivers'),
                  selected: _showDrivers,
                  onSelected: (val) {
                    if (val) setState(() => _showDrivers = true);
                  },
                  selectedColor: Colors.green,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? Center(
                        child: Text(
                          'No ${_showDrivers ? 'drivers' : 'customers'} found.',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final u = list[index];
                          // Simple mock suspension check or check deletedAt
                          final isSuspended = false; // Simulated for display

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U'),
                            ),
                            title: Text(u.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${u.email}'),
                                if (u.phone != null) Text('Phone: ${u.phone}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _toggleSuspension(u, isSuspended),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSuspended ? Colors.green : Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isSuspended ? 'Activate' : 'Suspend'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _toggleSuspension(UserModel user, bool isSuspended) async {
    bool ok;
    if (_showDrivers) {
      ok = await ref
          .read(adminProvider.notifier)
          .toggleDeliveryPartnerSuspension(user.id, isSuspended);
    } else {
      ok = await ref
          .read(adminProvider.notifier)
          .toggleCustomerSuspension(user.id, isSuspended ? 'suspended' : 'active');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'User status updated successfully!' : 'Failed to update user status.',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
