/// @context7:feature:tests
/// @context7:dependencies:payment_processing,student_entity
/// @context7:pattern:integration_test
///
/// Integration test to verify payment flow works end-to-end
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/payments/domain/entities/payment_entity.dart';
import 'package:tutor_pay/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entity.dart';

void main() {
  group('Payment Integration Tests', () {
    late ProcessPaymentUseCase processPaymentUseCase;
    late StudentEntity testStudent;

    setUp(() {
      processPaymentUseCase = ProcessPaymentUseCase();
      testStudent = StudentEntity(
        id: 'test_student_1',
        name: 'Integration Test Student',
        subject: 'Mathematics',
        monthlyFee: 150.0,
        createdAt: DateTime(2024, 1, 1),
        outstandingBalance: 50.0, // Has some outstanding balance
        currentMonthPaid: false,
      );
    });

    group('Comprehensive Payment Scenarios', () {
      test('Scenario 1: Partial Payment with Outstanding Balance', () {
        // Student owes $50 + $150 (monthly) = $200 total
        // Pays $100 - should go to outstanding first, then partial monthly
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 100.0,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
          description: 'Partial Payment Test',
        );

        // Verify payment details
        expect(result.payment.amount, 100.0);
        expect(result.payment.isPartialPayment, true);
        expect(result.payment.outstandingBalanceBefore, 50.0);
        expect(result.payment.outstandingBalanceAfter, 100.0); // 50 + 150 - 100
        expect(result.payment.shortfallAmount, 100.0); // Monthly fee not fully covered
        expect(result.payment.excessAmount, 0.0);
        
        // Verify student update
        expect(result.updatedStudent.outstandingBalance, 100.0);
        expect(result.updatedStudent.currentMonthPaid, false);
        
        print('✅ Partial Payment with Outstanding Balance Test Passed');
      });

      test('Scenario 2: Overpayment Clears Everything Plus Credit', () {
        // Student owes $50 + $150 = $200 total
        // Pays $250 - should clear everything with $50 credit
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 250.0,
          paymentMethod: PaymentMethod.creditCard,
          paymentDate: DateTime.now(),
          description: 'Overpayment Test',
        );

        // Verify payment details
        expect(result.payment.amount, 250.0);
        expect(result.payment.isPartialPayment, false);
        expect(result.payment.outstandingBalanceBefore, 50.0);
        expect(result.payment.outstandingBalanceAfter, 0.0);
        expect(result.payment.shortfallAmount, 0.0);
        expect(result.payment.excessAmount, 50.0); // 250 - 200
        
        // Verify student update
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);
        
        print('✅ Overpayment Test Passed');
      });

      test('Scenario 3: Exact Payment Clears Outstanding Plus Monthly', () {
        // Student owes $50 + $150 = $200 total
        // Pays exactly $200
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 200.0,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
          description: 'Exact Payment Test',
        );

        // Verify payment details
        expect(result.payment.amount, 200.0);
        expect(result.payment.isPartialPayment, false);
        expect(result.payment.outstandingBalanceBefore, 50.0);
        expect(result.payment.outstandingBalanceAfter, 0.0);
        expect(result.payment.shortfallAmount, 0.0);
        expect(result.payment.excessAmount, 0.0);
        
        // Verify student update
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);
        
        print('✅ Exact Payment Test Passed');
      });

      test('Scenario 4: Student with No Outstanding - Partial Monthly Payment', () {
        // New student with no outstanding balance
        final newStudent = testStudent.copyWith(outstandingBalance: 0.0);
        
        // Pays $75 of $150 monthly fee
        final result = processPaymentUseCase.processPayment(
          student: newStudent,
          paymentAmount: 75.0,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
          description: 'Partial Monthly Fee Test',
        );

        // Verify payment details
        expect(result.payment.amount, 75.0);
        expect(result.payment.isPartialPayment, true);
        expect(result.payment.outstandingBalanceBefore, 0.0);
        expect(result.payment.outstandingBalanceAfter, 75.0); // Shortfall becomes outstanding
        expect(result.payment.shortfallAmount, 75.0);
        expect(result.payment.excessAmount, 0.0);
        
        // According to business logic, current month is paid even if partial
        expect(result.updatedStudent.currentMonthPaid, true);
        expect(result.updatedStudent.outstandingBalance, 75.0);
        
        print('✅ Partial Monthly Fee Test Passed');
      });
    });

    group('Payment Card Information Display Tests', () {
      test('Payment Entity Contains All Required Information', () {
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 100.0,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime(2024, 8, 15),
          description: 'Test Payment',
          notes: 'Integration test payment',
        );

        final payment = result.payment;

        // Verify all essential fields are populated
        expect(payment.id, isNotEmpty);
        expect(payment.studentId, testStudent.id);
        expect(payment.studentName, testStudent.name);
        expect(payment.amount, 100.0);
        expect(payment.method, PaymentMethod.cash);
        expect(payment.description, 'Test Payment');
        expect(payment.notes, 'Integration test payment');
        expect(payment.monthlyFeeAtPayment, testStudent.monthlyFee);
        expect(payment.paymentPeriod.year, 2024);
        expect(payment.paymentPeriod.month, 8);
        expect(payment.outstandingBalanceBefore, isNotNull);
        expect(payment.outstandingBalanceAfter, isNotNull);

        // Verify display helper methods work
        expect(payment.formattedAmount, '\$100.00');
        expect(payment.methodDisplayName, 'Cash');
        expect(payment.statusDisplayName, 'Pending');
        expect(payment.paymentCoverageSummary, contains('Partial payment'));

        print('✅ Payment Entity Information Test Passed');
      });
    });

    group('Business Logic Validation', () {
      test('Payment Processing Maintains Data Consistency', () {
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 180.0, // More than monthly, less than total due
          paymentMethod: PaymentMethod.creditCard,
          paymentDate: DateTime.now(),
        );

        // Check math consistency
        final totalDue = testStudent.outstandingBalance + testStudent.monthlyFee;
        final expectedRemaining = totalDue - 180.0;
        
        expect(result.payment.outstandingBalanceAfter, expectedRemaining);
        expect(result.updatedStudent.outstandingBalance, expectedRemaining);
        
        // Check amount allocation logic
        expect(result.amountForOutstanding, testStudent.outstandingBalance);
        expect(result.amountForMonthlyFee, 180.0 - testStudent.outstandingBalance);
        
        print('✅ Data Consistency Test Passed');
      });
    });

    tearDown(() {
      // Clean up if needed
    });
  });
}