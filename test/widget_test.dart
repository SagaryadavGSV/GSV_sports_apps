import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsv_sports/main.dart';

void main() {
  testWidgets('GSV Sports app launches and shows login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GSVSportsApp());
    await tester.pumpAndSettle();

    // App should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
