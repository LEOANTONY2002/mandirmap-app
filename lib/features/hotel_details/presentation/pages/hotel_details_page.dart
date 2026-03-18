import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mandirmap_app/core/theme/app_colors.dart';
import 'package:mandirmap_app/core/widgets/animated_segmented_tabs.dart';
import 'package:mandirmap_app/core/widgets/app_input_field.dart';
import 'package:mandirmap_app/core/widgets/app_network_image.dart';
import 'package:mandirmap_app/core/widgets/app_shimmer.dart';
import 'package:mandirmap_app/features/auth/presentation/providers/user_provider.dart';
import 'package:mandirmap_app/features/astrology/data/models/review_model.dart';
import 'package:mandirmap_app/features/home/data/models/location_model.dart';
import 'package:mandirmap_app/features/home/data/repositories/home_repository.dart';
import 'package:mandirmap_app/features/home/presentation/providers/home_providers.dart';

final hotelDetailsProvider = FutureProvider.family<LocationModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getLocationDetails(id);
});

class HotelDetailsPage extends ConsumerStatefulWidget {
  const HotelDetailsPage({super.key, required this.hotelId});

  final String hotelId;

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage> {
  final _picker = ImagePicker();
  final _menuSearchController = TextEditingController();
  String _menuQuery = '';

  @override
  void dispose() {
    _menuSearchController.dispose();
    super.dispose();
  }

  Future<void> _refreshDetail() async {
    await ref.refresh(hotelDetailsProvider(widget.hotelId).future);
  }

  void _refreshLists() {
    ref.invalidate(nearbyLocationsProvider);
    ref.invalidate(hotelsProvider);
    ref.invalidate(restaurantsProvider);
    ref.invalidate(searchResultsProvider);
    ref.invalidate(nearbyTemplesProvider);
  }

  Future<void> _openReviewComposer(
    BuildContext context,
    LocationModel location, {
    AstrologerReviewModel? review,
  }) async {
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => _ReviewFormPage(
              locationId: location.id,
              reviewId: review?.id,
              initialRating: review?.rating ?? 5,
              initialComment: review?.comment ?? '',
              isEditing: review != null,
            ),
      ),
    );
    if (didChange != true) return;
    await _refreshDetail();
    _refreshLists();
  }

  Future<void> _deleteReview(LocationModel location, String reviewId) async {
    await ref.read(homeRepositoryProvider).deleteReview(location.id, reviewId);
    await _refreshDetail();
    _refreshLists();
  }

  Future<void> _uploadRestaurantPhoto(LocationModel location) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    await ref
        .read(homeRepositoryProvider)
        .uploadLocationImage(location.id, file.path);
    await _refreshDetail();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(hotelDetailsProvider(widget.hotelId));

    return locationAsync.when(
      data: (location) {
        if (location.category == 'RESTAURANT' && location.restaurant != null) {
          return _RestaurantDetails(
            location: location,
            menuQuery: _menuQuery,
            menuSearchController: _menuSearchController,
            onMenuSearchChanged:
                (value) => setState(() => _menuQuery = value.toLowerCase()),
            onAddReview: () => _openReviewComposer(context, location),
            onEditReview:
                (review) =>
                    _openReviewComposer(context, location, review: review),
            onDeleteReview: (reviewId) => _deleteReview(location, reviewId),
            onUploadPhoto: () => _uploadRestaurantPhoto(location),
          );
        }

        if ((location.category == 'HOTEL' || location.category == 'RENTAL') &&
            location.hotel != null) {
          return _RentalDetails(
            location: location,
            onAddReview: () => _openReviewComposer(context, location),
            onEditReview:
                (review) =>
                    _openReviewComposer(context, location, review: review),
            onDeleteReview: (reviewId) => _deleteReview(location, reviewId),
          );
        }

        return Scaffold(
          appBar: AppBar(backgroundColor: Colors.white),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                'This detail page only supports rentals and restaurants.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: HotelDetailSkeleton()),
      error:
          (err, _) => Scaffold(
            appBar: AppBar(backgroundColor: Colors.white),
            body: Center(child: Text('Error: $err')),
          ),
    );
  }
}

