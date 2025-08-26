/// @context7:feature:app_configuration
/// @context7:pattern:page_widget
/// @context7:dependencies:flutter/material.dart
/// 
/// App configuration page for managing grades and subjects that are used
/// when adding students. This centralized configuration allows tutors to
/// customize available options based on their teaching context.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/domain/entities/student_entities.dart';
import '../widgets/add_subject_dialog.dart';
import '../widgets/add_grade_dialog.dart';

class AppConfigurationPage extends StatefulWidget {
  const AppConfigurationPage({super.key});

  @override
  State<AppConfigurationPage> createState() => _AppConfigurationPageState();
}

class _AppConfigurationPageState extends State<AppConfigurationPage> {
  // Available grades (in a real app, these would come from a repository/database)
  List<ConfigurableGrade> _availableGrades = [
    ConfigurableGrade(
      id: '1',
      name: 'Grade 1',
      shortName: 'G1',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '2',
      name: 'Grade 2',
      shortName: 'G2',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '3',
      name: 'Grade 3',
      shortName: 'G3',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '4',
      name: 'Grade 4',
      shortName: 'G4',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '5',
      name: 'Grade 5',
      shortName: 'G5',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '6',
      name: 'Grade 6',
      shortName: 'G6',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '7',
      name: 'Grade 7',
      shortName: 'G7',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '8',
      name: 'Grade 8',
      shortName: 'G8',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '9',
      name: 'Grade 9',
      shortName: 'G9',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '10',
      name: 'Grade 10',
      shortName: 'G10',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '11',
      name: 'Grade 11',
      shortName: 'G11',
      isActive: true,
    ),
    ConfigurableGrade(
      id: '12',
      name: 'Grade 12',
      shortName: 'G12',
      isActive: true,
    ),
  ];

