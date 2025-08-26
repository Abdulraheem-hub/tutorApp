import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_pay/features/payments/domain/entities/payment_entity.dart';
import 'package:tutor_pay/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:tutor_pay/features/students/domain/entities/student_entity.dart';

void main() {
  group('Payment Flow Tests', () {
    late StudentEntity testStudent;
    late ProcessPaymentUseCase processPaymentUseCase;

    setUp(() {
      processPaymentUseCase = ProcessPaymentUseCase();
      testStudent = StudentEntity(
        id: 'student_1',
        name: 'John Doe',
        subject: 'Mathematics',
        monthlyFee: 120.0,
        createdAt: DateTime(2024, 1, 1),
        outstandingBalance: 0.0,
        currentMonthPaid: false,
      );
    });

    group('Partial Payment Tests', () {
      testWidgets('Test Case 1: Partial Payment (Less than Monthly Fee)', (
        WidgetTester tester,
      ) async {
        // Arrange
        const paymentAmount = 110.0;
        const expectedOutstanding = 10.0; // 120 - 110

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
          description: 'Monthly Fee Payment',
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.isPartialPayment, true);
        expect(result.payment.shortfallAmount, expectedOutstanding);
        expect(result.updatedStudent.outstandingBalance, expectedOutstanding);
        expect(
          result.updatedStudent.currentMonthPaid,
          true,
        ); // Current month is paid even if partial
        expect(result.isCurrentMonthPaid, true);

        print('✓ Test Case 1 Passed: Partial payment properly handled');
      });

      testWidgets('Test Case 2: Exact Payment', (WidgetTester tester) async {
        // Arrange
        const paymentAmount = 120.0;

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.isPartialPayment, false);
        expect(result.payment.shortfallAmount, 0.0);
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);
        expect(result.isCurrentMonthPaid, true);

        print('✓ Test Case 2 Passed: Exact payment properly handled');
      });

      testWidgets('Test Case 3: Overpayment', (WidgetTester tester) async {
        // Arrange
        const paymentAmount = 150.0;
        const expectedExcess = 30.0; // 150 - 120

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.isPartialPayment, false);
        expect(result.payment.excessAmount, expectedExcess);
        expect(result.payment.shortfallAmount, 0.0);
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);
        expect(result.isCurrentMonthPaid, true);

        print('✓ Test Case 3 Passed: Overpayment properly handled');
      });

      testWidgets('Test Case 4: Partial Payment with Existing Due Amount', (
        WidgetTester tester,
      ) async {
        // Arrange
        final studentWithDue = testStudent.copyWith(outstandingBalance: 10.0);
        const paymentAmount = 110.0;
        const expectedOutstanding = 20.0; // 130 - 110

        // Act
        final result = processPaymentUseCase.processPayment(
          student: studentWithDue,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.creditCard,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.outstandingBalanceBefore, 10.0);
        expect(result.payment.outstandingBalanceAfter, expectedOutstanding);
        expect(result.updatedStudent.outstandingBalance, expectedOutstanding);
        expect(result.payment.isPartialPayment, true);

        print(
          '✓ Test Case 4 Passed: Partial payment with existing due amount properly handled',
        );
      });

      testWidgets('Test Case 5: Payment Covering Previous Due Amount', (
        WidgetTester tester,
      ) async {
        // Arrange
        final studentWithDue = testStudent.copyWith(outstandingBalance: 10.0);
        const paymentAmount = 130.0; // Covers 10 due + 120 monthly fee

        // Act
        final result = processPaymentUseCase.processPayment(
          student: studentWithDue,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.paypal,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.outstandingBalanceBefore, 10.0);
        expect(result.payment.outstandingBalanceAfter, 0.0);
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);
        expect(result.payment.isPartialPayment, false);
        expect(result.amountForOutstanding, 10.0);
        expect(result.amountForMonthlyFee, 120.0);

        print(
          '✓ Test Case 5 Passed: Payment covering previous due amount properly handled',
        );
      });

      testWidgets('Test Case 6: Large Outstanding Balance with Partial Payment', (
        WidgetTester tester,
      ) async {
        // Arrange
        final studentWithLargeDue = testStudent.copyWith(
          outstandingBalance: 200.0,
        );
        const paymentAmount = 100.0;

        // Act
        final result = processPaymentUseCase.processPayment(
          student: studentWithLargeDue,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.outstandingBalanceBefore, 200.0);
        expect(
          result.updatedStudent.outstandingBalance,
          220.0,
        ); // 200 - 100 + 120 (new shortfall)
        expect(result.payment.isPartialPayment, true);
        expect(
          result.updatedStudent.currentMonthPaid,
          false,
        ); // Monthly fee not covered
        expect(result.amountForOutstanding, 100.0);
        expect(result.amountForMonthlyFee, 0.0);

        print(
          '✓ Test Case 6 Passed: Large outstanding balance with partial payment properly handled',
        );
      });

      testWidgets('Test Case 7: Multiple Month Due Calculation', (
        WidgetTester tester,
      ) async {
        // Arrange
        final studentWithMultiMonthDue = testStudent.copyWith(
          outstandingBalance: 240.0,
        ); // 2 months
        const paymentAmount =
            300.0; // Should cover 2 months due + current month

        // Act
        final result = processPaymentUseCase.processPayment(
          student: studentWithMultiMonthDue,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.outstandingBalanceBefore, 240.0);
        expect(result.updatedStudent.outstandingBalance, 60.0); // 360 - 300
        expect(result.payment.isPartialPayment, true);
        expect(result.amountForOutstanding, 240.0);
        expect(
          result.amountForMonthlyFee,
          60.0,
        ); // Partial monthly fee coverage

        print(
          '✓ Test Case 7 Passed: Multiple month due calculation properly handled',
        );
      });

      testWidgets('Test Case 8: Zero Payment (Edge Case)', (
        WidgetTester tester,
      ) async {
        // Arrange
        const paymentAmount = 0.0;

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.cash,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.amount, paymentAmount);
        expect(result.payment.isPartialPayment, true);
        expect(
          result.payment.shortfallAmount,
          120.0,
        ); // Full monthly fee is shortfall
        expect(result.updatedStudent.outstandingBalance, 120.0);
        expect(result.updatedStudent.currentMonthPaid, false);

        print('✓ Test Case 8 Passed: Zero payment edge case properly handled');
      });
    });

    group('Payment Entity Tests', () {
      testWidgets('Payment Entity Creation and Properties', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        final payment = PaymentEntity(
          id: 'payment_1',
          studentId: 'student_1',
          studentName: 'John Doe',
          amount: 110.0,
          method: PaymentMethod.cash,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          monthlyFeeAtPayment: 120.0,
          paymentPeriod: DateTime(2024, 1, 1),
          shortfallAmount: 10.0,
          isPartialPayment: true,
        );

        // Assert
        expect(payment.formattedAmount, '\$110.00');
        expect(payment.formattedShortfallAmount, '\$10.00');
        expect(payment.coversFullMonthlyFee, false);
        expect(payment.paymentCoverageSummary, 'Partial payment: \$10.00 due');
        expect(payment.isPartialPayment, true);

        print('✓ Payment Entity Tests Passed');
      });
    });

    group('Student Entity Tests', () {
      testWidgets('Student Entity Payment Flow Properties', (
        WidgetTester tester,
      ) async {
        // Arrange
        final student = testStudent.copyWith(
          outstandingBalance: 50.0,
          currentMonthPaid: true,
        );

        // Assert
        expect(student.hasOutstandingBalance, true);
        expect(student.totalAmountDue, 170.0); // 120 + 50
        expect(student.formattedOutstandingBalance, '\$50.00');
        expect(student.formattedTotalAmountDue, '\$170.00');
        expect(student.calculatedPaymentStatus, 'Paid (Due Balance)');

        print('✓ Student Entity Payment Flow Tests Passed');
      });
    });

    group('Business Logic Edge Cases', () {
      testWidgets('Very Large Payment Amount', (WidgetTester tester) async {
        // Arrange
        const paymentAmount = 10000.0;

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: paymentAmount,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );

        // Assert
        expect(result.payment.excessAmount, 9880.0); // 10000 - 120
        expect(result.updatedStudent.outstandingBalance, 0.0);
        expect(result.updatedStudent.currentMonthPaid, true);

        print('✓ Very Large Payment Test Passed');
      });

      testWidgets('Payment Period Tracking', (WidgetTester tester) async {
        // Arrange
        final paymentDate = DateTime(2024, 3, 15);

        // Act
        final result = processPaymentUseCase.processPayment(
          student: testStudent,
          paymentAmount: 120.0,
          paymentMethod: PaymentMethod.cash,
          paymentDate: paymentDate,
        );

        // Assert
        expect(result.payment.paymentPeriod.year, 2024);
        expect(result.payment.paymentPeriod.month, 3);
        expect(result.payment.paymentPeriod.day, 1);
        expect(
          result.updatedStudent.paymentPeriod,
          result.payment.paymentPeriod,
        );

        print('✓ Payment Period Tracking Test Passed');
      });
    });
  });
}