class _RentalDetails extends StatefulWidget {
  const _RentalDetails({
    required this.location,
    required this.onAddReview,
    required this.onEditReview,
    required this.onDeleteReview,
  });

  final LocationModel location;
  final VoidCallback onAddReview;
  final ValueChanged<AstrologerReviewModel> onEditReview;
  final ValueChanged<String> onDeleteReview;

  @override
  State<_RentalDetails> createState() => _RentalDetailsState();
}

class _RentalDetailsState extends State<_RentalDetails>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      final nextIndex = _tabController.index;
      if (_selectedIndex != nextIndex && mounted) {
        setState(() => _selectedIndex = nextIndex);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeTab(int nextIndex) {
    if (nextIndex < 0 || nextIndex > 1 || nextIndex == _selectedIndex) return;
    _tabController.animateTo(nextIndex);
    setState(() => _selectedIndex = nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final hotel = location.hotel;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppNetworkImage(
                    url:
                        location.photos.isNotEmpty
                            ? location.photos.first
                            : null,
                    width: double.infinity,
                    height: 250.h,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.hotel,
                  ),
                  Positioned(
                    top: 14.h,
                    left: 14.w,
                    child: _CircleAction(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => context.pop(),
                    ),
                  ),
                  Positioned(
                    top: 14.h,
                    right: 14.w,
                    child: const _CircleAction(icon: Icons.ios_share),
                  ),
                  Positioned(
                    left: 14.w,
                    bottom: 14.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Text(
                            location.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          ...List.generate(
                            5,
                            (_) => Icon(
                              Icons.star,
                              size: 11.sp,
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (location.photos.length > 1)
                SizedBox(
                  height: 62.h,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
                    scrollDirection: Axis.horizontal,
                    itemCount: location.photos.length.clamp(0, 4) as int,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder:
                        (_, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: AppNetworkImage(
                            url: location.photos[index],
                            width: 74.w,
                            height: 54.h,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.image,
                          ),
                        ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            location.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹${hotel?.pricePerDay.toStringAsFixed(0) ?? '0'}/Night',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            location.addressText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ContactButton(
                            label: 'Call',
                            color: AppColors.primary,
                            icon: Icons.call,
                            onTap: () async {
                              final phone = hotel?.contactPhone;
                              if (phone != null && phone.isNotEmpty) {
                                await launchUrl(
                                  Uri(scheme: 'tel', path: phone),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _ContactButton(
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            icon: Icons.chat,
                            onTap: () async {
                              final phone =
                                  hotel?.whatsapp ?? hotel?.contactPhone;
                              if (phone != null && phone.isNotEmpty) {
                                await launchUrl(
                                  Uri.parse(
                                    'https://wa.me/${phone.replaceAll('+', '')}',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    AnimatedSegmentedTabs(
                      controller: _tabController,
                      items: const [
                        SegmentedTabItem(
                          label: 'Amenities',
                          icon: Icons.home_repair_service_outlined,
                        ),
                        SegmentedTabItem(
                          label: 'Reviews',
                          icon: Icons.star_rounded,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 0,
                      height: 0,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Amenities'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity < -150) {
                          _changeTab(_selectedIndex + 1);
                        } else if (velocity > 150) {
                          _changeTab(_selectedIndex - 1);
                        }
                      },
                      child:
                          _selectedIndex == 0
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: hotel?.amenities.length ?? 0,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 8.w,
                                          mainAxisSpacing: 14.h,
                                          childAspectRatio: 0.78,
                                        ),
                                    itemBuilder: (_, index) {
                                      final amenity = hotel!.amenities[index];
                                      return Column(
                                        children: [
                                          Container(
                                            width: 60.w,
                                            height: 60.w,
                                            padding: EdgeInsets.all(16.r),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFF2EC),
                                              shape: BoxShape.circle,
                                            ),
                                            child: AppNetworkImage(
                                              url: amenity.image,
                                              fallbackIcon: Icons.home,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            amenity.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if ((location.description ?? '')
                                      .isNotEmpty) ...[
                                    SizedBox(height: 16.h),
                                    Text(
                                      location.description!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        height: 1.6,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                              : Column(
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (_) => Icon(
                                            Icons.star,
                                            size: 15.sp,
                                            color: const Color(0xFFFFC107),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        location.averageRating.toStringAsFixed(
                                          1,
                                        ),
                                        style: TextStyle(
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${location.totalRatings} Ratings',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton.icon(
                                      onPressed: widget.onAddReview,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Review'),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFFFFC95A),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  location.reviews.isEmpty
                                      ? const Center(
                                        child: Text('No reviews yet.'),
                                      )
                                      : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: location.reviews.length,
                                        separatorBuilder:
                                            (_, __) => SizedBox(height: 10.h),
                                        itemBuilder: (_, index) {
                                          return _ReviewCard(
                                            review: location.reviews[index],
                                            onEdit: widget.onEditReview,
                                            onDelete: widget.onDeleteReview,
                                          );
                                        },
                                      ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantDetails extends ConsumerStatefulWidget {
  const _RestaurantDetails({
    required this.location,
    required this.menuQuery,
    required this.menuSearchController,
    required this.onMenuSearchChanged,
    required this.onAddReview,
    required this.onEditReview,
    required this.onDeleteReview,
    required this.onUploadPhoto,
  });

  final LocationModel location;
  final String menuQuery;
  final TextEditingController menuSearchController;
  final ValueChanged<String> onMenuSearchChanged;
  final VoidCallback onAddReview;
  final ValueChanged<AstrologerReviewModel> onEditReview;
  final ValueChanged<String> onDeleteReview;
  final VoidCallback onUploadPhoto;

  @override
  ConsumerState<_RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends ConsumerState<_RestaurantDetails>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final restaurant = location.restaurant;
    final menuItems =
        restaurant?.menuItems.where((item) {
          if (widget.menuQuery.isEmpty) return true;
          return item.name.toLowerCase().contains(widget.menuQuery);
        }).toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  url:
                      location.photos.isNotEmpty ? location.photos.first : null,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant,
                ),
                Positioned(
                  top: 12.h,
                  left: 14.w,
                  child: _CircleAction(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => context.pop(),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 14.w,
                  child: const _CircleAction(icon: Icons.ios_share),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 11.sp,
                          color: const Color(0xFFFFA000),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          location.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (restaurant?.isPureVeg == true)
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 1.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
              child: AnimatedSegmentedTabs(
                controller: _tabController,
                items: const [
                  SegmentedTabItem(
                    label: 'Menu',
                    icon: Icons.lunch_dining_rounded,
                  ),
                  SegmentedTabItem(label: 'Reviews', icon: Icons.star_rounded),
                  SegmentedTabItem(
                    label: 'Photos',
                    icon: Icons.photo_library_outlined,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 0,
              height: 0,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Photos'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      children: [
                        AppInputField(
                          controller: widget.menuSearchController,
                          onChanged: widget.onMenuSearchChanged,
                          hintText: 'Search items',
                          prefix: Icon(
                            Icons.search,
                            color: const Color(0xFFFF6A3D),
                            size: 20.sp,
                          ),
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          hintStyle: TextStyle(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          cursorHeight: 20.h,
                          borderRadius: 20,
                          borderColor: const Color(0xFFECECEC),
                          containerPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: GridView.builder(
                            itemCount: menuItems.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 0.88,
                                ),
                            itemBuilder: (_, index) {
                              final item = menuItems[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: const Color(0xFFF0F0F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(14.r),
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: AppNetworkImage(
                                            url: item.image,
                                            fit: BoxFit.cover,
                                            fallbackIcon: Icons.restaurant_menu,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (_) => Icon(
                                  Icons.star,
                                  size: 15.sp,
                                  color: const Color(0xFFFFC107),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              location.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${location.totalRatings} Ratings',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: widget.onAddReview,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Review'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFFC95A)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child:
                              location.reviews.isEmpty
                                  ? const Center(child: Text('No reviews yet.'))
                                  : ListView.separated(
                                    itemCount: location.reviews.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(height: 10.h),
                                    itemBuilder: (_, index) {
                                      return _ReviewCard(
                                        review: location.reviews[index],
                                        onEdit: widget.onEditReview,
                                        onDelete: widget.onDeleteReview,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: widget.onUploadPhoto,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Upload Photos & Videos'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 42.h),
                            side: const BorderSide(color: Color(0xFFFFC95A)),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: GridView.builder(
                            itemCount: location.photos.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                ),
                            itemBuilder:
                                (_, index) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: AppNetworkImage(
                                    url: location.photos[index],
                                    fit: BoxFit.cover,
                                    fallbackIcon: Icons.image,
                                  ),
                                ),
                          ),
                        ),
                      ],
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

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.location, required this.onAddReview});

  final LocationModel location;
  final VoidCallback onAddReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.averageRating.toStringAsFixed(1),
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            '${location.totalRatings} ratings',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onAddReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 46.h),
            ),
            child: const Text('Add Review'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  final AstrologerReviewModel review;
  final ValueChanged<AstrologerReviewModel> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider).value;
    final isOwner = currentUser?.id == review.userId;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15.r,
            backgroundColor: const Color(0xFFE8E8E8),
            backgroundImage:
                review.user?.avatarUrl != null
                    ? NetworkImage(review.user!.avatarUrl!)
                    : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.user?.fullName ?? 'Guest User',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 12.sp,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                if ((review.comment ?? '').isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    review.comment!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(review);
                } else if (value == 'delete') {
                  onDelete(review.id);
                }
              },
              itemBuilder:
                  (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
        ],
      ),
    );
  }
}

class _ReviewFormPage extends ConsumerStatefulWidget {
  const _ReviewFormPage({
    required this.locationId,
    this.reviewId,
    required this.initialRating,
    required this.initialComment,
    required this.isEditing,
  });

  final String locationId;
  final String? reviewId;
  final int initialRating;
  final String initialComment;
  final bool isEditing;

  @override
  ConsumerState<_ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends ConsumerState<_ReviewFormPage> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final repository = ref.read(homeRepositoryProvider);

    try {
      if (widget.isEditing && widget.reviewId != null) {
        await repository.updateReview(
          widget.locationId,
          widget.reviewId!,
          _rating,
          _commentController.text.trim(),
        );
      } else {
        await repository.submitReview(
          widget.locationId,
          _rating,
          _commentController.text.trim(),
        );
      }

      if (!mounted) return;
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => _ReviewSuccessPage(rating: _rating)),
      );
      if (!mounted) return;
      Navigator.of(context).pop(changed == true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Review' : 'Add Review'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your experience',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16.h),
              AppInputField(
                controller: _commentController,
                maxLines: 8,
                hintText: 'Write your review here',
                backgroundColor: const Color(0xFFFFFBF5),
                borderColor: const Color(0xFFFFE0B2),
                borderRadius: 20,
                contentPadding: EdgeInsets.all(16.w),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: InkWell(
                        onTap: () => setState(() => _rating = index + 1),
                        borderRadius: BorderRadius.circular(24.r),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 34.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            widget.isEditing ? 'Update Review' : 'Add Review',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSuccessPage extends StatelessWidget {
  const _ReviewSuccessPage({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
              const Spacer(),
              Container(
                width: 92.w,
                height: 92.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1EB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: const Color(0xFFFFC107),
                  size: 46.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                rating.toString(),
                style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),
              const Text(
                'Thank you for the review',
                style: TextStyle(color: Colors.green),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50.h),
      ),
      icon: Icon(icon, size: 18.sp),
      label: Text(label),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ReviewResult {
  const _ReviewResult({required this.rating, required this.comment});

  final int rating;
  final String comment;
}
