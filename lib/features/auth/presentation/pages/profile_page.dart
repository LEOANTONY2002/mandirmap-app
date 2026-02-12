import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_repository.dart';
import '../../domain/user_model.dart';
import 'login_page.dart';
import '../../domain/auth_repository.dart';

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data:
            (user) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(user),
                  SizedBox(height: 20.h),
                  _buildMenuSection(context, ref),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46.r,
                  backgroundImage:
                      user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : const NetworkImage(
                            'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?w=200&q=80',
                          ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            user.fullName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            user.phoneNumber,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final currentLang =
        context.locale.languageCode == 'en' ? 'English' : 'മലയാളം';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'edit_profile'.tr(), () {}),
          _buildMenuItem(Icons.history, 'my_bookings'.tr(), () {}),
          _buildMenuItem(Icons.favorite_border, 'favorites'.tr(), () {}),
          _buildMenuItem(Icons.notifications_none, 'notifications'.tr(), () {}),
          _buildMenuItem(
            Icons.language,
            '${'language'.tr()} ($currentLang)',
            () {
              // Toggle language for demo
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ml'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
          _buildMenuItem(Icons.help_outline, 'help_support'.tr(), () {}),
          _buildMenuItem(Icons.policy_outlined, 'privacy_policy'.tr(), () {}),
          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 10.h),
          _buildMenuItem(Icons.logout, 'log_out'.tr(), () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing:
          isDestructive
              ? null
              : Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
