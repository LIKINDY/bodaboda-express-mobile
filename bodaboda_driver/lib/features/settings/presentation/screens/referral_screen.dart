import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refer a friend and Earn TSH 5,000',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppTheme.darkDivider 
                      : Colors.grey.shade300
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RkMFucd', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    tooltip: 'Copy referral code',
                    onPressed: () async {
                      await Clipboard.setData(const ClipboardData(text: 'RkMFucd'));
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral code copied.')));
                    },
                    icon: Icon(Icons.copy, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkTextSecondary : Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(const ClipboardData(text: 'Bodaboda Express referral code: RkMFucd'));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation text copied. Share it with a friend.')));
                },
                child: const Text('Invite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
