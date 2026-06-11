import 'package:flutter_test/flutter_test.dart';

import 'package:climate_app/main.dart';

void main() {
  testWidgets('HomeScreen shows climate info', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Clima Actual'), findsOneWidget);
    expect(find.text('24°C'), findsOneWidget);
    expect(find.text('Santiago de Querétaro'), findsOneWidget);
    expect(find.text('Buscar Ciudades'), findsOneWidget);
  });
}
