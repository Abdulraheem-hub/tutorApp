import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/students/presentation/pages/payment_confirmation_page.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entities.dart';

void main() {
  group('PaymentConfirmationPage Tests', () {
    late Student testStudent;
    late Payment testPayment;

    setUp(() {
      testStudent = Student(
        id: '1',
        name: 'John Doe',
        grade: Grade.grade10,
        subjects: const [
          Subject(id: '1', name: 'Mathematics'),
          Subject(id: '2', name: 'Physics'),
        ],
        monthlyFee: 100.0,
        paymentStatus: PaymentStatus.paid,
        joinDate: DateTime(2024, 1, 15),
        admissionNumber: 'STD001',
      );

      testPayment = Payment(
        id: '1',
        studentId: '1',
        amount: 100.0,
        paymentDate: DateTime.now(),
        method: PaymentMethod.cash,
        description: 'Monthly Fee',
        type: PaymentType.monthlyFee,
      );
    });

    testWidgets('should display payment confirmation page header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentConfirmationPage(
            payment: testPayment,
            student: testStudent,
          ),
        ),
      );

      // Wait for initial render
      await tester.pump();

      // Verify page header
      expect(find.text('Payment Confirmation'), findsOneWidget);
    });

    testWidgets('should create payment confirmation page without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentConfirmationPage(
            payment: testPayment,
            student: testStudent,
          ),
        ),
      );

      // Just verify the page renders without errors
      expect(find.byType(PaymentConfirmationPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
