import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class SelectPaymentScreen extends StatefulWidget {
  const SelectPaymentScreen({super.key});

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  int _selected = 0;

  final List<Map<String, dynamic>> _methods = [
    {
      'title': 'Mobile Money',
      'subtitle': '(M-Pesa/TigoPesa)',
      'icon': Icons.phone_android,
      'color': Color(0xFF4CAF50),
      'badge': true,
    },
    {
      'title': 'Digital Wallet',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppTheme.primaryBlue,
    },
    {
      'title': 'Cash',
      'icon': Icons.attach_money,
      'color': Color(0xFF795548),
    },
    {
      'title': 'Maloddress@mail.com',
      'icon': Icons.paypal,
      'color': Color(0xFF003087),
    },
    {
      'title': 'Google Pay',
      'icon': Icons.g_mobiledata,
      'color': Colors.blue,
    },
    {
      'title': 'Phone Pay',
      'icon': Icons.phone_iphone,
      'color': Color(0xFF5F259F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Select payment method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select payment method you want to use',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: _methods.length,
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selected == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (method['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(method['icon'] as IconData, color: method['color'] as Color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (method['subtitle'] != null)
                                  Text(
                                    method['subtitle'] as String,
                                    style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (method['badge'] == true)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildProviderBadge('M', Colors.green),
                                const SizedBox(width: 4),
                                _buildProviderBadge('T', Colors.blue),
                              ],
                            ),
                          const SizedBox(width: 8),
                          Radio<int>(
                            value: index,
                            groupValue: _selected,
                            activeColor: AppTheme.primaryBlue,
                            onChanged: (v) => setState(() => _selected = v!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Confirm Ride'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderBadge(String letter, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(letter, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
