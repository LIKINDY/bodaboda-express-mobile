import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'request_success_screen.dart';
import '../../../payment/presentation/screens/select_payment_screen.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({super.key});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  String _paymentMethod = 'Cash';

  Future<void> _changePaymentMethod() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SelectPaymentScreen()),
    );
    if (selected != null && mounted) setState(() => _paymentMethod = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pick-up & Drop-off
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: AppTheme.primaryBlue, size: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pick-up Location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Mlimani City Mall', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 30,
                          width: 2,
                          child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.accentRed, size: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Drop-off Location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Posta Mpya', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ride Type
            const Text('Ride Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.motorcycle, color: AppTheme.primaryBlue, size: 40),
                title: const Text('Bodaboda Express', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Fast & reliable'),
                trailing: const Text('15 min', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // Fare Breakdown
            const Text('Fare Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFareRow('Ride Fare', 'TSH 4,000'),
                    const SizedBox(height: 8),
                    _buildFareRow('VAT (18%)', 'TSH 720'),
                    const SizedBox(height: 8),
                    _buildFareRow('Promo', '-TSH 500', isPromo: true),
                    const Divider(height: 24),
                    _buildFareRow('Total', 'TSH 4,220', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.money, color: AppTheme.ecoGreen),
                  title: Text(_paymentMethod),
                trailing: TextButton(
                  onPressed: _changePaymentMethod,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestSuccessScreen()),
                );
              },
              child: const Text('Confirm Ride'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, {bool isPromo = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal || isPromo ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isPromo ? AppTheme.ecoGreen : Colors.black87,
          ),
        ),
      ],
    );
  }
}
