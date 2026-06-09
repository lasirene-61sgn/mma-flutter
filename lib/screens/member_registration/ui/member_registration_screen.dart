import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  // Profile Photo
  XFile? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Personal Information Controllers
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _nativePlaceController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _hobbiesController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _bloodGroup;

  // Spouse Information Controllers
  final _spouseNameController = TextEditingController();
  final _spouseEducationController = TextEditingController();
  final _spouseOccupationController = TextEditingController();
  final _spouseHobbiesController = TextEditingController();
  DateTime? _spouseDateOfBirth;
  String? _spouseBloodGroup;
  DateTime? _weddingDate;

  // Contact Details Controllers
  final _mobileController = TextEditingController();
  final _spouseMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _officePhoneController = TextEditingController();
  final _residencePhoneController = TextEditingController();

  // Address Controllers
  final _officeAddressController = TextEditingController();
  final _residentialAddressController = TextEditingController();
  String _preferredAddress = 'Residence';

  // Additional Information Controllers
  final _achievementsController = TextEditingController();
  final _otherMembershipsController = TextEditingController();

  // Children Details
  final List<ChildInfo> _children = [];

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _nativePlaceController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _hobbiesController.dispose();
    _spouseNameController.dispose();
    _spouseEducationController.dispose();
    _spouseOccupationController.dispose();
    _spouseHobbiesController.dispose();
    _mobileController.dispose();
    _spouseMobileController.dispose();
    _emailController.dispose();
    _officePhoneController.dispose();
    _residencePhoneController.dispose();
    _officeAddressController.dispose();
    _residentialAddressController.dispose();
    _achievementsController.dispose();
    _otherMembershipsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: const Text('Member Registration'),
        actions: [
          TextButton.icon(
            onPressed: () => _showPreview(),
            icon: const Icon(Icons.preview, color: Colors.white),
            label: const Text(
              'Preview',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 5) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          onStepTapped: (index) {
            setState(() => _currentStep = index);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: details.onStepContinue,
                    icon: Icon(
                      _currentStep == 5 ? Icons.check : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    label: Text(
                      _currentStep == 5 ? 'Submit' : 'Continue',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MMPApp.maroon,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: details.onStepCancel,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Information
            Step(
              title: const Text('Personal Information'),
              subtitle: Text(
                _fullNameController.text.isNotEmpty 
                  ? _fullNameController.text 
                  : 'Your basic details'
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPersonalInfoSection(),
            ),
            // Step 2: Spouse Information
            Step(
              title: const Text('Spouse Information'),
              subtitle: Text(
                _spouseNameController.text.isNotEmpty 
                  ? _spouseNameController.text 
                  : 'Partner details (optional)'
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildSpouseInfoSection(),
            ),
            // Step 3: Contact Details
            Step(
              title: const Text('Contact Details'),
              subtitle: Text(
                _mobileController.text.isNotEmpty 
                  ? _mobileController.text 
                  : 'Phone & Email'
              ),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildContactSection(),
            ),
            // Step 4: Address Details
            Step(
              title: const Text('Address Details'),
              subtitle: Text('Preferred: $_preferredAddress'),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: _buildAddressSection(),
            ),
            // Step 5: Additional Information
            Step(
              title: const Text('Additional Information'),
              subtitle: const Text('Achievements & Memberships'),
              isActive: _currentStep >= 4,
              state: _currentStep > 4 ? StepState.complete : StepState.indexed,
              content: _buildAdditionalInfoSection(),
            ),
            // Step 6: Children Details
            Step(
              title: const Text('Children Details'),
              subtitle: Text(
                _children.isEmpty 
                  ? 'No children added' 
                  : '${_children.length} ${_children.length == 1 ? 'child' : 'children'} added'
              ),
              isActive: _currentStep >= 5,
              state: _currentStep > 5 ? StepState.complete : StepState.indexed,
              content: _buildChildrenSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Upload
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerDialog(),
                  child: Container(
                    width: 120,
                    height: 144, // 66mm x 48mm ratio (1.37)
                    decoration: BoxDecoration(
                      color: MMPApp.maroon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MMPApp.maroon.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(_profileImage!.path)
                                  : FileImage(File(_profileImage!.path)) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 36,
                                color: MMPApp.maroon.withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MMPApp.maroon.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: MMPApp.maroon,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Photo size: 66mm x 48mm',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                if (_profileImage != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _profileImage = null),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                    label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fatherNameController,
            label: "Father's Name",
            icon: Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nativePlaceController,
            label: 'Native Place',
            icon: Icons.location_city,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'Date of Birth',
            selectedDate: _dateOfBirth,
            onDateSelected: (date) => setState(() => _dateOfBirth = date),
            icon: Icons.cake,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _educationController,
            label: 'Education',
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
            icon: Icons.work,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Blood Group',
            value: _bloodGroup,
            items: _bloodGroups,
            onChanged: (value) => setState(() => _bloodGroup = value),
            icon: Icons.bloodtype,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _hobbiesController,
            label: 'Hobbies',
            icon: Icons.sports_esports,
            hint: 'e.g., Reading, Music, Sports',
          ),
        ],
      ),
    );
  }

  Widget _buildSpouseInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MMPApp.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite, color: MMPApp.orange),
              ),
              const SizedBox(width: 12),
              const Text(
                'Spouse Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MMPApp.maroon,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _spouseNameController,
            label: 'Spouse Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'Date of Birth (Spouse)',
            selectedDate: _spouseDateOfBirth,
            onDateSelected: (date) => setState(() => _spouseDateOfBirth = date),
            icon: Icons.cake,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _spouseEducationController,
            label: 'Education (Spouse)',
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _spouseOccupationController,
            label: 'Occupation (Spouse)',
            icon: Icons.work,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Blood Group (Spouse)',
            value: _spouseBloodGroup,
            items: _bloodGroups,
            onChanged: (value) => setState(() => _spouseBloodGroup = value),
            icon: Icons.bloodtype,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _spouseHobbiesController,
            label: 'Hobbies (Spouse)',
            icon: Icons.sports_esports,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'Wedding Date',
            selectedDate: _weddingDate,
            onDateSelected: (date) => setState(() => _weddingDate = date),
            icon: Icons.celebration,
            isWeddingDate: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone, color: Colors.green),
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _mobileController,
            label: 'Mobile Number (Self)',
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            required: true,
            hint: '+91 XXXXX XXXXX',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _spouseMobileController,
            label: 'Mobile Number (Spouse)',
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            hint: '+91 XXXXX XXXXX',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            required: true,
            hint: 'example@email.com',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _officePhoneController,
            label: 'Contact No. (Office)',
            icon: Icons.business,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _residencePhoneController,
            label: 'Contact No. (Residence)',
            icon: Icons.home,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMultilineTextField(
            controller: _officeAddressController,
            label: 'Office Address',
            icon: Icons.business,
            hint: 'Complete office address with PIN code',
          ),
          const SizedBox(height: 16),
          _buildMultilineTextField(
            controller: _residentialAddressController,
            label: 'Residential Address',
            icon: Icons.home,
            hint: 'Complete residential address with PIN code',
          ),
          const SizedBox(height: 20),
          const Text(
            'Preferred Communication Address',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAddressOption(
                  'Office',
                  Icons.business,
                  _preferredAddress == 'Office',
                  () => setState(() => _preferredAddress = 'Office'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressOption(
                  'Residence',
                  Icons.home,
                  _preferredAddress == 'Residence',
                  () => setState(() => _preferredAddress = 'Residence'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMultilineTextField(
            controller: _achievementsController,
            label: 'Achievements (if any)',
            icon: Icons.star,
            hint: 'Enter your achievements, awards, recognitions...',
          ),
          const SizedBox(height: 16),
          _buildMultilineTextField(
            controller: _otherMembershipsController,
            label: 'Membership in other Associations',
            icon: Icons.groups,
            hint: 'List other associations you are a member of...',
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.child_care, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Children Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _addChild(),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Add Child', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MMPApp.maroon,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_children.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No children added yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add Child" to add children details',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_children.length, (index) {
              return _buildChildCard(index);
            }),
        ],
      ),
    );
  }

  Widget _buildChildCard(int index) {
    final child = _children[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MMPApp.borderBrown.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: MMPApp.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      child.sex == 'Male' ? Icons.face : Icons.face_2,
                      size: 16,
                      color: MMPApp.maroon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Child ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MMPApp.maroon,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: () => _showDeleteChildDialog(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: child.name,
            decoration: InputDecoration(
              labelText: 'Child Name',
              prefixIcon: const Icon(Icons.person, color: MMPApp.maroon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) => setState(() => child.name = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: child.sex,
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    prefixIcon: const Icon(Icons.wc, color: MMPApp.maroon),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['Male', 'Female'].map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Row(
                        children: [
                          Icon(
                            sex == 'Male' ? Icons.male : Icons.female,
                            size: 18,
                            color: sex == 'Male' ? Colors.blue : Colors.pink,
                          ),
                          const SizedBox(width: 8),
                          Text(sex),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => child.sex = value ?? 'Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: child.dateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1980),
                      lastDate: DateTime.now(),
                      builder: (context, childWidget) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: MMPApp.maroon),
                          ),
                          child: childWidget!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => child.dateOfBirth = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.cake, color: MMPApp.maroon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          child.dateOfBirth != null
                              ? _dateFormat.format(child.dateOfBirth!)
                              : 'Select',
                          style: TextStyle(
                            color: child.dateOfBirth != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: MMPApp.maroon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
        ),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildMultilineTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Icon(icon, color: MMPApp.maroon),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    required IconData icon,
    bool isWeddingDate = false,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? (isWeddingDate ? DateTime.now() : DateTime(2000, 1, 1)),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: MMPApp.maroon,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: MMPApp.maroon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? _dateFormat.format(selectedDate)
                  : 'Select Date',
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey[600],
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: MMPApp.maroon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAddressOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? MMPApp.maroon.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MMPApp.maroon : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? MMPApp.maroon : Colors.grey[500],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? MMPApp.maroon : Colors.grey[600],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle, color: MMPApp.maroon, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  void _addChild() {
    setState(() {
      _children.add(ChildInfo());
    });
  }

  void _showDeleteChildDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Remove Child'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${_children[index].name.isNotEmpty ? _children[index].name : 'Child ${index + 1}'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _children.removeAt(index));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MMPApp.maroon,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended size: 66mm x 48mm (Passport size)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  Icons.camera_alt,
                  'Camera',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  Icons.photo_library,
                  'Gallery',
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registration Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Photo Preview
                  if (_profileImage != null)
                    Center(
                      child: Container(
                        width: 100,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MMPApp.maroon, width: 2),
                          image: DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_profileImage!.path)
                                : FileImage(File(_profileImage!.path)) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  _buildPreviewSection('Personal Information', [
                    _buildPreviewRow('Full Name', _fullNameController.text),
                    _buildPreviewRow("Father's Name", _fatherNameController.text),
                    _buildPreviewRow('Native Place', _nativePlaceController.text),
                    _buildPreviewRow('Date of Birth', _dateOfBirth != null ? _dateFormat.format(_dateOfBirth!) : '-'),
                    _buildPreviewRow('Education', _educationController.text),
                    _buildPreviewRow('Occupation', _occupationController.text),
                    _buildPreviewRow('Blood Group', _bloodGroup ?? '-'),
                    _buildPreviewRow('Hobbies', _hobbiesController.text),
                  ]),
                  if (_spouseNameController.text.isNotEmpty)
                    _buildPreviewSection('Spouse Information', [
                      _buildPreviewRow('Spouse Name', _spouseNameController.text),
                      _buildPreviewRow('Date of Birth', _spouseDateOfBirth != null ? _dateFormat.format(_spouseDateOfBirth!) : '-'),
                      _buildPreviewRow('Education', _spouseEducationController.text),
                      _buildPreviewRow('Occupation', _spouseOccupationController.text),
                      _buildPreviewRow('Blood Group', _spouseBloodGroup ?? '-'),
                      _buildPreviewRow('Hobbies', _spouseHobbiesController.text),
                      _buildPreviewRow('Wedding Date', _weddingDate != null ? _dateFormat.format(_weddingDate!) : '-'),
                    ]),
                  _buildPreviewSection('Contact Details', [
                    _buildPreviewRow('Mobile (Self)', _mobileController.text),
                    _buildPreviewRow('Mobile (Spouse)', _spouseMobileController.text),
                    _buildPreviewRow('Email', _emailController.text),
                    _buildPreviewRow('Office Phone', _officePhoneController.text),
                    _buildPreviewRow('Residence Phone', _residencePhoneController.text),
                  ]),
                  _buildPreviewSection('Address Details', [
                    _buildPreviewRow('Office Address', _officeAddressController.text),
                    _buildPreviewRow('Residential Address', _residentialAddressController.text),
                    _buildPreviewRow('Preferred Address', _preferredAddress),
                  ]),
                  if (_achievementsController.text.isNotEmpty || _otherMembershipsController.text.isNotEmpty)
                    _buildPreviewSection('Additional Information', [
                      _buildPreviewRow('Achievements', _achievementsController.text),
                      _buildPreviewRow('Other Memberships', _otherMembershipsController.text),
                    ]),
                  if (_children.isNotEmpty)
                    _buildPreviewSection('Children Details', [
                      ..._children.asMap().entries.map((entry) {
                        final child = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: MMPApp.maroon.withValues(alpha: 0.1),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: MMPApp.maroon,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child.name.isNotEmpty ? child.name : 'Not specified',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${child.sex} • ${child.dateOfBirth != null ? _dateFormat.format(child.dateOfBirth!) : "DOB not set"}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MMPApp.borderBrown.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: MMPApp.maroon,
              fontSize: 16,
            ),
          ),
          const Divider(),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check required fields
      if (_fullNameController.text.isEmpty || 
          _fatherNameController.text.isEmpty ||
          _mobileController.text.isEmpty ||
          _emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 12),
              const Text('Success!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your membership registration has been submitted successfully!',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MMPApp.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: MMPApp.maroon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Our team will review and contact you soon at ${_emailController.text}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text('Go to Home', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MMPApp.maroon,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class ChildInfo {
  String name = '';
  String sex = 'Male';
  DateTime? dateOfBirth;
}
