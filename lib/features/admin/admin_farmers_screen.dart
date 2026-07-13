import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class AdminFarmersScreen extends ConsumerStatefulWidget {
  const AdminFarmersScreen({super.key});

  @override
  ConsumerState<AdminFarmersScreen> createState() => _AdminFarmersScreenState();
}

class _AdminFarmersScreenState extends ConsumerState<AdminFarmersScreen> {
  String _selectedFilter = 'PENDING';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadFarmers(status: _selectedFilter);
    });
  }

  void _loadFarmersFiltered(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(adminProvider.notifier).loadFarmers(status: filter);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final farmers = adminState.farmers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Approvals'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton('Pending KYC', 'PENDING'),
                _buildFilterButton('Approved', 'APPROVED'),
                _buildFilterButton('Rejected', 'REJECTED'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : farmers.isEmpty
                    ? Center(
                        child: Text(
                          'No farmers in $_selectedFilter state',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: farmers.length,
                        itemBuilder: (context, index) {
                          final f = farmers[index];
                          final user = f['user'] as Map<String, dynamic>? ?? {};
                          final kycDoc = f['kycDocUrl'] as String? ?? '';
                          final isSuspended = user['deletedAt'] != null;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        f['farmName'] ?? 'No Farm Name',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSuspended
                                              ? Colors.grey
                                              : _selectedFilter == 'APPROVED'
                                                  ? Colors.green
                                                  : _selectedFilter == 'REJECTED'
                                                      ? Colors.red
                                                      : Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isSuspended ? 'SUSPENDED' : _selectedFilter,
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Owner: ${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'),
                                  Text('Email: ${user['email'] ?? ''}'),
                                  Text('Phone: ${user['phone'] ?? ''}'),
                                  Text('Address: ${f['farmAddress'] ?? ''}'),
                                  if (kycDoc.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'KYC Doc / Govt ID: $kycDoc',
                                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  if (_selectedFilter == 'PENDING')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _approveFarmer(f['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () => _rejectFarmer(f['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  if (_selectedFilter == 'APPROVED' && !isSuspended)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _suspendFarmer(f['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[700],
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Suspend Partner'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
      selected: isSelected,
      onSelected: (val) {
        if (val) _loadFarmersFiltered(value);
      },
      selectedColor: Colors.green,
    );
  }

  void _approveFarmer(String id) async {
    final ok = await ref.read(adminProvider.notifier).approveFarmer(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Farmer KYC Approved' : 'Failed to approve farmer'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _rejectFarmer(String id) async {
    final ok = await ref.read(adminProvider.notifier).rejectFarmer(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Farmer KYC Rejected' : 'Failed to reject farmer'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _suspendFarmer(String id) async {
    final ok = await ref.read(adminProvider.notifier).suspendFarmer(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Farmer Suspended' : 'Failed to suspend farmer'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
