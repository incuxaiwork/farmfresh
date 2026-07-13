import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/farmer_provider.dart';
import '../../models/earnings_model.dart';

class FarmerEarningsScreen extends ConsumerStatefulWidget {
  const FarmerEarningsScreen({super.key});

  @override
  ConsumerState<FarmerEarningsScreen> createState() => _FarmerEarningsScreenState();
}

class _FarmerEarningsScreenState extends ConsumerState<FarmerEarningsScreen> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmerEarningsProvider.notifier).loadMoreTransactions();
    }
  }

  Widget _buildEarningCard(String title, double amount, Color color, {bool large = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: large ? 20 : 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: large ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: large ? 28 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel txn) {
    final isCredit = txn.type.toUpperCase() == 'CREDIT';
    final amountColor = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconBg = isCredit ? Colors.green[50] : Colors.red[50];
    final iconColor = isCredit ? Colors.green : Colors.red;

    Color statusColor;
    switch (txn.status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'FAILED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat.format(txn.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    txn.status,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerEarningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: () => ref.read(farmerEarningsProvider.notifier).loadEarnings(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildEarningCard('Total Earnings', state.earnings.totalEarnings, Colors.green, large: true),
                  const SizedBox(height: 10),
                  _buildEarningCard('Monthly Earnings', state.earnings.monthlyEarnings, Colors.blue),
                  const SizedBox(height: 10),
                  _buildEarningCard('Weekly Earnings', state.earnings.weeklyEarnings, Colors.teal),
                  const SizedBox(height: 10),
                  _buildEarningCard('Daily Earnings', state.earnings.dailyEarnings, Colors.indigo),
                  const SizedBox(height: 10),
                  _buildEarningCard('Pending Withdrawals', state.earnings.pendingWithdrawals, Colors.orange),
                  const SizedBox(height: 10),
                  _buildEarningCard('Completed Withdrawals', state.earnings.completedWithdrawals, Colors.green),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/farmer-withdrawal'),
                      icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                      label: const Text('Request Withdrawal', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (state.transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text('No transactions yet', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...state.transactions.map(_buildTransactionItem),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(color: Colors.green)),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
