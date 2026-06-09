import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:mmp_official/main.dart'; // Contains MMPApp colors
import '../notifier/profile_notifier.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(); // Read-only
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _labelNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _gotraController = TextEditingController();

  // VILLAGE
  final TextEditingController _villageController = TextEditingController(); // Read-only

  // BUSINESS
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _productServiceController = TextEditingController();
  final TextEditingController _officeAddressController = TextEditingController();

  // ADDRESS
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  DateTime? _selectedDateOfAnniversary;
  File? _profileImage;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final state = ref.read(profileNotifierProvider);
      if (state.profile == null) {
        await ref.read(profileNotifierProvider.notifier).loadProfile();
      }
      loadData();
    });
  }

  void loadData() {
    final profile = ref.read(profileNotifierProvider).profile;
    if (profile == null) return;

    setState(() {
      _nameController.text = profile.name;
      _mobileController.text = profile.mobile;
      _emailController.text = profile.email ?? '';
      _labelNameController.text = profile.labelName ?? '';
      _villageController.text = profile.villageName ?? '';
      _fatherNameController.text = profile.fatherName ?? '';
      _educationController.text = profile.education ?? '';
      _occupationController.text = profile.occupation ?? '';
      _genderController.text = profile.gender ?? '';
      _ageController.text = profile.age ?? '';
      _gotraController.text = profile.gotra ?? '';

      _firmNameController.text = profile.msFirmName ?? '';
      _businessTypeController.text = profile.businessType ?? '';
      _productServiceController.text = profile.productService ?? '';
      _officeAddressController.text = profile.officeAddress ?? '';

      _addressController.text = profile.address2 ?? '';
      _cityController.text = profile.city ?? '';
      _pincodeController.text = profile.pincode ?? '';

      _selectedDateOfBirth = profile.dateOfBirth;
      _selectedDateOfAnniversary = profile.anniversaryDate;
    });
  }

  Future<void> _saveProfile() async {
    final state = ref.watch(profileNotifierProvider);
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> updatedMember = {
      "id": state.profile?.id,
      "name": _nameController.text,
      "email": _emailController.text,
      "father_name": _fatherNameController.text,
      "mobile": _mobileController.text,
      "ms_firm_name": _firmNameController.text,
      "address2": _addressController.text,
      "city": _cityController.text,
      "pincode": _pincodeController.text,
      "business_type": _businessTypeController.text,
      "business_name": _firmNameController.text,
      "product_service": _productServiceController.text,
      "office_address": _officeAddressController.text,
      "gender": _genderController.text,
      "age": _ageController.text,
      "education": _educationController.text,
      "occupation": _occupationController.text,
      "date_of_birth": _selectedDateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!) : null,
      "anniversary_date": _selectedDateOfAnniversary != null ? DateFormat('yyyy-MM-dd').format(_selectedDateOfAnniversary!) : null,
      "status": "active",
      "admin_customer_id": state.profile?.adminCustomerId.toString(),
      "admin_id": state.profile?.adminId.toString(),
      "village_id": null,
      "area": '',
      "gotra": _gotraController.text,
      "label_name": _labelNameController.text,
      "district": "",
      "dno": "",
      "street_road": "",
      "otp_expires_at": null,
      "is_password_set": 1,
      "whatsapp": "",
      "blood_group": "",
      "hobbies": "",
      "native_place": "",
      "created_at": state.profile?.createdAt ?? DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String()
    };

    await ref.read(profileNotifierProvider.notifier).submitProfile(context, updatedMember, _profileImage, _backgroundImage);
  }

  Future<void> _pickImage(ImageSource source, bool isBackground) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          if (isBackground) {
            _backgroundImage = File(pickedFile.path);
          } else {
            _profileImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e")),
        );
      }
    }
  }

  void _showImagePickerSheet(BuildContext context, bool isBackground) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: MMPApp.cream, child: Icon(Icons.camera_alt, color: MMPApp.maroon)),
                title: const Text('Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isBackground);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(backgroundColor: MMPApp.cream, child: Icon(Icons.photo_library, color: MMPApp.maroon)),
                title: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isBackground);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth
          ? (_selectedDateOfBirth ?? DateTime.now())
          : (_selectedDateOfAnniversary ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MMPApp.maroon,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedDateOfAnniversary = picked;
        }
      });
    }
  }

  Widget _buildDatePicker(BuildContext context, String label, bool isDOB) {
    DateTime? date = isDOB ? _selectedDateOfBirth : _selectedDateOfAnniversary;
    return InkWell(
      onTap: () => _selectDate(context, isDOB),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: MMPApp.maroon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select Date',
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: MMPApp.maroon),
          filled: true,
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MMPApp.maroon, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: MMPApp.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MMPApp.maroon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: MMPApp.maroon),
        titleTextStyle: const TextStyle(
          color: MMPApp.maroon,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: state.isLoading && state.profile == null
            ? const Center(child: CircularProgressIndicator(color: MMPApp.maroon))
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Background Image and Avatar
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25 + 50,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Background Image (25% of screen)
                            Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.25,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: MMPApp.maroonLight,
                                    image: _backgroundImage != null
                                        ? DecorationImage(
                                            image: FileImage(_backgroundImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : (state.profile?.backgroundImage != null
                                            ? DecorationImage(
                                                image: NetworkImage(state.profile!.backgroundImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: InkWell(
                                    onTap: () => _showImagePickerSheet(context, true),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Avatar positioned at bottom center
                            Positioned(
                              bottom: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: MMPApp.maroon.withValues(alpha: 0.3), width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.white,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : (state.profile?.image != null
                                              ? NetworkImage(state.profile!.image!)
                                              : null) as ImageProvider?,
                                      child: (_profileImage == null && state.profile?.image == null)
                                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () => _showImagePickerSheet(context, false),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: MMPApp.orange,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Personal Information'),
                            _buildTextField(controller: _nameController, label: 'Name', icon: Icons.person),
                            _buildTextField(controller: _labelNameController, label: 'Label Name', icon: Icons.label),
                            _buildTextField(controller: _mobileController, label: 'Mobile', icon: Icons.phone, readOnly: true, keyboardType: TextInputType.phone),
                      _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                      _buildTextField(controller: _genderController, label: 'Gender', icon: Icons.wc),
                      _buildTextField(controller: _ageController, label: 'Age', icon: Icons.cake, keyboardType: TextInputType.number),
                      _buildTextField(controller: _fatherNameController, label: 'Father Name', icon: Icons.person_outline),
                      _buildTextField(controller: _educationController, label: 'Education', icon: Icons.school),
                      _buildTextField(controller: _gotraController, label: 'Gotra', icon: Icons.family_restroom, readOnly: true),
                      
                      _buildDatePicker(context, 'Date of Birth', true),
                      const SizedBox(height: 16),
                      _buildDatePicker(context, 'Anniversary Date', false),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Business Details'),
                      _buildTextField(controller: _firmNameController, label: 'Firm Name', icon: Icons.business),
                      _buildTextField(controller: _occupationController, label: 'Occupation', icon: Icons.work),
                      _buildTextField(controller: _businessTypeController, label: 'Business Type', icon: Icons.store),
                      _buildTextField(controller: _productServiceController, label: 'Product / Service', icon: Icons.category),
                      _buildTextField(controller: _officeAddressController, label: 'Office Address', icon: Icons.business_center, maxLines: 2),
                      const SizedBox(height: 8),

                      _buildSectionHeader('Address Details'),
                      _buildTextField(controller: _addressController, label: 'Address (Home)', icon: Icons.home, maxLines: 2),
                      _buildTextField(controller: _cityController, label: 'City', icon: Icons.location_city),
                      _buildTextField(controller: _pincodeController, label: 'Pincode', icon: Icons.pin_drop, keyboardType: TextInputType.number),
                      
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MMPApp.maroon,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Update Profile',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
