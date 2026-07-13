import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/delivery_provider.dart';

class DeliveryEarningsScreen extends ConsumerStatefulWidget {
  const DeliveryEarningsScreen({super.key});

  @override
  ConsumerState<DeliveryEarningsScreen> createState() => _DeliveryEarningsScreenState();
}

class _DeliveryEarningsScreenState extends ConsumerState<DeliveryEarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryEarningsProvider.notifier).loadEarnings());
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(deliveryEarningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: earningsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryEarningsProvider.notifier).loadEarnings(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEarningsCards(earningsState),
                    const SizedBox(height: 20),
                    const Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (earningsState.transactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...earningsState.transactions.map((t) => _buildTransactionTile(t)),
                    if (earningsState.hasMore && earningsState.transactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: earningsState.isLoadingMore
                              ? const CircularProgressIndicator()
                              : TextButton(
                                  onPressed: () => ref.read(deliveryEarningsProvider.notifier).loadMoreTransactions(),
                                  child: const Text('Load More'),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEarningsCards(DeliveryEarningsState state) {
    final earnings = state.earnings;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildEarningCard('Today', '₹${earnings.dailyEarnings.toStringAsFixed(0)}', Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildEarningCard('This Week', '₹${earnings.weeklyEarnings.toStringAsFixed(0)}', Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildEarningCard('This Month', '₹${earnings.monthlyEarnings.toStringAsFixed(0)}', Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _buildEarningCard('Total', '₹${earnings.totalEarnings.toStringAsFixed(0)}', Colors.teal)),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic transaction) {
    String dateStr = '';
    try {
      dateStr = DateFormat('dd/MM/yyyy').format(transaction.createdAt);
    } catch (_) {
      dateStr = '';
    }

    final isCredit = transaction.type == 'CREDIT' || transaction.type == 'earning';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(transaction.description.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
