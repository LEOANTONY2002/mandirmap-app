import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:email_validator/email_validator.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _selectedState;
  String? _selectedCity; // We'll use this as District in our context

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    print('Starting signup process...');
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedState == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both State and District'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signup(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            stateAttr: _selectedState!,
            district: _selectedCity!,
          );
    } catch (e) {
      print('Signup error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Registration Failed'),
                content: Text(e.toString().replaceAll('Exception: ', '')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Join MandirMap',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Fill in your details to get started',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Name Field
                  _buildLabel('Full Name'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'John Doe',
                    icon: Icons.person_outline,
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Name is required'
                                : null,
                  ),
                  SizedBox(height: 20.h),

                  // Email Field
                  _buildLabel('Email Address'),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'john@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email is required';
                      }
                      if (!EmailValidator.validate(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Phone Field
                  _buildLabel('Phone Number'),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+91 98765 43210',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Phone number is required'
                                : null,
                  ),
                  SizedBox(height: 20.h),

                  // Password Field
                  _buildLabel('Password'),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Minimum 6 characters',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator:
                        (v) =>
                            (v == null || v.length < 6)
                                ? 'Password too short'
                                : null,
                  ),
                  SizedBox(height: 24.h),

                  // State & District Selection (CSC Picker)
                  _buildLabel('Regional Details'),
                  SizedBox(height: 8.h),
                  CSCPickerPlus(
                    showStates: true,
                    showCities: true,
                    flagState: CountryFlag.DISABLE,
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade100,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    selectedItemStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
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
                    onCountryChanged:
                        (
                          value,
                        ) {}, // We'll force India in layout if possible, or just let users pick.
                    // CSC Picker starts with Country. Let's initialize to India if we can.
                    // Actually, CSCPicker doesn't have an 'initialCountry' parameter that works easily for just state/city.
                    // We will allow users to pick Country, but we can set default country.
                    defaultCountry: CscCountry.India,
                    onStateChanged: (value) {
                      setState(() {
                        _selectedState = value;
                        _selectedCity = null;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    countryDropdownLabel: "Country",
                    stateDropdownLabel: "State",
                    cityDropdownLabel: "District",
                  ),
                  SizedBox(height: 40.h),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child:
                          authState.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Sign Up',
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
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
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                )
                : null,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      validator: validator,
    );
  }
}
