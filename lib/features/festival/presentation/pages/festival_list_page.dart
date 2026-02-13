import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import 'festival_details_page.dart';

class FestivalListPage extends ConsumerWidget {
  const FestivalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);
    final districtsAsync = ref.watch(districtsListProvider);
    final selectedDistrict = ref.watch(selectedDistrictProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Festivals (Mahotsavam)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Dynamic District Selector
          districtsAsync.when(
            data:
                (districts) => Container(
                  height: 60.h,
                  color: Colors.white,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: districts.length,
                    separatorBuilder: (context, index) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final district = districts[index];
                      final isSelected = district.id == selectedDistrict;
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(selectedDistrictProvider.notifier)
                                .update(district.id);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                              ),
                            ),
                            child: Text(
                              district.name,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                fontSize: 13.sp,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: festivalsAsync.when(
              data: (festivals) {
                if (festivals.isEmpty) {
                  return const Center(child: Text('No festivals found.'));
                }
                return ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: festivals.length,
                  separatorBuilder: (context, index) => SizedBox(height: 15.h),
                  itemBuilder: (context, index) {
                    final festival = festivals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    FestivalDetailsPage(festival: festival),
                          ),
                        );
                      },
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(15.r),
                              ),
                              child:
                                  festival.photoUrl != null
                                      ? Image.network(
                                        festival.photoUrl!,
                                        width: 120.w,
                                        height: 120.h,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: 120.w,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: Icon(
                                          Icons.festival,
                                          color: AppColors.primary,
                                          size: 40.sp,
                                        ),
                                      ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      festival.name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 14.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(festival.startDate),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      festival.description ??
                                          'Experience the divine celebration and cultural heritage.',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
