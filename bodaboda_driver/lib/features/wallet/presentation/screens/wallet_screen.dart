import 'package:flutter/material.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) => const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        ListTile(leading: Icon(Icons.account_balance_wallet), title: Text('Wallet updated'), subtitle: Text('Your latest demo balance is available.')),
                        ListTile(leading: Icon(Icons.directions_bike), title: Text('Trip complete'), subtitle: Text('A sample transaction was added to this wallet.')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard(
                    label: 'Available Balance',
                    amount: 'TZS 350,000',
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceCard(
                    label: 'Total Expend',
                    amount: 'TZS 120,000',
                    color: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Money Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddMoneySheet(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Money'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(5, (index) => _buildTransactionItem(
              title: "Boda Ride to 'Home'",
              subtitle: 'TZS 3,000',
              amount: '-TZS 3,000',
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard({required String label, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.ecoGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTheme.ecoGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: AppTheme.accentRed,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneySheet(BuildContext context) {
    String? _selectedNetwork;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Select Mobile Money Network',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNetworkDropdown(setModalState, _selectedNetwork, (v) {
                    setModalState(() => _selectedNetwork = v);
                  }),
                  const SizedBox(height: 16),
                  ...[
                    for (final provider in ['M-Pesa', 'Tigo Pesa'])
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RadioListTile<String>(
                          title: Text(provider),
                          value: provider,
                          groupValue: _selectedNetwork,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (v) => setModalState(() => _selectedNetwork = v),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  const Text('Account details', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const TextField(decoration: InputDecoration(hintText: 'Account details')),
                  const SizedBox(height: 12),
                  const TextField(decoration: InputDecoration(hintText: 'Account details')),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuccessDialog(context);
                    },
                    child: const Text('Save Payment Method'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNetworkDropdown(
    StateSetter setModalState,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(hintText: 'Select Network'),
      value: selected,
      items: ['M-Pesa', 'Tigo Pesa', 'Airtel Money'].map((s) {
        return DropdownMenuItem<String>(value: s, child: Text(s));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ecoGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.ecoGreen, size: 64),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Money Success',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Amount',
                style: TextStyle(color: AppTheme.textLight),
              ),
              const SizedBox(height: 8),
              const Text(
                'TZS 100,000',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
