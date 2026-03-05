import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/location_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/nearby_temple_tile.dart';

class DeityDetailsPage extends ConsumerWidget {
  final DeityModel deity;
  const DeityDetailsPage({super.key, required this.deity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocationAsync = ref.watch(userLocationProvider);

    return userLocationAsync.when(
      data: (userLocation) {
        final templesAsync = ref.watch(
          templesByDeityProvider((
            deityId: deity.id,
            lat: userLocation['lat']!,
            lng: userLocation['lng']!,
          )),
        );

        return _buildScaffold(context, templesAsync);
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, _) => Scaffold(
            body: Center(child: Text('Error loading location: $err')),
          ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AsyncValue<List<LocationModel>> templesAsync,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    child: Text(
                      deity.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    'About Lord ${deity.name}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Lord ${deity.name} is one of the most revered deities in Hindu mythology. Temples dedicated to this deity are centers of spiritual energy and devotion.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Famous Temples',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          templesAsync.when(
            data: (temples) {
              if (temples.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.temple_buddhist_outlined,
                            size: 48.r,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'No specific temples listed yet for ${deity.name}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final temple = temples[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigate to temple details
                        },
                        child: NearbyTempleTile(location: temple),
                      ),
                    );
                  }, childCount: temples.length),
                ),
              );
            },
            loading:
                () => SliverToBoxAdapter(
                  child: const Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error loading temples: $err')),
                ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
        ],
      ),
    );
  }
}
