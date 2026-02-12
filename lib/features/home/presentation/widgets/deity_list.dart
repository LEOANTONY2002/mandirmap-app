import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';
import '../../../../features/deity/presentation/pages/deity_list_page.dart';
import '../../../../features/deity/presentation/pages/deity_details_page.dart';

class DeityList extends ConsumerWidget {
  const DeityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deitiesAsync = ref.watch(deitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'List of Gods',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeityListPage(),
                    ),
                  );
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 100.h,
          child: deitiesAsync.when(
            data: (deities) {
              if (deities.isEmpty) return const SizedBox.shrink();

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: deities.length,
                separatorBuilder: (context, index) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final deity = deities[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeityDetailsPage(deity: deity),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            image:
                                deity.photoUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(deity.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              deity.photoUrl == null
                                  ? Icon(
                                    Icons.temple_hindu,
                                    color: AppColors.primary,
                                    size: 28.sp,
                                  )
                                  : null,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          deity.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
