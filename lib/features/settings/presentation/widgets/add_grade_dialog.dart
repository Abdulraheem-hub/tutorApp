/// @context7:feature:app_configuration
/// @context7:pattern:dialog_widget
/// @context7:dependencies:flutter/material.dart
/// 
/// Dialog for adding or editing grades in the app configuration
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/app_configuration_page.dart';

class AddGradeDialog extends StatefulWidget {
  final ConfigurableGrade? grade; // null for add, non-null for edit
  final Function(ConfigurableGrade) onGradeAdded;

  const AddGradeDialog({super.key, this.grade, required this.onGradeAdded});

  @override
  State<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends State<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _nameController.text = widget.grade!.name;
      _shortNameController.text = widget.grade!.shortName;
      _isActive = widget.grade!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.grade != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Grade' : 'Add Grade',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grade Name Field
              _buildFormField(
                label: 'Grade Name',
                controller: _nameController,
                hintText: 'e.g., Grade 1, Kindergarten',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter grade name';
                  }
                  if (value.trim().length < 2) {
                    return 'Grade name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Short Name Field
              _buildFormField(
                label: 'Short Name',
                controller: _shortNameController,
                hintText: 'e.g., G1, KG',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter short name';
                  }
                  if (value.trim().length > 5) {
                    return 'Short name must be 5 characters or less';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Active Status
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'Grade is available for new students'
                        : 'Grade is hidden from selection',
                    style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                  ),
                  value: _isActive,
                  activeColor: AppTheme.primaryPurple,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Helper text
              Text(
                'Short name is used in compact displays and student cards',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveGrade,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
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
          style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight.withValues(alpha: 0.7),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
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

  void _saveGrade() {
    if (_formKey.currentState?.validate() == true) {
      final name = _nameController.text.trim();
      final shortName = _shortNameController.text.trim();

      final grade = ConfigurableGrade(
        id:
            widget.grade?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        shortName: shortName,
        isActive: _isActive,
      );

      widget.onGradeAdded(grade);
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Grade ${widget.grade != null ? 'updated' : 'added'} successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
