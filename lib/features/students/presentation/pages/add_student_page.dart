/**
 * @context7:feature:students
 * @context7:dependencies:flutter,student_entities
 * @context7:pattern:page_widget
 * 
 * Add student page with 3-step form process
 */

import 'package:flutter/material.dart';
import '../widgets/add_student_basic_info.dart';
import '../widgets/add_student_academic_info.dart';
import '../widgets/add_student_contact_info.dart';
import '../../../../core/theme/app_theme.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form data storage
  final Map<String, dynamic> _studentData = {};

  // Form keys for validation
  final GlobalKey<FormState> _basicFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _academicFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();

  final List<String> _stepTitles = [
    'Basic Information',
    'Academic Details',
    'Contact Information',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      // Validate current step before proceeding
      bool isValid = false;
      switch (_currentStep) {
        case 0:
          isValid = _basicFormKey.currentState?.validate() ?? false;
          break;
        case 1:
          isValid = _academicFormKey.currentState?.validate() ?? false;
          break;
        case 2:
          isValid = _contactFormKey.currentState?.validate() ?? false;
          break;
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Final step - save student
      _saveStudent();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveStudent() {
    if (_contactFormKey.currentState?.validate() ?? false) {
      // TODO: Implement actual save logic with BLoC or repository
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _updateStudentData(String key, dynamic value) {
    setState(() {
      _studentData[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AddStudentBasicInfo(
                  formKey: _basicFormKey,
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),
                AddStudentAcademicInfo(
                  formKey: _academicFormKey,
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),
                AddStudentContactInfo(
                  formKey: _contactFormKey,
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Add Student',
        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.textDark),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 3',
                style: const TextStyle(fontSize: 16, color: AppTheme.textLight),
              ),
              Text(
                _stepTitles[_currentStep],
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppTheme.primaryPurple
                        : AppTheme.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentStep == 2 ? 'Save Student' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (_currentStep > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _previousStep,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
