import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/driver_login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/document_upload_screen.dart';
import '../../features/auth/presentation/screens/set_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_verify_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_set_new_screen.dart';
import '../../features/auth/presentation/screens/reset_success_screen.dart';
import '../../features/dashboard/presentation/screens/driver_dashboard_screen.dart';
import '../../features/wallet/presentation/screens/fuel_wallet_screen.dart';
import '../../features/history/presentation/screens/driver_ride_history_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/booking/presentation/screens/driver_active_ride_screen.dart';
import '../../features/booking/presentation/screens/bodaboda_details_screen.dart';
import '../../features/booking/presentation/screens/checkout_screen.dart';
import '../../features/booking/presentation/screens/cancel_trip_screen.dart';
import '../../features/booking/presentation/screens/rating_screen.dart';
import '../../features/booking/presentation/screens/select_payment_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/change_language_screen.dart';
import '../../features/settings/presentation/screens/delete_account_screen.dart';
import '../../features/settings/presentation/screens/contact_us_screen.dart';
import '../../features/settings/presentation/screens/referral_screen.dart';
import '../../features/settings/presentation/screens/about_us_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/help_support_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Welcome / Landing
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const DriverLoginScreen(),
    ),

    // Auth Flow - Sign Up
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/document-upload',
      name: 'document-upload',
      builder: (context, state) => const DocumentUploadScreen(),
    ),
    GoRoute(
      path: '/set-password',
      name: 'set-password',
      builder: (context, state) => const SetPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-success',
      name: 'reset-success',
      builder: (context, state) => const ResetSuccessScreen(),
    ),

    // Auth Flow - Sign In
    GoRoute(
      path: '/sign-in',
      name: 'sign-in',
      builder: (context, state) => const SignInScreen(),
    ),

    // Auth Flow - Forgot Password
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-password-verify',
      name: 'forgot-password-verify',
      builder: (context, state) => const ForgotPasswordVerifyScreen(),
    ),
    GoRoute(
      path: '/forgot-password-otp',
      name: 'forgot-password-otp',
      builder: (context, state) => const ForgotPasswordOtpScreen(),
    ),
    GoRoute(
      path: '/forgot-password-set-new',
      name: 'forgot-password-set-new',
      builder: (context, state) => const ForgotPasswordSetNewScreen(),
    ),

    // Main App
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/fuel-wallet',
      name: 'fuelWallet',
      builder: (context, state) => const FuelWalletScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const DriverRideHistoryScreen(),
    ),
    GoRoute(
      path: '/earnings',
      name: 'earnings',
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Booking Flow
    GoRoute(
      path: '/driver-active-ride',
      name: 'driver-active-ride',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return DriverActiveRideScreen(initialTripData: data);
      },
    ),
    GoRoute(
      path: '/bodaboda-details',
      name: 'bodaboda-details',
      builder: (context, state) => const BodabodaDetailsScreen(),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/cancel-trip',
      name: 'cancel-trip',
      builder: (context, state) => const CancelTripScreen(),
    ),
    GoRoute(
      path: '/rating',
      name: 'rating',
      builder: (context, state) => const DriverRatingScreen(),
    ),
    GoRoute(
      path: '/select-payment',
      name: 'select-payment',
      builder: (context, state) => const SelectPaymentScreen(),
    ),

    // Settings Flow
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/change-language',
      name: 'change-language',
      builder: (context, state) => const ChangeLanguageScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      name: 'delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/contact-us',
      name: 'contact-us',
      builder: (context, state) => const ContactUsScreen(),
    ),
    GoRoute(
      path: '/referral',
      name: 'referral',
      builder: (context, state) => const ReferralScreen(),
    ),
    GoRoute(
      path: '/about-us',
      name: 'about-us',
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/help-support',
      name: 'help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
  ],
);