  // Available subjects (in a real app, these would come from a repository/database)
  List<Subject> _availableSubjects = [
    const Subject(id: '1', name: 'Mathematics', shortName: 'Math'),
    const Subject(id: '2', name: 'English', shortName: 'Eng'),
    const Subject(id: '3', name: 'Physics', shortName: 'Phy'),
    const Subject(id: '4', name: 'Chemistry', shortName: 'Chem'),
    const Subject(id: '5', name: 'Biology', shortName: 'Bio'),
    const Subject(id: '6', name: 'Computer Science', shortName: 'CS'),
    const Subject(id: '7', name: 'Economics', shortName: 'Econ'),
    const Subject(id: '8', name: 'Accounting', shortName: 'Acc'),
    const Subject(id: '9', name: 'Urdu', shortName: 'Urdu'),
    const Subject(id: '10', name: 'Islamiat', shortName: 'Isl'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          'App Configuration',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            Text(
              'Configure grades and subjects available when adding students',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: 24),

            // Grades Configuration Card
            _buildConfigurationCard(
              title: 'Grades',
              subtitle: 'Manage available grade levels',
              icon: Icons.school,
              iconColor: AppTheme.primaryPurple,
              itemCount: _availableGrades.length,
              activeCount: _availableGrades.where((g) => g.isActive).length,
              onTap: _showGradesModal,
              onAdd: _showAddGradeDialog,
            ),

            const SizedBox(height: 16),

            // Subjects Configuration Card
            _buildConfigurationCard(
              title: 'Subjects',
              subtitle: 'Manage available subjects',
              icon: Icons.book,
              iconColor: AppTheme.successColor,
              itemCount: _availableSubjects.length,
              activeCount: _availableSubjects
                  .length, // All subjects are considered active
              onTap: _showSubjectsModal,
              onAdd: _showAddSubjectDialog,
            ),

            const SizedBox(height: 32),

            // Reset to defaults button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showResetDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.restore, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Reset to Default Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required int itemCount,
    required int activeCount,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.textLight.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, color: AppTheme.primaryPurple),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatChip(
                    label: 'Total',
                    value: itemCount.toString(),
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 12),
                  if (title == 'Grades') // Only show active count for grades
                    _buildStatChip(
                      label: 'Active',
                      value: activeCount.toString(),
                      color: AppTheme.successColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tap to view and manage',
                      style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textLight.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showGradesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 20,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Grades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Add, edit, or toggle grade availability',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddGradeDialog,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Grades list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _availableGrades.length,
                  itemBuilder: (context, index) {
                    final grade = _availableGrades[index];
                    return _buildGradeModalItem(grade);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.book,
                        size: 20,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Subjects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Add, edit, or remove subjects',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddSubjectDialog,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Subjects list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = _availableSubjects[index];
                    return _buildSubjectModalItem(subject);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeModalItem(ConfigurableGrade grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: grade.isActive
            ? Colors.white
            : AppTheme.textLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: grade.isActive
              ? AppTheme.primaryPurple.withValues(alpha: 0.2)
              : AppTheme.textLight.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: grade.isActive
                ? AppTheme.primaryPurple.withValues(alpha: 0.1)
                : AppTheme.textLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              grade.shortName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: grade.isActive
                    ? AppTheme.primaryPurple
                    : AppTheme.textLight,
              ),
            ),
          ),
        ),
        title: Text(
          grade.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: grade.isActive ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
        subtitle: Text(
          grade.isActive
              ? 'Available for new students'
              : 'Hidden from selection',
          style: TextStyle(
            fontSize: 14,
            color: grade.isActive ? AppTheme.successColor : AppTheme.textLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: grade.isActive,
              activeColor: AppTheme.primaryPurple,
              onChanged: (value) => _toggleGradeActive(grade, value),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: AppTheme.textLight),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                  onTap: () =>
                      Future.delayed(Duration.zero, () => _editGrade(grade)),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ],
                  ),
                  onTap: () =>
                      Future.delayed(Duration.zero, () => _deleteGrade(grade)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectModalItem(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              subject.shortName ?? subject.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          'Short name: ${subject.shortName ?? 'N/A'}',
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.textLight),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              onTap: () =>
                  Future.delayed(Duration.zero, () => _editSubject(subject)),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
              onTap: () =>
                  Future.delayed(Duration.zero, () => _deleteSubject(subject)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddGradeDialog(
        onGradeAdded: (ConfigurableGrade newGrade) {
          setState(() {
            _availableGrades.add(newGrade);
          });
        },
      ),
    );
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        onSubjectAdded: (Subject newSubject) {
          setState(() {
            _availableSubjects.add(newSubject);
          });
        },
      ),
    );
  }

  void _editGrade(dynamic grade) {
    final gradeObj = grade as ConfigurableGrade;
    showDialog(
      context: context,
      builder: (context) => AddGradeDialog(
        grade: gradeObj,
        onGradeAdded: (ConfigurableGrade updatedGrade) {
          setState(() {
            final index = _availableGrades.indexWhere(
              (g) => g.id == updatedGrade.id,
            );
            if (index != -1) {
              _availableGrades[index] = updatedGrade;
            }
          });
        },
      ),
    );
  }

  void _editSubject(dynamic subject) {
    final subjectObj = subject as Subject;
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        subject: subjectObj,
        onSubjectAdded: (Subject updatedSubject) {
          setState(() {
            final index = _availableSubjects.indexWhere(
              (s) => s.id == updatedSubject.id,
            );
            if (index != -1) {
              _availableSubjects[index] = updatedSubject;
            }
          });
        },
      ),
    );
  }

  void _deleteGrade(dynamic grade) {
    final gradeObj = grade as ConfigurableGrade;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: Text('Are you sure you want to delete ${gradeObj.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _availableGrades.removeWhere((g) => g.id == gradeObj.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${gradeObj.name} deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(dynamic subject) {
    final subjectObj = subject as Subject;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subjectObj.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _availableSubjects.removeWhere((s) => s.id == subjectObj.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subjectObj.name} deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _toggleGradeActive(dynamic grade, bool value) {
    final gradeObj = grade as ConfigurableGrade;
    setState(() {
      final index = _availableGrades.indexWhere((g) => g.id == gradeObj.id);
      if (index != -1) {
        _availableGrades[index] = ConfigurableGrade(
          id: gradeObj.id,
          name: gradeObj.name,
          shortName: gradeObj.shortName,
          isActive: value,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${gradeObj.name} ${value ? 'activated' : 'deactivated'}',
        ),
        backgroundColor: value ? AppTheme.successColor : AppTheme.warningColor,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Configuration'),
        content: const Text(
          'Are you sure you want to reset all grades and subjects to default configuration? This will remove any custom items you\'ve added.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _availableGrades = [
        ConfigurableGrade(
          id: '1',
          name: 'Grade 1',
          shortName: 'G1',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '2',
          name: 'Grade 2',
          shortName: 'G2',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '3',
          name: 'Grade 3',
          shortName: 'G3',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '4',
          name: 'Grade 4',
          shortName: 'G4',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '5',
          name: 'Grade 5',
          shortName: 'G5',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '6',
          name: 'Grade 6',
          shortName: 'G6',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '7',
          name: 'Grade 7',
          shortName: 'G7',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '8',
          name: 'Grade 8',
          shortName: 'G8',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '9',
          name: 'Grade 9',
          shortName: 'G9',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '10',
          name: 'Grade 10',
          shortName: 'G10',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '11',
          name: 'Grade 11',
          shortName: 'G11',
          isActive: true,
        ),
        ConfigurableGrade(
          id: '12',
          name: 'Grade 12',
          shortName: 'G12',
          isActive: true,
        ),
      ];

      _availableSubjects = [
        const Subject(id: '1', name: 'Mathematics', shortName: 'Math'),
        const Subject(id: '2', name: 'English', shortName: 'Eng'),
        const Subject(id: '3', name: 'Physics', shortName: 'Phy'),
        const Subject(id: '4', name: 'Chemistry', shortName: 'Chem'),
        const Subject(id: '5', name: 'Biology', shortName: 'Bio'),
        const Subject(id: '6', name: 'Computer Science', shortName: 'CS'),
        const Subject(id: '7', name: 'Economics', shortName: 'Econ'),
        const Subject(id: '8', name: 'Accounting', shortName: 'Acc'),
        const Subject(id: '9', name: 'Urdu', shortName: 'Urdu'),
        const Subject(id: '10', name: 'Islamiat', shortName: 'Isl'),
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration reset to defaults'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}

// Model for configurable grades with active/inactive state
class ConfigurableGrade {
  final String id;
  final String name;
  final String shortName;
  final bool isActive;

  ConfigurableGrade({
    required this.id,
    required this.name,
    required this.shortName,
    required this.isActive,
  });
}
