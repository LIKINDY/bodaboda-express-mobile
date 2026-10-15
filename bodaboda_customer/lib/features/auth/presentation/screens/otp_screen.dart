import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_copy.dart';
import '../../../../core/services/user_profile_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyFocusNodes = List.generate(6, (_) => FocusNode());

  // 5-minute timer
  late Timer _timer;
  int _secondsRemaining = 5 * 60; // 5 minutes
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    for (var f in _keyFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _fullOtp => _controllers.map((c) => c.text).join();

  void _onFieldChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_fullOtp.length == 6) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(KeyEvent event, int index) {
    if (event.logicalKey.keyLabel == 'Backspace' && _controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() async {
    final otp = _fullOtp;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tafadhali ingiza namba 6 za OTP'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    await UserProfileService.instance.recordRideActivityOrVerification();
    if (mounted) {
      setState(() => _isLoading = false);
      context.goNamed('dashboard');
    }
  }

  void _resendOtp() {
    if (!_canResend) return;
    setState(() {
      _secondsRemaining = 5 * 60;
      _canResend = false;
      for (var c in _controllers) c.clear();
    });
    _startTimer();
    _focusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP mpya imetumwa kwa ${widget.phoneNumber}'),
        backgroundColor: AppTheme.ecoGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = _secondsRemaining <= 0;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sms_outlined, color: AppTheme.primaryBlue, size: 30),
              ),
              const SizedBox(height: 24),
              Text(
                appCopy(context, 'Verify your number', 'Thibitisha namba yako'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: appCopy(context, 'We sent a 6-digit code to\n', 'Tumekutumia namba 6 za siri (OTP) kwa\n'),
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                  children: [
                    TextSpan(
                      text: widget.phoneNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return KeyboardListener(
                    focusNode: _keyFocusNodes[index],
                    onKeyEvent: (event) => _onKeyPressed(event, index),
                    child: SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                              : colors.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? AppTheme.primaryBlue
                                  : colors.outline,
                            ),
                          ),
                        ),
                        onChanged: (val) => _onFieldChanged(val, index),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Timer
              Center(
                child: Column(
                  children: [
                    if (!isExpired) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: _secondsRemaining < 60 ? AppTheme.accentRed : Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            appCopy(context, 'Code expires in $_timerDisplay', 'OTP itakwisha baada ya $_timerDisplay'),
                            style: TextStyle(
                              color: _secondsRemaining < 60 ? AppTheme.accentRed : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        appCopy(context, 'Code expired', 'OTP imekwisha muda wake!'),
                        style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _canResend ? _resendOtp : null,
                      child: Text(
                        appCopy(context, 'Resend code', 'Tuma tena OTP'),
                        style: TextStyle(
                          color: _canResend ? AppTheme.primaryBlue : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          appCopy(context, 'Verify code', 'Thibitisha OTP'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
