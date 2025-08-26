/// @context7:feature:app
/// @context7:dependencies:flutter_bloc,dashboard_bloc
/// @context7:pattern:main_app_widget
///
/// Main app widget with bottom navigation and dashboard
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/students/presentation/pages/students_page.dart';
import 'features/students/presentation/pages/student_detail_page.dart';
import 'features/students/presentation/pages/add_student_page.dart';
import 'features/students/presentation/pages/add_payment_page.dart';
import 'features/students/presentation/pages/payments_list_page.dart';
import 'features/students/presentation/pages/payment_confirmation_page.dart';
import 'features/payments/presentation/pages/payment_card_demo_page.dart';
import 'features/students/presentation/bloc/students_bloc.dart';
import 'features/students/domain/entities/student_entities.dart';
import 'features/developer_tools/presentation/pages/developer_tools_page.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';

class TutorPayApp extends StatelessWidget {
  const TutorPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider(
          create: (context) => DashboardBloc(),
          child: const MainScreen(),
        ),
        AppRoutes.students: (context) => BlocProvider(
          create: (context) => serviceLocator<StudentsBloc>(),
          child: const StudentsPage(),
        ),
        AppRoutes.studentDetail: (context) => const StudentDetailPage(),
        AppRoutes.addStudent: (context) => BlocProvider(
          create: (context) => serviceLocator<StudentsBloc>(),
          child: const AddStudentPage(),
        ),
        AppRoutes.addPayment: (context) => const AddPaymentPage(),
        AppRoutes.payments: (context) => const PaymentsListPage(),
        AppRoutes.paymentConfirmation: (context) =>
            const PaymentConfirmationPage(),
        AppRoutes.paymentCardDemo: (context) => const PaymentCardDemoPage(),
        AppRoutes.developerTools: (context) => const DeveloperToolsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.studentDetail) {
          final student = settings.arguments as Student;
          return MaterialPageRoute(
            builder: (context) => StudentDetailPage(student: student),
          );
        }
        if (settings.name == AppRoutes.addPayment) {
          final student = settings.arguments as Student;
          return MaterialPageRoute(
            builder: (context) => AddPaymentPage(student: student),
          );
        }
        if (settings.name == AppRoutes.paymentConfirmation) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PaymentConfirmationPage(
              payment: args['payment'] as Payment,
              student: args['student'] as Student,
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const PaymentsListPage(),
    BlocProvider(
      create: (context) => serviceLocator<StudentsBloc>(),
      child: const StudentsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Students',
          ),
        ],
      ),
    );
  }
}
