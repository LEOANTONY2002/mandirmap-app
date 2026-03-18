import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mandirmap_app/core/theme/app_colors.dart';
import 'package:mandirmap_app/core/widgets/app_network_image.dart';
import 'package:mandirmap_app/features/home/data/models/location_model.dart';
import 'package:mandirmap_app/features/home/data/repositories/home_repository.dart';
import 'package:mandirmap_app/features/home/presentation/providers/home_providers.dart';
import 'package:mandirmap_app/features/auth/presentation/providers/user_provider.dart';
import 'package:mandirmap_app/features/astrology/data/models/review_model.dart';

final hotelDetailsProvider = FutureProvider.family<LocationModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getLocationDetails(id);
});

class HotelDetailsPage extends ConsumerWidget {
  const HotelDetailsPage({super.key, required this.hotelId});

  final String hotelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelAsync = ref.watch(hotelDetailsProvider(hotelId));

    return hotelAsync.when(
      data: (hotel) => Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      url: hotel.photos.isNotEmpty ? hotel.photos.first : null,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.hotel,
                      fallbackIconSize: 60,
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
                      hotel.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            hotel.addressText,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if (hotel.hotel != null) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price per Day',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${hotel.hotel!.pricePerDay}',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: hotel.hotel!.amenities.map((amenity) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final Uri phoneUri = Uri(
                                  scheme: 'tel',
                                  path: hotel.hotel!.contactPhone,
                                );
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                }
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final Uri whatsappUri = Uri.parse(
                                  'https://wa.me/${hotel.hotel!.whatsapp?.replaceAll('+', '')}',
                                );
                                if (await canLaunchUrl(whatsappUri)) {
                                  await launchUrl(
                                    whatsappUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildReviewsSection(context, ref, hotel),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    WidgetRef ref,
    LocationModel hotel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviews & Ratings',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hotel.totalRatings > 0)
                  Text(
                    '${hotel.averageRating.toStringAsFixed(1)} ★ (${hotel.totalRatings} reviews)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            TextButton(
              onPressed: () => _showAddReviewDialog(context, ref, hotel),
              child: Text(
                'Add Review',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (hotel.reviews.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hotel.reviews.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return _buildReviewItem(context, ref, hotel, hotel.reviews[index]);
            },
          ),
      ],
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    WidgetRef ref,
    LocationModel hotel,
    AstrologerReviewModel review,
  ) {
    final currentUser = ref.watch(userProvider).value;
    final isOwner = currentUser?.id == review.userId;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: AppNetworkImage(
                  url: review.user?.avatarUrl,
                  height: 40.w,
                  width: 40.w,
                  fallbackIcon: Icons.person,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.fullName ?? 'Anonymous User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 14.sp,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddReviewDialog(context, ref, hotel, review: review);
                    } else if (value == 'delete') {
                      _deleteReview(context, ref, hotel, review.id);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                  child: Icon(
                    Icons.more_vert,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddReviewDialog(
    BuildContext context,
    WidgetRef ref,
    LocationModel hotel, {
    AstrologerReviewModel? review,
  }) {
    final isEditing = review != null;
    int rating = review?.rating ?? 5;
    final commentController = TextEditingController(text: review?.comment);
    bool isLoading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(isEditing ? 'Edit Review' : 'Add Review'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => setState(() => rating = index + 1),
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: AppColors.gold,
                            size: 32.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    if (error != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              setState(() {
                                isLoading = true;
                                error = null;
                              });
                              try {
                                if (isEditing) {
                                  await ref
                                      .read(homeRepositoryProvider)
                                      .updateReview(
                                        hotel.id,
                                        review.id,
                                        rating,
                                        commentController.text,
                                      );
                                } else {
                                  await ref
                                      .read(homeRepositoryProvider)
                                      .submitReview(
                                        hotel.id,
                                        rating,
                                        commentController.text,
                                      );
                                }
                                final _ = await ref.refresh(
                                  hotelDetailsProvider(hotel.id).future,
                                );

                                // Invalidate list providers to ensure ratings are updated in other screens
                                ref.invalidate(nearbyLocationsProvider);
                                ref.invalidate(hotelsProvider);
                                ref.invalidate(restaurantsProvider);
                                ref.invalidate(searchResultsProvider);
                                ref.invalidate(nearbyTemplesProvider);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Review updated successfully'
                                            : 'Review submitted successfully',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                  error = 'Something went wrong. Try again.';
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(isEditing ? 'Update' : 'Submit'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _deleteReview(
    BuildContext context,
    WidgetRef ref,
    LocationModel hotel,
    String reviewId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Review'),
            content: const Text('Are you sure you want to delete this review?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref
                      .read(homeRepositoryProvider)
                      .deleteReview(hotel.id, reviewId);
                    final _ = await ref.refresh(
                      hotelDetailsProvider(hotel.id).future,
                    );

                    // Invalidate list providers to ensure ratings are updated in other screens
                    ref.invalidate(nearbyLocationsProvider);
                    ref.invalidate(hotelsProvider);
                    ref.invalidate(restaurantsProvider);
                    ref.invalidate(searchResultsProvider);
                    ref.invalidate(nearbyTemplesProvider);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review deleted')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete review')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
