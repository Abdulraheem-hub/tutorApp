/**
 * @context7:feature:students
 * @context7:pattern:widget_component
 * 
 * Contact information form for add student step 3
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class ContactInfo {
  String name;
  String phone;
  String email;
  String relationship;

  ContactInfo({
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
    };
  }
}

class AddStudentContactInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> studentData;
  final Function(String, dynamic) onDataChanged;

  const AddStudentContactInfo({
    super.key,
    required this.formKey,
    required this.studentData,
    required this.onDataChanged,
  });

  @override
  State<AddStudentContactInfo> createState() => _AddStudentContactInfoState();
}

class _AddStudentContactInfoState extends State<AddStudentContactInfo> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  List<ContactInfo> _contacts = [];

  final List<String> _relationshipOptions = [
    'Father',
    'Mother',
    'Guardian',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _phoneController.text = widget.studentData['phoneNumber'] ?? '';
    _emailController.text = widget.studentData['email'] ?? '';
    _contacts = (widget.studentData['contacts'] as List<ContactInfo>?) ?? [];
    
    // Add a default contact if none exist
    if (_contacts.isEmpty) {
      _addContact();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addContact() {
    setState(() {
      _contacts.add(ContactInfo(
        name: '',
        phone: '',
        email: '',
        relationship: 'Father',
      ));
    });
    widget.onDataChanged('contacts', _contacts);
  }

  void _removeContact(int index) {
    if (_contacts.length > 1) {
      setState(() {
        _contacts.removeAt(index);
      });
      widget.onDataChanged('contacts', _contacts);
    }
  }

  void _updateContact(int index, String field, String value) {
    setState(() {
      switch (field) {
        case 'name':
          _contacts[index].name = value;
          break;
        case 'phone':
          _contacts[index].phone = value;
          break;
        case 'email':
          _contacts[index].email = value;
          break;
        case 'relationship':
          _contacts[index].relationship = value;
          break;
      }
    });
    widget.onDataChanged('contacts', _contacts);
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
              'Contact Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the student\'s contact details',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            
            // Primary Contact (Student's own contact)
            _buildPrimaryContactSection(),
            
            const SizedBox(height: 32),
            
            // Additional Contacts
            _buildAdditionalContactsSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Phone Number
          _buildFormField(
            label: 'Phone Number',
            controller: _phoneController,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty && !AppUtils.isValidPhone(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('phoneNumber', value),
          ),
          
          const SizedBox(height: 16),
          
          // Email
          _buildFormField(
            label: 'Email',
            controller: _emailController,
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty && !AppUtils.isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('email', value),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalContactsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: _addContact,
                icon: const Icon(
                  Icons.add,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                label: const Text(
                  'Add Contact',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Contact List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildContactCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(int index) {
    final contact = _contacts[index];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              if (_contacts.length > 1)
                IconButton(
                  onPressed: () => _removeContact(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Contact Name
          _buildContactField(
            label: 'Name',
            value: contact.name,
            hintText: 'Enter contact name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact name';
              }
              return null;
            },
            onChanged: (value) => _updateContact(index, 'name', value),
          ),
          
          const SizedBox(height: 12),
          
          // Relationship
          _buildRelationshipField(index, contact),
          
          const SizedBox(height: 12),
          
          // Contact Phone
          _buildContactField(
            label: 'Phone',
            value: contact.phone,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (!AppUtils.isValidPhone(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            onChanged: (value) => _updateContact(index, 'phone', value),
          ),
          
          const SizedBox(height: 12),
          
          // Contact Email
          _buildContactField(
            label: 'Email',
            value: contact.email,
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty && !AppUtils.isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) => _updateContact(index, 'email', value),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipField(int index, ContactInfo contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relationship',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: contact.relationship,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
          items: _relationshipOptions.map((String relationship) {
            return DropdownMenuItem<String>(
              value: relationship,
              child: Text(
                relationship,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateContact(index, 'relationship', newValue);
            }
          },
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
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
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

  Widget _buildContactField({
    required String label,
    required String value,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
        ),
      ],
    );
  }
}