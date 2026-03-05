import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/location_model.dart';
import '../../../festival/presentation/pages/festival_details_page.dart';
import '../../../temple_details/presentation/pages/temple_details_page.dart';
import '../../../hotel_details/presentation/pages/hotel_details_page.dart';
import 'nearby_temples_page.dart';
import '../providers/home_providers.dart';
import '../widgets/home_header.dart';
import '../widgets/deity_list.dart';
import '../widgets/nearby_item_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Column(
      children: [
        const HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchQuery.isNotEmpty)
                  const _SearchResultsSection()
                else ...[
                  const _CategoryBar(),
                  SizedBox(height: 16.h),
                  const _FeaturedBannerSection(),
                  SizedBox(height: 24.h),
                  const DeityList(),
                  SizedBox(height: 24.h),
                  const _TempleNearBySection(),
                  SizedBox(height: 40.h),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchResultsSection extends ConsumerWidget {
  const _SearchResultsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text('no_results_found'.tr()),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return GestureDetector(
              onTap: () {
                if (result.category == 'TEMPLE') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TempleDetailsPage(templeId: result.id),
                    ),
                  );
                } else if (result.category == 'HOTEL' ||
                    result.category == 'RENTAL') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HotelDetailsPage(hotelId: result.id),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${result.category} detail page coming soon!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: AppNetworkImage(
                        url:
                            result.photos.isNotEmpty
                                ? result.photos.first
                                : null,
                        height: 60.h,
                        width: 60.h,
                        fallbackIcon: Icons.place,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            result.addressText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _CategoryBar extends ConsumerWidget {
  const _CategoryBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtsAsync = ref.watch(districtsListProvider);
    final selectedDistrict = ref.watch(selectedDistrictProvider);

    return districtsAsync.when(
      data:
          (districts) => SizedBox(
            height: 38.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: districts.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final district = districts[index];
                final isSelected = district.id == selectedDistrict;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(selectedDistrictProvider.notifier)
                        .update(district.id);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      district.name,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FeaturedBannerSection extends ConsumerWidget {
  const _FeaturedBannerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);

    return festivalsAsync.when(
      data: (festivals) {
        if (festivals.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 200.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: festivals.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final festival = festivals[index];
              return _FestivalCard(festival: festival);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FestivalCard extends StatelessWidget {
  final FestivalModel festival;

  const _FestivalCard({required this.festival});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FestivalDetailsPage(festival: festival),
          ),
        );
      },
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: AppNetworkImage(
                  url: festival.photoUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  fallbackIcon: Icons.festival,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('MMM dd, yyyy').format(festival.startDate),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempleNearBySection extends ConsumerWidget {
  const _TempleNearBySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyTemples = ref.watch(nearbyTemplesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'nearby_temples'.tr(),
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
                      builder: (context) => const NearbyTemplesPage(),
                    ),
                  );
                },
                child: Text(
                  'view_all'.tr(),
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
        nearbyTemples.when(
          data: (temples) {
            if (temples.isEmpty) {
              return Container(
                height: 200.h,
                alignment: Alignment.center,
                child: Text('no_temples_found'.tr()),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: temples.length,
              itemBuilder: (context, index) {
                final temple = temples[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TempleDetailsPage(templeId: temple.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: NearbyItemCard(location: temple),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
}
