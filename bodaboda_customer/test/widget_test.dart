import 'package:flutter_test/flutter_test.dart';
import 'package:bodaboda_customer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BodabodaCustomerApp());
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(BodabodaCustomerApp), findsOneWidget);
  });
}
