/**
 * @context7:feature:payment_settings
 * @context7:pattern:widget_test
 * 
 * Tests for payment options page functionality
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/settings/presentation/pages/payment_settings_page.dart';
import 'package:tutor_pay/core/theme/app_theme.dart';

void main() {
  group('PaymentSettingsPage Tests', () {
    testWidgets('should display payment options page correctly', (
      WidgetTester tester,
    ) async {
      // Build the payment settings page
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PaymentSettingsPage(),
        ),
      );

      // Verify that the page title is displayed
      expect(find.text('Payment Options'), findsOneWidget);

      // Verify that the manage payment options text is displayed
      expect(
        find.text(
          'Manage payment method options for recording student fee payments',
        ),
        findsOneWidget,
      );

      // Verify that the add payment option button is displayed
      expect(find.text('Add Payment Option'), findsOneWidget);
    });

    testWidgets('should display default payment options', (
      WidgetTester tester,
    ) async {
      // Build the payment settings page
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PaymentSettingsPage(),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pumpAndSettle();

      // Verify that default payment options are displayed
      expect(find.text('UPI Payment'), findsOneWidget);
      expect(find.text('Cash Payment'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('Card Payment'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets(
      'should open add payment option sheet when add button is tapped',
      (WidgetTester tester) async {
        // Build the payment settings page
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentSettingsPage(),
          ),
        );

        // Wait for the widget to be fully built
        await tester.pumpAndSettle();

        // Tap the add payment option button
        await tester.tap(find.text('Add Payment Option'));
        await tester.pumpAndSettle();

        // Verify that the add payment option sheet is displayed
        expect(find.text('Add Payment Option'), findsAtLeastNWidgets(1));
        expect(find.text('Payment Option Type'), findsOneWidget);
        expect(find.text('UPI Payment'), findsOneWidget);
        expect(find.text('Cash Payment'), findsOneWidget);
      },
    );

    testWidgets('should show payment option actions when card is tapped', (
      WidgetTester tester,
    ) async {
      // Build the payment settings page
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PaymentSettingsPage(),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pumpAndSettle();

      // Tap on a payment method card
      await tester.tap(find.text('UPI Payment'));
      await tester.pumpAndSettle();

      // Verify that the options sheet is displayed
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      // Build the payment settings page
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PaymentSettingsPage(),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pumpAndSettle();

      // Tap on a payment method card (non-default one)
      await tester.tap(find.text('Cash Payment'));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify that the delete confirmation dialog is displayed
      expect(find.text('Delete Payment Option'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete Cash Payment?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('PaymentMethod Model Tests', () {
    test('should create payment method correctly', () {
      final paymentMethod = PaymentMethod(
        id: '1',
        type: PaymentMethodType.upi,
        title: 'UPI Payment',
        subtitle: 'Google Pay, PhonePe, etc.',
        isDefault: true,
      );

      expect(paymentMethod.id, '1');
      expect(paymentMethod.type, PaymentMethodType.upi);
      expect(paymentMethod.title, 'UPI Payment');
      expect(paymentMethod.subtitle, 'Google Pay, PhonePe, etc.');
      expect(paymentMethod.isDefault, true);
    });

    test('should support all payment method types', () {
      expect(PaymentMethodType.values.length, 5);
      expect(PaymentMethodType.values.contains(PaymentMethodType.upi), true);
      expect(PaymentMethodType.values.contains(PaymentMethodType.cash), true);
      expect(
        PaymentMethodType.values.contains(PaymentMethodType.creditCard),
        true,
      );
      expect(
        PaymentMethodType.values.contains(PaymentMethodType.debitCard),
        true,
      );
      expect(
        PaymentMethodType.values.contains(PaymentMethodType.bankTransfer),
        true,
      );
    });
  });
}
