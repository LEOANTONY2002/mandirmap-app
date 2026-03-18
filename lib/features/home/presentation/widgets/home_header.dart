import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
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
                  image: DecorationImage(
                    image:
                        (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl) as ImageProvider
                            : const NetworkImage(
                              'https://ui-avatars.com/api/?background=FF6B35&color=fff&name=User&size=100',
                            ),
                    fit: BoxFit.cover,
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
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFFCCCCCC), size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: TextStyle(fontSize: 14.sp),
                    cursorHeight: 20.h,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Search place or temples',
                      hintStyle: TextStyle(
                        color: const Color(0xFFCCCCCC),
                        fontSize: 12.sp,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hoverColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      focusColor: Colors.transparent,
                    ),
                  ),
                ),
                Icon(
                  Icons.mic_none,
                  color: const Color(0xFFCCCCCC),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
