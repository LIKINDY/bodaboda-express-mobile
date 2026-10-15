import 'package:flutter/material.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class SpecialOffersScreen extends StatelessWidget {
  const SpecialOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      {'title': 'Discount', 'value': '15% off', 'type': 'discount'},
      {'title': 'Cashback', 'value': '15%', 'type': 'cashback'},
      {'title': 'Discount', 'value': '20% off', 'type': 'discount'},
      {'title': 'Cashback', 'value': '10%', 'type': 'cashback'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Special Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = offers[index];
          final isDiscount = offer['type'] == 'discount';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        offer['value']!,
                        style: TextStyle(
                          color: isDiscount ? AppTheme.primaryBlue : AppTheme.ecoGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDiscount
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : AppTheme.ecoGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDiscount ? Icons.local_offer_outlined : Icons.monetization_on_outlined,
                    color: isDiscount ? AppTheme.primaryBlue : AppTheme.ecoGreen,
                    size: 22,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
