import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/location_model.dart';
import '../providers/home_providers.dart';
import '../widgets/home_header.dart';
import '../widgets/deity_list.dart';
import '../widgets/temple_card.dart';
import '../../../../core/widgets/app_shimmer.dart';

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
                  SizedBox(height: 18.h),
                  const _FestivalSection(),
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
                  context.push('/home/temples/${result.id}');
                } else if (result.category == 'HOTEL' ||
                    result.category == 'RESTAURANT' ||
                    result.category == 'RENTAL') {
                  context.push('/home/hotels/${result.id}');
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
      loading: () => const ShimmerList(height: 84),
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
      data: (districts) {
        if (districts.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 36.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: districts.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    district.name,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FestivalSection extends ConsumerWidget {
  const _FestivalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);

    return festivalsAsync.when(
      data: (festivals) {
        if (festivals.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 290.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: festivals.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final festival = festivals[index];
              return _FestivalCard(festival: festival);
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 290.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) => AppShimmer(
            width: 160.w,
            height: 290.h,
            borderRadius: 28,
          ),
        ),
      ),
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
        context.push('/home/festival-details', extra: festival);
      },
      child: Container(
        width: 160.w,
        height: 330.h,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: AppNetworkImage(
                url: festival.photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                fallbackIcon: Icons.festival,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Text Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    festival.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    festival.description ?? festival.locationName ?? '',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    DateFormat('MMM dd, yyyy').format(festival.startDate),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.9),
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
                'Temple Near by Me',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/home/nearby-temples');
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
        nearbyTemples.when(
          data: (temples) {
            if (temples.isEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                alignment: Alignment.center,
                child: Text('no_temples_found'.tr()),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
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
          loading: () => const ShimmerList(height: 120, padding: EdgeInsets.zero),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
}
