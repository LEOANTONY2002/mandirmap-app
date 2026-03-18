import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../providers/home_providers.dart';
import '../widgets/temple_card.dart';

class NearbyTemplesPage extends ConsumerWidget {
  const NearbyTemplesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyTemples = ref.watch(nearbyTemplesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'nearby_temples'.tr(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40.w,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: nearbyTemples.when(
        data: (temples) {
          if (temples.isEmpty) {
            return Center(child: Text('no_temples_found'.tr()));
          }
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: temples.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final temple = temples[index];
              return TempleCard(
                location: temple,
                onTap: () {
                  context.push('/home/temples/${temple.id}');
                },
              );
            },
          );
        },
        loading: () => const ShimmerList(height: 120),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
