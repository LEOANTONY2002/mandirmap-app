import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.cursorHeight,
    this.textStyle,
    this.hintStyle,
    this.containerPadding,
    this.contentPadding,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFECECEC),
    this.borderRadius = 20,
    this.boxShadow,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;
  final bool readOnly;
  final double? cursorHeight;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller?.text,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  containerPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: maxLines > 1 ? 0 : 0,
                  ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius.r),
                border: Border.all(color: borderColor),
                boxShadow:
                    boxShadow ??
                    [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
              ),
              child: Row(
                children: [
                  if (prefix != null) ...[
                    prefix!,
                    SizedBox(width: 14.w),
                  ],
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      onChanged: (value) {
                        field.didChange(value);
                        onChanged?.call(value);
                      },
                      onSubmitted: onFieldSubmitted,
                      obscureText: obscureText,
                      maxLines: obscureText ? 1 : maxLines,
                      readOnly: readOnly,
                      cursorHeight: cursorHeight,
                      cursorColor: AppColors.textPrimary,
                      textAlignVertical:
                          maxLines > 1
                              ? TextAlignVertical.top
                              : TextAlignVertical.center,
                      style:
                          textStyle ??
                          TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle:
                            hintStyle ??
                            TextStyle(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                            ),
                        contentPadding:
                            contentPadding ??
                            EdgeInsets.symmetric(
                              vertical: maxLines > 1 ? 16.h : 20.h,
                            ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ),
                  if (suffix != null) ...[
                    SizedBox(width: 12.w),
                    suffix!,
                  ],
                ],
              ),
            ),
            if (field.hasError) ...[
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
