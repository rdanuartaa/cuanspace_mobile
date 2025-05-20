// widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cuan_space/main.dart';

void main() {
  testWidgets('Welcome page displays correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the Welcome page title is displayed.
    expect(find.text('Selamat Datang di Cuan Space'), findsOneWidget);

    // Verify that the Next button is present.
    expect(find.text('Next'), findsOneWidget);

    // Tap the Next button and trigger a frame.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify that the next page title is displayed.
    expect(find.text('Temukan Aset Digital Terbaik'), findsOneWidget);
  });
}