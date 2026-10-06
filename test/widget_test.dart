import 'package:cura/screen/oracle/oracle_page.dart';
import 'package:cura/widget/home_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home gradient paints without overflow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SubtleHomeGradient())),
    );

    expect(find.byType(SubtleHomeGradient), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('oracle page shows its coming-soon copy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OraclePage()));

    expect(find.text('Oracle'), findsOneWidget);
    expect(find.textContaining('deeper guidance'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });
}
