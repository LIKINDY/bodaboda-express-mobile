import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class BodabodaDetailsScreen extends StatelessWidget {
  const BodabodaDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Bodaboda Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Motorcycle image
            Container(
              height: 200,
              color: AppTheme.backgroundLight,
              child: const Center(
                child: Icon(Icons.motorcycle, size: 120, color: AppTheme.primaryBlue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Motorcycle features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureRow('Helmet Provided:', 'Yes'),
                  _buildDivider(),
                  _buildFeatureRow('Rider Experience:', '2+ Years'),
                  _buildDivider(),
                  _buildFeatureRow('Vehicle Plate No.:', '013455-329'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/checkout'),
                      child: const Text('Confirm Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[200], height: 1);
  }
}
