import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rentals/presentation/pages/rental_rooms_page.dart';

import '../pages/restaurants_page.dart';
import '../pages/generic_locations_page.dart';
import '../../../astrology/presentation/pages/astrology_page.dart';

class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'label': 'temple',
        'icon': Icons.temple_hindu,
        'color': const Color(0xFFFFECE0),
      },
      {
        'label': 'poojari',
        'icon': Icons.person,
        'color': const Color(0xFFE0F2FF),
      },
      {
        'label': 'astrology',
        'icon': Icons.auto_stories,
        'color': const Color(0xFFFFE0F2),
      },
      {
        'label': 'hotel_foods',
        'icon': Icons.restaurant,
        'color': const Color(0xFFE0FFE0),
      },
      {
        'label': 'rental_houses',
        'icon': Icons.home_work,
        'color': const Color(0xFFFAF0E6),
      },
      {
        'label': 'travel_booking',
        'icon': Icons.directions_bus,
        'color': const Color(0xFFF0E6FA),
      },
      {
        'label': 'handicrafts',
        'icon': Icons.shopping_bag,
        'color': const Color(0xFFFFF0E6),
      },
      {
        'label': 'festivals',
        'icon': Icons.celebration,
        'color': const Color(0xFFE6F0FA),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 15.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.8,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final labelKey = service['label'] as String;

          return GestureDetector(
            onTap: () {
              if (labelKey == 'rental_houses') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RentalRoomsPage(),
                  ),
                );
              } else if (labelKey == 'hotel_foods') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RestaurantsPage(),
                  ),
                );
              } else if (labelKey == 'astrology') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AstrologyPage(),
                  ),
                );
              } else if (labelKey == 'poojari') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GenericLocationsPage(
                          category: 'POOJARI',
                          title: 'poojari'.tr(),
                        ),
                  ),
                );
              } else if (labelKey == 'travel_booking') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GenericLocationsPage(
                          category: 'TRAVEL_HUB',
                          title: 'travel_booking'.tr(),
                        ),
                  ),
                );
              } else if (labelKey == 'handicrafts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GenericLocationsPage(
                          category: 'SHOP',
                          title: 'handicrafts'.tr(),
                        ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: service['color'] as Color,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  labelKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
