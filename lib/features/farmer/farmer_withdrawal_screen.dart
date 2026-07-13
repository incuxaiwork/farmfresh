import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    final success = await ref.read(farmerWithdrawalProvider.notifier).requestWithdrawal(amount);
    if (!mounted) return;
    if (success) {
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request submitted'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _saveBankDetails() async {
    if (_bankNameController.text.isEmpty || _accountNumberController.text.isEmpty || _accountHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank details')),
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
        const SnackBar(content: Text('Bank details saved'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
      case 'COMPLETED':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      case 'REJECTED':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWithdrawalItem(WithdrawalModel withdrawal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${withdrawal.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                _buildStatusBadge(withdrawal.status),
              ],
            ),
            const SizedBox(height: 8),
            if (withdrawal.bankName != null || withdrawal.accountNumber != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${withdrawal.bankName ?? ''} - ${withdrawal.accountNumber ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            if (withdrawal.accountHolder != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Holder: ${withdrawal.accountHolder}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            Text(
              _dateFormat.format(withdrawal.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerWithdrawalProvider);

    ref.listen<FarmerWithdrawalState>(farmerWithdrawalProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
        ref.read(farmerWithdrawalProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null && next.actionMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(farmerWithdrawalProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: () => ref.read(farmerWithdrawalProvider.notifier).loadWithdrawals(),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Withdrawal',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _requestWithdrawal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Request', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bank Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bankNameController,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _accountNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Account Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _accountHolderController,
                          decoration: const InputDecoration(
                            labelText: 'Account Holder',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _saveBankDetails,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Save Bank Details', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Withdrawal History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (state.withdrawals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text('No withdrawals yet', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...state.withdrawals.map(_buildWithdrawalItem),
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
