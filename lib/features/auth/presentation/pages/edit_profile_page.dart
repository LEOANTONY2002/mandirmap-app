import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/user_model.dart';
import '../../domain/profile_repository.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _address3Controller;

  String? _selectedState;
  String? _selectedCity;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _address1Controller = TextEditingController(text: widget.user.address1);
    _address2Controller = TextEditingController(text: widget.user.address2);
    _address3Controller = TextEditingController(text: widget.user.address3);
    _selectedState = widget.user.state;
    _selectedCity = widget.user.district;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Upload avatar if changed
      if (_imageFile != null) {
        await ref
            .read(profileRepositoryProvider)
            .uploadAvatar(_imageFile!.path);
      }

      // 2. Update other details
      await ref.read(profileRepositoryProvider).updateProfile({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address1': _address1Controller.text.trim(),
        'address2': _address2Controller.text.trim(),
        'address3': _address3Controller.text.trim(),
        'state': _selectedState,
        'district': _selectedCity,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Uploader
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : widget.user.avatarUrl != null &&
                                    widget.user.avatarUrl!.isNotEmpty
                                ? AppNetworkImage(
                                  url: widget.user.avatarUrl,
                                  fit: BoxFit.cover,
                                  fallbackIcon: Icons.person,
                                  fallbackIconSize: 60,
                                )
                                : _buildDefaultAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              _buildLabel('Full Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),
              _buildLabel('Email Address'),
              _buildTextField(
                controller: _emailController,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildLabel('Phone Number'),
              _buildTextField(
                controller: _phoneController,
                hint: 'Enter your phone number',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),

              _buildLabel('Regional Details'),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Color(0xFFECECEC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Color(0xFFECECEC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: const BorderSide(color: Color(0xFFECECEC)),
                    ),
                  ),
                ),
                child: CSCPickerPlus(
                  showStates: true,
                  showCities: true,
                  flagState: CountryFlag.DISABLE,
                  defaultCountry: CscCountry.India,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFECECEC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  disabledDropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFECECEC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  selectedItemStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    height: 2.5,
                  ),
                  dropdownHeadingStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  dropdownItemStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  dropdownDialogRadius: 10.0,
                  searchBarRadius: 10.0,
                  onCountryChanged: (value) {},
                  onStateChanged:
                      (value) => setState(() {
                        _selectedState = value;
                        _selectedCity = null;
                      }),
                  onCityChanged:
                      (value) => setState(() => _selectedCity = value),
                  countryDropdownLabel: 'India',
                  stateDropdownLabel: _selectedState ?? "Select State",
                  cityDropdownLabel: _selectedCity ?? "Select District",
                ),
              ),
              SizedBox(height: 24.h),

              _buildLabel('Address'),
              _buildTextField(
                controller: _address1Controller,
                hint: 'House No. / Building',
                icon: Icons.home_outlined,
                isOptional: true,
              ),
              _buildTextField(
                controller: _address2Controller,
                hint: 'Street / Area',
                icon: Icons.location_on_outlined,
                isOptional: true,
              ),
              _buildTextField(
                controller: _address3Controller,
                hint: 'Landmark',
                icon: Icons.map_outlined,
                isOptional: true,
              ),

              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.surface,
      child: Icon(
        Icons.person,
        size: 60.w,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: AppInputField(
        controller: controller,
        keyboardType: keyboardType,
        hintText: hint,
        prefix: Icon(icon, color: AppColors.primary, size: 20.sp),
        textStyle: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
        validator:
            isOptional
                ? null
                : (v) =>
                    (v == null || v.isEmpty) ? 'Field cannot be empty' : null,
      ),
    );
  }
}
