import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../providers/home_providers.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).update(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.valueOrNull;
    final displayName = user?.fullName ?? 'Guest';
    final avatarUrl = user?.avatarUrl;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20.w,
        MediaQuery.of(context).padding.top + 10.h,
        20.w,
        16.h,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: AppNetworkImage(
                    url: avatarUrl,
                    width: 48.r,
                    height: 48.r,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.person,
                    fallbackIconSize: 22,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'namaste'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_outlined,
                  size: 26.sp,
                  color: AppColors.textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          AppInputField(
            onChanged: _onSearchChanged,
            hintText: 'Search place or temples',
            prefix: Icon(
              Icons.search,
              color: const Color(0xFFFF6A3D),
              size: 20.sp,
            ),
            hintStyle: TextStyle(
              color: const Color(0xFFB7B7B7),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            textStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            cursorHeight: 20.h,
            containerPadding: EdgeInsets.symmetric(horizontal: 16.w),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            borderRadius: 12,
            borderColor: const Color(0xFFEEEEEE),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
