// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bodaboda_driver/main.dart';
import 'package:bodaboda_driver/core/routing/app_router.dart';

void main() {
  testWidgets('Driver app starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BodabodaDriverApp()),
    );
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Fuel Wallet'), findsOneWidget);
  });
}
