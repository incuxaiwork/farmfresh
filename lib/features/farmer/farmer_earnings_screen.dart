import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Widget _buildEarningCard(String title, double amount, Color accentColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF647C72),
                ),
              ),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF23312B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel txn) {
    final isCredit = txn.type.toUpperCase() == 'CREDIT';
    final amountColor = isCredit ? const Color(0xFF2E7D32) : const Color(0xFFFF4D6D);
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconBg = isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF0F3);
    final iconColor = isCredit ? const Color(0xFF2E7D32) : const Color(0xFFFF4D6D);

    Color statusColor;
    switch (txn.status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = const Color(0xFF2E7D32);
        break;
      case 'PENDING':
        statusColor = const Color(0xFFE28C43);
        break;
      case 'FAILED':
        statusColor = const Color(0xFFFF4D6D);
        break;
      default:
        statusColor = const Color(0xFF647C72);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF23312B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _dateFormat.format(txn.createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF647C72),
                    fontWeight: FontWeight.w500,
                  ),
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
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  txn.status.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerEarningsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Earnings Wallet',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () => ref.read(farmerEarningsProvider.notifier).loadEarnings(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Green Gradient Core Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F2E7D32),
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL WALLET BALANCE',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${state.earnings.totalEarnings.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Grid Cards
                  _buildEarningCard('Monthly Revenue', state.earnings.monthlyEarnings, const Color(0xFF219EBC), const Color(0xFFF0F9FB)),
                  const SizedBox(height: 10),
                  _buildEarningCard('Weekly Earnings', state.earnings.weeklyEarnings, const Color(0xFFE28C43), const Color(0xFFFFF1E6)),
                  const SizedBox(height: 10),
                  _buildEarningCard('Daily Earnings', state.earnings.dailyEarnings, const Color(0xFF8338EC), const Color(0xFFF5EFFF)),
                  const SizedBox(height: 10),
                  _buildEarningCard('Pending Withdrawals', state.earnings.pendingWithdrawals, const Color(0xFFFFB703), const Color(0xFFFFFDF0)),
                  const SizedBox(height: 10),
                  _buildEarningCard('Completed Withdrawals', state.earnings.completedWithdrawals, const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                  const SizedBox(height: 16),
                  
                  // Request Withdrawal Button
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
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/farmer-withdrawal'),
                      icon: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                      label: Text(
                        'Request Payout Withdrawal',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Transaction History',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF23312B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF647C72)),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions posted yet.',
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...state.transactions.map(_buildTransactionItem),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
