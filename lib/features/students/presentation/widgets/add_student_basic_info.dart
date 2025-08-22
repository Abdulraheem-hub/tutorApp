/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Basic information form for add student step 1
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AddStudentBasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> studentData;
  final Function(String, dynamic) onDataChanged;

  const AddStudentBasicInfo({
    super.key,
    required this.formKey,
    required this.studentData,
    required this.onDataChanged,
  });

  @override
  State<AddStudentBasicInfo> createState() => _AddStudentBasicInfoState();
}

class _AddStudentBasicInfoState extends State<AddStudentBasicInfo> {
  final TextEditingController _nameEnglishController = TextEditingController();
  final TextEditingController _nameUrduController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _admissionNumberController = TextEditingController();
  final TextEditingController _admissionDateController = TextEditingController();

  DateTime? _selectedAdmissionDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _nameEnglishController.text = widget.studentData['nameEnglish'] ?? '';
    _nameUrduController.text = widget.studentData['nameUrdu'] ?? '';
    _addressController.text = widget.studentData['address'] ?? '';
    _admissionNumberController.text = widget.studentData['admissionNumber'] ?? '';
    _admissionDateController.text = widget.studentData['admissionDate'] ?? '';
    
    if (widget.studentData['admissionDateObj'] != null) {
      _selectedAdmissionDate = widget.studentData['admissionDateObj'];
    }
  }

  @override
  void dispose() {
    _nameEnglishController.dispose();
    _nameUrduController.dispose();
    _addressController.dispose();
    _admissionNumberController.dispose();
    _admissionDateController.dispose();
    super.dispose();
  }

  Future<void> _selectAdmissionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAdmissionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedAdmissionDate) {
      setState(() {
        _selectedAdmissionDate = picked;
        _admissionDateController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
      widget.onDataChanged('admissionDate', _admissionDateController.text);
      widget.onDataChanged('admissionDateObj', picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the student\'s basic details',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            
            // Name (English)
            _buildFormField(
              label: 'Name (English)',
              controller: _nameEnglishController,
              hintText: 'Enter full name in English',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name in English';
                }
                return null;
              },
              onChanged: (value) => widget.onDataChanged('nameEnglish', value),
            ),
            
            const SizedBox(height: 24),
            
            // Name (Urdu)
            _buildFormField(
              label: 'Name (Urdu)',
              controller: _nameUrduController,
              hintText: 'اردو میں نام داخل کریں',
              onChanged: (value) => widget.onDataChanged('nameUrdu', value),
            ),
            
            const SizedBox(height: 24),
            
            // Address
            _buildFormField(
              label: 'Address',
              controller: _addressController,
              hintText: 'Enter complete address',
              maxLines: 4,
              onChanged: (value) => widget.onDataChanged('address', value),
            ),
            
            const SizedBox(height: 24),
            
            // Admission Number
            _buildFormField(
              label: 'Admission Number',
              controller: _admissionNumberController,
              hintText: 'Enter admission number',
              onChanged: (value) => widget.onDataChanged('admissionNumber', value),
            ),
            
            const SizedBox(height: 24),
            
            // Admission Date
            _buildDateField(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admission Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _admissionDateController,
          readOnly: true,
          onTap: _selectAdmissionDate,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'mm/dd/yyyy',
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: AppTheme.textLight,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryPurple,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}