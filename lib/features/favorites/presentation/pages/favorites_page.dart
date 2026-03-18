import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_segmented_tabs.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/favorites_repository.dart';
import '../providers/favorites_providers.dart';
import '../../../home/data/models/location_model.dart';
import '../../../../core/widgets/app_shimmer.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading:
            widget.showBackButton
                ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
                  onPressed: () => context.pop(),
                )
                : null,
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: favoritesAsync.when(
              data: (favorites) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(
                      _getFilteredFavorites(favorites, 0),
                      0,
                    ),
                    _buildTabContent(
                      _getFilteredFavorites(favorites, 1),
                      1,
                    ),
                    _buildTabContent(
                      _getFilteredFavorites(favorites, 2),
                      2,
                    ),
                  ],
                );
              },
              loading:
                  () => const ShimmerList(
                    height: 150,
                    padding: EdgeInsets.all(16),
                  ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: AnimatedSegmentedTabs(
        controller: _tabController,
        items: const [
          SegmentedTabItem(label: 'Temple', icon: Icons.home_filled),
          SegmentedTabItem(
            label: 'Resta',
            icon: Icons.restaurant_menu,
          ),
          SegmentedTabItem(label: 'Rooms', icon: Icons.bed_rounded),
        ],
      ),
    );
  }

  List<LocationModel> _getFilteredFavorites(
    List<LocationModel> favorites,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0:
        return favorites.where((l) => l.category == 'TEMPLE').toList();
      case 1:
        return favorites.where((l) => l.category == 'RESTAURANT').toList();
      case 2:
        return favorites
            .where((l) => l.category == 'HOTEL' || l.category == 'RENTAL')
            .toList();
      default:
        return [];
    }
  }

  Widget _buildTabContent(List<LocationModel> items, int tabIndex) {
    if (items.isEmpty) {
      return _buildEmptyState(tabIndex);
    }
    return _buildList(items, tabIndex);
  }

  Widget _buildList(List<LocationModel> items, int tabIndex) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = items[index];
        if (tabIndex == 0) return _TempleFavoriteCard(location: item);
        if (tabIndex == 1) {
          return _RestaurantFavoriteCard(location: item);
        }
        return _RoomFavoriteCard(location: item);
      },
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String message = "No favorites here yet";
    if (tabIndex == 0) message = "No favorite temples found";
    if (tabIndex == 1) message = "No favorite restaurants found";
    if (tabIndex == 2) message = "No favorite rooms found";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}

class _TempleFavoriteCard extends StatelessWidget {
  final LocationModel location;
  const _TempleFavoriteCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/home/temples/${location.id}');
      },
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppNetworkImage(
                url: location.photos.isNotEmpty ? location.photos.first : null,
                fit: BoxFit.cover,
                fallbackIcon: Icons.temple_hindu,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${location.district ?? ""}, Kerala',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: Colors.red, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantFavoriteCard extends ConsumerWidget {
  final LocationModel location;
  const _RestaurantFavoriteCard({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AppNetworkImage(
                  url:
                      location.photos.isNotEmpty ? location.photos.first : null,
                  height: 90.h,
                  width: 90.h,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant,
                ),
              ),
              if (location.restaurant?.isPureVeg == true)
                Positioned(
                  bottom: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(Icons.circle, color: Colors.green, size: 10.sp),
                  ),
                ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(favoritesRepositoryProvider)
                        .toggleFavorite(location.id)
                        .then((_) => ref.refresh(favoritesProvider));
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, color: Colors.red, size: 14.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.black, size: 12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            location.averageRating.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Location Details, ${location.distance != null ? (location.distance! / 1000).toStringAsFixed(1) : "1.2"} Km',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                if (location.restaurant?.isPureVeg == true)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Pure Veg',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomFavoriteCard extends ConsumerWidget {
  final LocationModel location;
  const _RoomFavoriteCard({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: AppNetworkImage(
                  url:
                      location.photos.isNotEmpty ? location.photos.first : null,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.hotel,
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB200),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        location.averageRating.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(favoritesRepositoryProvider)
                        .toggleFavorite(location.id)
                        .then((_) => ref.refresh(favoritesProvider));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, color: Colors.red, size: 18.sp),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Location | ${location.distance != null ? (location.distance! / 1000).toStringAsFixed(1) : "1.5"} km away',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${location.hotel?.pricePerDay ?? 2000}/ Day',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
