import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/students/presentation/pages/add_payment_page.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entities.dart';
import 'package:tutor_pay/core/theme/app_theme.dart';

void main() {
  group('AddPaymentPage Tests', () {
    late Student testStudent;

    setUp(() {
      testStudent = Student(
        id: '1',
        name: 'Sarah Johnson',
        grade: Grade.grade10,
        subjects: const [
          Subject(id: '1', name: 'Mathematics'),
          Subject(id: '2', name: 'Physics'),
          Subject(id: '3', name: 'Chemistry'),
        ],
        monthlyFee: 12500.0,
        paymentStatus: PaymentStatus.pending,
        joinDate: DateTime(2024, 1, 15),
        admissionNumber: 'ST2024',
      );
    });

    testWidgets('should display student information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Verify student name is displayed
      expect(find.text('Sarah Johnson'), findsOneWidget);
      
      // Verify grade and student ID are displayed
      expect(find.textContaining('Grade 10'), findsOneWidget);
      expect(find.textContaining('ST2024'), findsOneWidget);
      
      // Verify subjects are displayed
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);
      
      // Verify monthly fee is displayed
      expect(find.textContaining('\$12,500'), findsOneWidget);
    });

    testWidgets('should display payment form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Verify payment amount field exists
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
      
      // Verify payment date section exists
      expect(find.text('Payment Date'), findsOneWidget);
      
      // Verify payment method section exists
      expect(find.text('Payment Mode'), findsOneWidget);
      
      // Verify all payment methods are displayed
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Debit Card'), findsOneWidget);
      
      // Verify record payment button exists
      expect(find.text('Record Payment'), findsOneWidget);
    });

    testWidgets('should pre-fill amount with monthly fee', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Find the amount text field
      final amountField = find.byType(TextFormField).first;
      final TextFormField textField = tester.widget(amountField);
      
      // Verify the amount is pre-filled with monthly fee
      expect(textField.controller?.text, '12500');
    });

    testWidgets('should validate empty payment amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Clear the amount field
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '');
      
      // Tap the record payment button
      await tester.tap(find.text('Record Payment'));
      await tester.pump();
      
      // Verify validation error appears
      expect(find.text('Please enter payment amount'), findsOneWidget);
    });

    testWidgets('should validate invalid payment amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Enter invalid amount
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '0');
      
      // Tap the record payment button
      await tester.tap(find.text('Record Payment'));
      await tester.pump();
      
      // Verify validation error appears
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('should allow selecting different payment methods', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Initially Cash should be selected (default)
      // Try selecting UPI
      await tester.tap(find.text('UPI'));
      await tester.pump();
      
      // Try selecting Bank
      await tester.tap(find.text('Bank'));
      await tester.pump();
      
      // Try selecting Debit Card
      await tester.tap(find.text('Debit Card'));
      await tester.pump();
      
      // All taps should work without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AddPaymentPage(student: testStudent),
        ),
      );

      // Verify app bar title
      expect(find.text('Record Payment'), findsOneWidget);
      
      // Verify back button exists
      expect(find.byType(BackButton), findsOneWidget);
      
      // Verify help button exists
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });
  });
}