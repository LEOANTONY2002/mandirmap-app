import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/main_shell.dart';
import '../providers/auth_controller.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? password;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    this.name,
    this.email,
    this.password,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Future<void> _verifyOtp() async {
    final code = _controllers.map((e) => e.text).join();
    if (code.length < 4) return;

    await ref.read(authControllerProvider.notifier).verifyOtp(code);

    if (ref.read(authControllerProvider).hasError == false) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainShell()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter the 4-digit code sent to +91 ${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: 60.w,
                    height: 60.h,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_controllers.every((e) => e.text.isNotEmpty)) {
                          _verifyOtp();
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              if (ref.watch(authControllerProvider).hasError)
                Text(
                  ref.watch(authControllerProvider).error.toString(),
                  style: const TextStyle(color: AppColors.error),
                ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed:
                    ref.watch(authControllerProvider).isLoading
                        ? null
                        : _verifyOtp,
                child:
                    ref.watch(authControllerProvider).isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Verify & Proceed'),
              ),
              SizedBox(height: 20.h),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
