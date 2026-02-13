import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/location_model.dart';
import '../../../temple_details/presentation/pages/temple_details_page.dart';

class FestivalDetailsPage extends StatelessWidget {
  final FestivalModel festival;
  const FestivalDetailsPage({super.key, required this.festival});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                festival.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background:
                  festival.photoUrl != null
                      ? Image.network(festival.photoUrl!, fit: BoxFit.cover)
                      : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.festival,
                          size: 100.r,
                          color: AppColors.primary,
                        ),
                      ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Upcoming', // Mock status
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.share, color: AppColors.textSecondary),
                      SizedBox(width: 20.w),
                      Icon(
                        Icons.favorite_border,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    festival.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${DateFormat('MMM dd').format(festival.startDate)} - ${DateFormat('MMM dd, yyyy').format(festival.endDate)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Text(
                    'About Festival',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    festival.description ??
                        'A traditional celebration featuring cultural performances, divine rituals, and community gatherings. This festival marks an important event in the temple calendar, attracting thousands of devotees.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  if (festival.locationId != null) ...[
                    Text(
                      'Location (Temple)',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TempleDetailsPage(
                                  templeId: festival.locationId!,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.temple_hindu, color: AppColors.primary),
                            SizedBox(width: 15.w),
                            const Text(
                              'View Temple Details',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder feature coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          child: const Text('Set Reminder'),
        ),
      ),
    );
  }
}
