import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
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
              'Are you sure you want to delete your account? Please read how account deletion will affect.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Deleting your account removes personal information our database. Your email becomes permanently reserved and same email cannot be re-use to register a new account.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.darkTextSecondary 
                    : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Demo action'),
                      content: const Text('Account deletion will be connected when the backend is ready.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep account')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Understood')),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
