import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import '../../../../core/theme/app_colors.dart';
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
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

      // Refresh user profile provider
      ref.invalidate(userProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
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
              CSCPickerPlus(
                showStates: true,
                showCities: true,
                flagState: CountryFlag.DISABLE,
                defaultCountry: CscCountry.India,
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                selectedItemStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                ),
                onCountryChanged: (value) {},
                onStateChanged:
                    (value) => setState(() => _selectedState = value),
                onCityChanged: (value) => setState(() => _selectedCity = value),
                stateDropdownLabel: _selectedState ?? "Select State",
                cityDropdownLabel: _selectedCity ?? "Select District",
              ),
              SizedBox(height: 24.h),

              _buildLabel('Addresses'),
              _buildTextField(
                controller: _address1Controller,
                hint: 'House No. / Building',
                icon: Icons.home_outlined,
              ),
              _buildTextField(
                controller: _address2Controller,
                hint: 'Street / Area',
                icon: Icons.location_on_outlined,
              ),
              _buildTextField(
                controller: _address3Controller,
                hint: 'Landmark',
                icon: Icons.map_outlined,
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
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
          hintText: hint,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        validator:
            (v) => (v == null || v.isEmpty) ? 'Field cannot be empty' : null,
      ),
    );
  }
}
