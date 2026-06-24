// Basic smoke test for Saathi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saathi/common/widgets/app_logo.dart';

void main() {
  testWidgets('App logo renders wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: AppLogo(size: 80, showWordmark: true))),
    ));
    expect(find.text('Saathi'), findsOneWidget);
  });
}
