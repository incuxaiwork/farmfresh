import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/farmer_provider.dart';
import '../../models/withdrawal_model.dart';
import '../../models/bank_account_model.dart';

class FarmerWithdrawalScreen extends ConsumerStatefulWidget {
  const FarmerWithdrawalScreen({super.key});

  @override
  ConsumerState<FarmerWithdrawalScreen> createState() => _FarmerWithdrawalScreenState();
}

class _FarmerWithdrawalScreenState extends ConsumerState<FarmerWithdrawalScreen> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmerWithdrawalProvider.notifier).loadMore();
    }
  }

  Future<void> _requestWithdrawal() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Color(0xFFFF4D6D)),
      );
      return;
    }
    final success = await ref.read(farmerWithdrawalProvider.notifier).requestWithdrawal(amount);
    if (!mounted) return;
    if (success) {
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request submitted!'), backgroundColor: Color(0xFF2E7D32)),
      );
    }
  }

  Future<void> _saveBankDetails() async {
    if (_bankNameController.text.isEmpty || _accountNumberController.text.isEmpty || _accountHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank details'), backgroundColor: Color(0xFFFF4D6D)),
      );
      return;
    }
    final account = BankAccountModel(
      id: '',
      bankName: _bankNameController.text,
      accountNumber: _accountNumberController.text,
      accountHolder: _accountHolderController.text,
    );
    final success = await ref.read(farmerWithdrawalProvider.notifier).updateBankAccount(account);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank details saved successfully'), backgroundColor: Color(0xFF2E7D32)),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = const Color(0xFFFFFDF0);
        textColor = const Color(0xFFE28C43);
        break;
      case 'COMPLETED':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFFF0F3);
        textColor = const Color(0xFFFF4D6D);
        break;
      default:
        bgColor = const Color(0xFFFAFBF9);
        textColor = const Color(0xFF647C72);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildWithdrawalItem(WithdrawalModel withdrawal) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${withdrawal.amount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              _buildStatusBadge(withdrawal.status),
            ],
          ),
          const SizedBox(height: 6),
          if (withdrawal.bankName != null || withdrawal.accountNumber != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${withdrawal.bankName ?? ''} - ${withdrawal.accountNumber ?? ''}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF647C72),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (withdrawal.accountHolder != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Holder: ${withdrawal.accountHolder}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF647C72),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Text(
            _dateFormat.format(withdrawal.createdAt),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: const Color(0xFF8D99AE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerWithdrawalProvider);

    ref.listen<FarmerWithdrawalState>(farmerWithdrawalProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!), backgroundColor: const Color(0xFF2E7D32)),
        );
        ref.read(farmerWithdrawalProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null && next.actionMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: const Color(0xFFFF4D6D)),
        );
        ref.read(farmerWithdrawalProvider.notifier).clearMessages();
      }
    });

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
            'Request Payout',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : RefreshIndicator(
                color: const Color(0xFF2E7D32),
                onRefresh: () => ref.read(farmerWithdrawalProvider.notifier).loadWithdrawals(),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Request Amount Card
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Request Amount Withdrawal',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Withdrawal Amount',
                              prefixText: '₹ ',
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
                              fillColor: const Color(0xFFFAFBF9),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE28C43), Color(0xFFF3A05B)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _requestWithdrawal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Request Withdrawal',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bank Account Info Form
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bank Account Details',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF23312B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bankNameController,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Bank Name',
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
                              fillColor: const Color(0xFFFAFBF9),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Account Number',
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
                              fillColor: const Color(0xFFFAFBF9),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _accountHolderController,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF23312B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Account Holder Name',
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
                              fillColor: const Color(0xFFFAFBF9),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: _saveBankDetails,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF2E7D32)),
                                foregroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Save Account Details',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Withdrawal Request History',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF23312B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.withdrawals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Color(0xFF647C72)),
                              const SizedBox(height: 12),
                              Text(
                                'No payout withdrawals requested yet.',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ...state.withdrawals.map(_buildWithdrawalItem),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
