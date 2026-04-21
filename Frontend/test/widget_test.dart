// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lube/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({'is_local_mode': true});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const LubeApp());

    // Initial frame should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Give it time to run the async check and navigate
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Check if we reached the Dashboard (the AppBar title is "LUBE APP")
    expect(find.text('LUBE APP'), findsOneWidget);
  });
}
