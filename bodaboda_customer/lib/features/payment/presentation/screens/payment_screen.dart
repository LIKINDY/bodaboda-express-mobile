import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'M-Pesa';

  Future<void> _choosePaymentMethod() async {
    final selected = await context.pushNamed<String>('select-payment');
    if (selected != null && mounted) setState(() => _selectedMethod = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(appCopy(context, 'Payment', 'Malipo')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.motorcycle, color: AppTheme.primaryBlue, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bodaboda Express', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('4.9 (530 reviews)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Charge section
            const Text('Charge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildChargeRow('Bodaboda/1 hour', 'TSH 4,000'),
            const SizedBox(height: 10),
            _buildChargeRow('Vat (18%)', 'TSH 720'),
            const SizedBox(height: 10),
            _buildChargeRow('Promo Code', '-TSH 500', isPromo: true),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildChargeRow('Total', 'TSH 4,220', isTotal: true),
            const SizedBox(height: 28),

            // Payment method section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select payment method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _choosePaymentMethod,
                  child: const Text('View All', style: TextStyle(color: AppTheme.primaryBlue)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment options
            _buildPaymentOption(Icons.credit_card, 'M-Pesa', '•••• 4321'),
            const SizedBox(height: 10),
            _buildPaymentOption(Icons.credit_card, 'Tigo Pesa', '•••• 8970'),
            const SizedBox(height: 10),
            _buildPaymentOption(Icons.account_balance_wallet, 'My Wallet', ''),
            const SizedBox(height: 10),
            _buildPaymentOption(Icons.attach_money, 'Cash', ''),

            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pushNamed('payment-success', extra: _selectedMethod),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Confirm Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeRow(String label, String amount, {bool isPromo = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey.shade600,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal || isPromo ? FontWeight.bold : FontWeight.w500,
            color: isPromo ? AppTheme.ecoGreen : Colors.black87,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(IconData icon, String name, String detail) {
    final isSelected = _selectedMethod == name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surface,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selectedMethod = name),
        child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (detail.isNotEmpty) Text(detail, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
        ],
        ),
      ),
    );
  }
}
