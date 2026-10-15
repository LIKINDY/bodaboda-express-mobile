import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';

class SelectPaymentScreen extends StatefulWidget {
  const SelectPaymentScreen({super.key});

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  int _selectedIndex = 0;

  final List<_PaymentMethod> _methods = [
    _PaymentMethod(
      icon: Icons.credit_card,
      name: 'M-Pesa',
      detail: '•••• •••• •••• 4321',
      color: AppTheme.ecoGreen,
    ),
    _PaymentMethod(
      icon: Icons.credit_card,
      name: 'Tigo Pesa',
      detail: '•••• •••• •••• 8970',
      color: AppTheme.primaryBlue,
    ),
    _PaymentMethod(
      icon: Icons.account_balance_wallet,
      name: 'My Wallet',
      detail: 'TSH 25,000',
      color: Colors.orange,
    ),
    _PaymentMethod(
      icon: Icons.attach_money,
      name: 'Cash',
      detail: '',
      color: AppTheme.ecoGreen,
    ),
    _PaymentMethod(
      icon: Icons.email_outlined,
      name: 'Airtel Money',
      detail: '•••• •••• •••• 5678',
      color: AppTheme.accentRed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select payment method',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              appCopy(context, 'Choose how you want to pay.', 'Chagua njia ya kulipa.'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _methods.length,
              itemBuilder: (context, index) {
                final method = _methods[index];
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: method.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(method.icon, color: method.color, size: 22),
                    ),
                    title: Text(
                      method.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: method.detail.isNotEmpty
                        ? Text(method.detail, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))
                        : null,
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _methods[_selectedIndex].name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(appCopy(context, 'Use this payment method', 'Tumia njia hii ya malipo'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String name;
  final String detail;
  final Color color;

  _PaymentMethod({
    required this.icon,
    required this.name,
    required this.detail,
    required this.color,
  });
}
