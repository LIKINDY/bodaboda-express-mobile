import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/settings/app_settings.dart';

import 'core/services/user_profile_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BodabodaCustomerApp(),
    ),
  );
  unawaited(AppSettings.instance.load());
  unawaited(UserProfileService.instance.init());
}

class BodabodaCustomerApp extends StatelessWidget {
  const BodabodaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) => MaterialApp.router(
        title: 'Bodaboda Express',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: AppSettings.instance.themeMode,
        locale: AppSettings.instance.locale,
        supportedLocales: const [Locale('en'), Locale('sw')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}

class CustomerDashboardPlaceholder extends StatelessWidget {
  const CustomerDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bodaboda Express'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.motorcycle, size: 100, color: AppTheme.primaryBlue),
            const SizedBox(height: 20),
            Text(
              'Karibu Bodaboda Express',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text('Customer App Initialized!'),
          ],
        ),
      ),
    );
  }
}
