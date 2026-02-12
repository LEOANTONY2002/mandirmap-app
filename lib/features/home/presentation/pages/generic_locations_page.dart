import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/home_repository.dart';

class GenericLocationsPage extends ConsumerWidget {
  final String category;
  final String title;

  const GenericLocationsPage({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use a family provider or just the repository directly.
    // To keep it simple, I'll use the repository.
    final locationsAsync = ref.watch(_locationsByCategoryProvider(category));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return Center(child: Text('No $title found.'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              return _buildLocationCard(locations[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLocationCard(LocationModel location) {
    final imageUrl =
        location.photos.isNotEmpty
            ? location.photos.first
            : 'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?w=200&q=80';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Image.network(
              imageUrl,
              height: 160.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.gold, size: 16.sp),
                        Text(
                          ' ${location.averageRating}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        location.addressText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _locationsByCategoryProvider =
    FutureProvider.family<List<LocationModel>, String>((ref, category) async {
      final repository = ref.watch(homeRepositoryProvider);
      return repository.getLocationsByCategory(category);
    });
