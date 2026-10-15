import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Request Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Trip details
            _buildSection([
              _buildRow('Pickup', '2013 payments (13 Wikid Hyard Elkir)', '1.5km'),
              const SizedBox(height: 12),
              _buildRow('Destination', '2013 Mustang Shelby GT (Willard Hyard)', null),
            ]),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: 'Eard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: 'Time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Promo code
            TextFormField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: 'Enter Promo Code',
                suffixIcon: IconButton(
                  onPressed: () {
                    final code = _promoController.text.trim();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(code.isEmpty ? 'Enter a promo code first.' : 'Promo code $code checked (demo).')),
                    );
                  },
                  icon: const Icon(Icons.discount_outlined, color: AppTheme.textLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment summary
            const Text('Payment summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSection([
              _buildPaymentRow('Model', '015000'),
              const SizedBox(height: 8),
              _buildPaymentRow('Destination', '760hp'),
              const Divider(height: 24),
              _buildPaymentRow('Total', '9600', isBold: true),
              const SizedBox(height: 4),
              _buildPaymentRow('Total', '0155.00', isBold: true),
            ]),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => context.push('/select-payment'),
              child: const Text('Confirm Booking'),
            ),

            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.accentRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel Trip', style: TextStyle(color: AppTheme.accentRed)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildRow(String label, String value, String? distance) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (distance != null)
          Text(distance, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? AppTheme.textDark : AppTheme.textLight, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    context.push('/cancel-trip');
  }
}
