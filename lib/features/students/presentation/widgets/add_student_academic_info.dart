/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Academic information form for add student step 2
 */

import 'package:flutter/material.dart';
import '../../domain/entities/student_entities.dart';
import '../../../../core/theme/app_theme.dart';

class AddStudentAcademicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> studentData;
  final Function(String, dynamic) onDataChanged;

  const AddStudentAcademicInfo({
    super.key,
    required this.formKey,
    required this.studentData,
    required this.onDataChanged,
  });

  @override
  State<AddStudentAcademicInfo> createState() => _AddStudentAcademicInfoState();
}

class _AddStudentAcademicInfoState extends State<AddStudentAcademicInfo> {
  final TextEditingController _monthlyFeeController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();

  Grade? _selectedGrade;
  List<Subject> _selectedSubjects = [];
  DateTime? _selectedJoinDate;
  bool _isActive = true;

  // Available subjects (in a real app, these would come from a repository)
  final List<Subject> _availableSubjects = const [
    Subject(id: '1', name: 'Mathematics', shortName: 'Math'),
    Subject(id: '2', name: 'English', shortName: 'Eng'),
    Subject(id: '3', name: 'Physics', shortName: 'Phy'),
    Subject(id: '4', name: 'Chemistry', shortName: 'Chem'),
    Subject(id: '5', name: 'Biology', shortName: 'Bio'),
    Subject(id: '6', name: 'Computer Science', shortName: 'CS'),
    Subject(id: '7', name: 'Economics', shortName: 'Econ'),
    Subject(id: '8', name: 'Accounting', shortName: 'Acc'),
    Subject(id: '9', name: 'Urdu', shortName: 'Urdu'),
    Subject(id: '10', name: 'Islamiat', shortName: 'Isl'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _monthlyFeeController.text = widget.studentData['monthlyFee']?.toString() ?? '';
    _joinDateController.text = widget.studentData['joinDate'] ?? '';
    _selectedGrade = widget.studentData['grade'];
    _selectedSubjects = widget.studentData['subjects'] ?? [];
    _selectedJoinDate = widget.studentData['joinDateObj'];
    _isActive = widget.studentData['isActive'] ?? true;
  }

  @override
  void dispose() {
    _monthlyFeeController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _selectJoinDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedJoinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null && picked != _selectedJoinDate) {
      setState(() {
        _selectedJoinDate = picked;
        _joinDateController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
      widget.onDataChanged('joinDate', _joinDateController.text);
      widget.onDataChanged('joinDateObj', picked);
    }
  }

  void _showSubjectsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Subjects'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = _availableSubjects[index];
                    final isSelected = _selectedSubjects.any((s) => s.id == subject.id);
                    
                    return CheckboxListTile(
                      title: Text(subject.name),
                      value: isSelected,
                      activeColor: AppTheme.primaryPurple,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.removeWhere((s) => s.id == subject.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {});
                    widget.onDataChanged('subjects', _selectedSubjects);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
              'Academic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the student\'s academic details',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            
            // Grade Selection
            _buildGradeField(),
            
            const SizedBox(height: 24),
            
            // Subjects Selection
            _buildSubjectsField(),
            
            const SizedBox(height: 24),
            
            // Monthly Fee
            _buildFormField(
              label: 'Monthly Fee',
              controller: _monthlyFeeController,
              hintText: 'Enter monthly fee amount',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter monthly fee';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (value) {
                final fee = double.tryParse(value) ?? 0.0;
                widget.onDataChanged('monthlyFee', fee);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Join Date
            _buildDateField(),
            
            const SizedBox(height: 24),
            
            // Status
            _buildStatusField(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grade',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Grade>(
          value: _selectedGrade,
          validator: (value) {
            if (value == null) {
              return 'Please select a grade';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Select grade',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: Grade.values.map((Grade grade) {
            return DropdownMenuItem<Grade>(
              value: grade,
              child: Text(grade.displayName),
            );
          }).toList(),
          onChanged: (Grade? newValue) {
            setState(() {
              _selectedGrade = newValue;
            });
            widget.onDataChanged('grade', newValue);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSubjectsDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedSubjects.isEmpty
                        ? 'Select subjects'
                        : _selectedSubjects.map((s) => s.shortName).join(', '),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedSubjects.isEmpty 
                          ? AppTheme.textLight.withValues(alpha: 0.7)
                          : AppTheme.textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight.withValues(alpha: 0.7),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
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
          'Join Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _joinDateController,
          readOnly: true,
          onTap: _selectJoinDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select join date';
            }
            return null;
          },
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'mm/dd/yyyy',
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight.withValues(alpha: 0.7),
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: AppTheme.textLight,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(
              _isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
              ),
            ),
            value: _isActive,
            activeColor: AppTheme.primaryPurple,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
              widget.onDataChanged('isActive', value);
            },
          ),
        ),
      ],
    );
  }
}
