// Settings page widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('Settings page displays correctly', (WidgetTester tester) async {
    // Build the settings page and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsPage(),
      ),
    );

    // Verify that the settings page contains expected elements
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Mathematics Tutor'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.text('Payment Settings'), findsOneWidget);
    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('Receipt Generation'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('About TutorPay'), findsOneWidget);
    expect(find.text('Version 2.1.0'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Settings page navigation works', (WidgetTester tester) async {
    // Build the settings page with a navigator
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Center(child: Text('Dashboard')),
        ),
        routes: {
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );

    // Navigate to settings
    await tester.tap(find.text('Dashboard'));
    await tester.pump();

    // Navigate to settings page
    Navigator.of(tester.element(find.text('Dashboard'))).pushNamed('/settings');
    await tester.pumpAndSettle();

    // Verify we're on the settings page
    expect(find.text('Settings'), findsOneWidget);
  });
}