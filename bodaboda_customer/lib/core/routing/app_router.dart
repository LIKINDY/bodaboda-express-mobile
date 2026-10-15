import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/customer_sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/ride/presentation/screens/ride_summary_screen.dart';
import '../../features/ride/presentation/screens/ride_match_screen.dart';
import '../../features/ride/presentation/screens/request_success_screen.dart';
import '../../features/ride/presentation/screens/active_ride_tracking_screen.dart';
import '../../features/ride/presentation/screens/cancel_ride_screen.dart';
import '../../features/ride/presentation/screens/cancel_confirmation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/history/presentation/screens/ride_history_screen.dart';
import '../../features/payment/presentation/screens/select_payment_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/payment/presentation/screens/payment_success_screen.dart';
import '../../features/payment/presentation/screens/rating_screen.dart';
import '../../features/payment/presentation/screens/thank_you_screen.dart';
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
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const CustomerSignUpScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    // Ride Flow
    GoRoute(
      path: '/ride-summary',
      name: 'ride-summary',
      builder: (context, state) => const RideSummaryScreen(),
    ),
    GoRoute(
      path: '/ride-match',
      name: 'ride-match',
      builder: (context, state) => RideMatchScreen(bookingData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: '/ride-success',
      name: 'ride-success',
      builder: (context, state) => const RequestSuccessScreen(),
    ),
    GoRoute(
      path: '/ride-tracking',
      name: 'ride-tracking',
      builder: (context, state) => ActiveRideTrackingScreen(rideData: state.extra as Map<String, dynamic>?),
    ),

    // Cancel Flow
    GoRoute(
      path: '/cancel-ride',
      name: 'cancel-ride',
      builder: (context, state) => const CancelRideScreen(),
    ),
    GoRoute(
      path: '/cancel-confirmation',
      name: 'cancel-confirmation',
      builder: (context, state) => const CancelConfirmationScreen(),
    ),
    GoRoute(
      path: '/rating',
      name: 'rating',
      builder: (context, state) => const RatingScreen(),
    ),

    // Wallet Flow
    GoRoute(
      path: '/wallet',
      name: 'wallet',
      builder: (context, state) => const WalletScreen(),
    ),

    // History Flow
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const RideHistoryScreen(),
    ),

    // Profile Flow
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Notifications Flow
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Payment Flow
    GoRoute(
      path: '/select-payment',
      name: 'select-payment',
      builder: (context, state) => const SelectPaymentScreen(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/payment-success',
      name: 'payment-success',
      builder: (context, state) => PaymentSuccessScreen(
        paymentMethod: state.extra as String? ?? 'M-Pesa',
      ),
    ),
    GoRoute(
      path: '/thank-you',
      name: 'thank-you',
      builder: (context, state) => const ThankYouScreen(),
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
