import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/location_model.dart';

class DeityDetailsPage extends StatelessWidget {
  final DeityModel deity;
  const DeityDetailsPage({super.key, required this.deity});

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
                deity.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background:
                  deity.photoUrl != null
                      ? Image.network(deity.photoUrl!, fit: BoxFit.cover)
                      : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.temple_hindu,
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
                  Text(
                    'About ${deity.name}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Lord ${deity.name} is one of the most revered deities. This section will include detailed mythology, significance, and history related to the deity.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Famous Temples',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // Placeholder for temples
                  const Center(child: Text('Loading temples...')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
