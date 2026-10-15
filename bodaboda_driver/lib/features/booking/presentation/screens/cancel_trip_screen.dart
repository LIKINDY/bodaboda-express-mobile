import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class CancelTripScreen extends StatefulWidget {
  const CancelTripScreen({super.key});

  @override
  State<CancelTripScreen> createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends State<CancelTripScreen> {
  int? _selectedReason;

  final List<String> _reasons = [
    'Waiting for too long',
    'Driver asked to cancel',
    'Wrong address shown',
    'Driver denied to come to pickup',
    'Wrong address shown',
    'The price is not reasonable',
    'Other',
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
        title: const Text('Cancel Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Please select the cause of cancellation',
              style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _reasons.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedReason == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey[200]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: isSelected ? AppTheme.primaryBlue : Colors.white,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _reasons[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _selectedReason != null
                  ? () => _showSadDialog(context)
                  : null,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😢', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text(
                "We're so sad about your cancellation",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/dashboard');
                  },
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
