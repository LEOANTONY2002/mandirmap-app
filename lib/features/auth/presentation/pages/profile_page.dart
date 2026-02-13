import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/user_model.dart';
import '../../../../features/favorites/presentation/pages/favorites_page.dart';
import 'edit_profile_page.dart';
import '../providers/user_provider.dart';
import '../providers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user data'));
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                _buildHeader(user),
                SizedBox(height: 40.h),
                _buildMenuSection(context, ref, user),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 35.r,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user.phoneNumber,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline, 'Your Profile', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(user: user),
            ),
          );
        }),
        _buildMenuItem(Icons.notifications_none, 'Notifications', () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
        }),
        _buildMenuItem(Icons.favorite_border, 'Favourites', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesPage()),
          );
        }),
        _buildMenuItem(Icons.settings_outlined, 'Settings', () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
        }),
        _buildMenuItem(
          Icons.translate,
          'Language',
          () => _showLanguageSelector(context),
        ),
        _buildMenuItem(Icons.star_border, 'Rate Us', () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
        }),
        _buildMenuItem(Icons.policy_outlined, 'Privacy Policy', () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('coming_soon'.tr())));
        }),
        SizedBox(height: 40.h),
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'choose_language'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'choose_language_desc'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 30.h),
                _LanguageTile(
                  title: 'english'.tr(),
                  subtitle: 'English',
                  isSelected: context.locale.languageCode == 'en',
                  onTap: () {
                    context.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 16.h),
                _LanguageTile(
                  title: 'malayalam'.tr(),
                  subtitle: 'മലയാളം',
                  isSelected: context.locale.languageCode == 'ml',
                  onTap: () {
                    context.setLocale(const Locale('ml'));
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 22.sp, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14.sp,
          color: AppColors.textPrimary,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
