import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../temple_details/presentation/pages/temple_details_page.dart';
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
          onPressed: () => Navigator.pop(context),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TempleDetailsPage(templeId: temple.id),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
