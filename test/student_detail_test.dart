import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/features/students/domain/entities/student_entities.dart';
import '../lib/features/students/presentation/pages/student_detail_page.dart';
import '../lib/features/students/presentation/widgets/student_card.dart';
import '../lib/core/theme/app_theme.dart';

void main() {
  group('Student Detail Page Tests', () {
    late Student testStudent;

    setUp(() {
      testStudent = Student(
        id: '1',
        name: 'Ahmed Hassan',
        grade: Grade.grade8,
        subjects: const [Subject(id: '1', name: 'Mathematics', shortName: 'Math')],
        monthlyFee: 80.0,
        paymentStatus: PaymentStatus.paid,
        nextPaymentDate: DateTime(2024, 1, 15),
        joinDate: DateTime(2023, 9, 1),
        admissionNumber: '#204001',
        admissionDate: DateTime(2024, 1, 15),
        address: 'House 123, Street 5, Gulshan-e-Iqbal, Karachi',
        phoneNumber: '+92 300 1234567',
        email: 'ahmed.hassan@email.com',
      );
    });

    testWidgets('StudentDetailPage displays student information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StudentDetailPage(student: testStudent),
        ),
      );

      // Verify the student name is displayed
      expect(find.text('Ahmed Hassan'), findsOneWidget);
      
      // Verify admission number is displayed
      expect(find.textContaining('#204001'), findsOneWidget);
      
      // Verify the tabs are present
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Academic'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);
      
      // Verify payment summary section
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('Add Payment'), findsOneWidget);
      expect(find.text('View Payments'), findsOneWidget);
    });

    testWidgets('StudentCard has tap functionality', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StudentCard(
              student: testStudent,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the student card
      await tester.tap(find.byType(StudentCard));
      
      expect(tapped, isTrue);
    });

    test('Payment entities are created correctly', () {
      final payment = Payment(
        id: '1',
        studentId: '1',
        amount: 5000.0,
        paymentDate: DateTime(2024, 1, 15),
        method: PaymentMethod.cash,
        description: 'January Fee',
        type: PaymentType.monthlyFee,
      );

      expect(payment.amount, 5000.0);
      expect(payment.method, PaymentMethod.cash);
      expect(payment.type, PaymentType.monthlyFee);
      expect(payment.description, 'January Fee');
    });

    test('Student entity includes new fields', () {
      expect(testStudent.admissionNumber, '#204001');
      expect(testStudent.address, 'House 123, Street 5, Gulshan-e-Iqbal, Karachi');
      expect(testStudent.phoneNumber, '+92 300 1234567');
      expect(testStudent.email, 'ahmed.hassan@email.com');
    });
  });
}