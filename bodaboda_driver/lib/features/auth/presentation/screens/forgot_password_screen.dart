import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _selectedMethod = 'email'; // 'sms' or 'email'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select which contact details should we use to reset your password',
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // SMS Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethod = 'sms';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMethod == 'sms' ? AppTheme.ecoGreen : Colors.grey[300]!,
                      width: _selectedMethod == 'sms' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_android, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Via SMS',
                              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '***** ***70',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedMethod == 'sms')
                        const Icon(Icons.check_circle, color: AppTheme.ecoGreen),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Email Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethod = 'email';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMethod == 'email' ? AppTheme.ecoGreen : Colors.grey[300]!,
                      width: _selectedMethod == 'email' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Via Email',
                              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '**** **** xyz@xyz.com',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedMethod == 'email')
                        const Icon(Icons.check_circle, color: AppTheme.ecoGreen),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: () {
                  context.push('/forgot-password-verify');
                },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
