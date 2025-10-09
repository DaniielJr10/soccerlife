// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soccerlife/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that we're showing the login screen by looking for common login elements
    // We'll look for text that should appear on the login screen
    expect(find.text('Soccer Life'), findsOneWidget);
    
    // Look for email input field
    expect(find.byType(TextFormField), findsWidgets);
    
    // Verify subtitle text
    expect(find.text('Tu Evolución Futbolística'), findsOneWidget);
  });
}
