import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/temple_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../favorites/data/favorites_repository.dart';

class TempleDetailsPage extends ConsumerWidget {
  const TempleDetailsPage({super.key, required this.templeId});

  final String templeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templeAsync = ref.watch(templeDetailsProvider(templeId));
    final activeGroup = ref.watch(_activeTabGroupProvider);

    return templeAsync.when(
      data:
          (temple) => Scaffold(
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
                        Image.network(
                          temple.photos.isNotEmpty
                              ? temple.photos.first
                              : 'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?w=800&q=80',
                          fit: BoxFit.cover,
                        ),
                        // Dark gradient at bottom for text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(160),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                        // Title and Show in Map directly ON the image
                        Positioned(
                          bottom: 20.h,
                          left: 20.w,
                          right: 20.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  temple.name,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB200), // Yellow
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'Show in Map',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Consumer(
                      builder: (context, ref, child) {
                        final statusAsync = ref.watch(
                          favoriteStatusProvider(templeId),
                        );
                        final isFav = statusAsync.asData?.value ?? false;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(favoritesRepositoryProvider)
                                    .toggleFavorite(templeId);
                                ref.invalidate(
                                  favoriteStatusProvider(templeId),
                                );
                                ref.invalidate(favoritesProvider);
                              } catch (e) {
                                // Handle error
                              }
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 8.w,
                        right: 16.w,
                        top: 8.h,
                        bottom: 8.h,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _QuickActionGrid(),
                        SizedBox(height: 30.h),
                        _TempleDetailSection(
                          temple: temple,
                          group: activeGroup,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $err'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(templeDetailsProvider(templeId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class ActiveTabGroup extends Notifier<int> {
  @override
  int build() => 0;

  set group(int val) => state = val;
}

final _activeTabGroupProvider = NotifierProvider<ActiveTabGroup, int>(
  ActiveTabGroup.new,
);

class _QuickActionGrid extends ConsumerWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGroup = ref.watch(_activeTabGroupProvider);

    final actions = [
      {'label': 'Temple\nHistory', 'icon': Icons.history_edu, 'group': 0},
      {'label': 'Vazhipadu\n& Timing', 'icon': Icons.access_time, 'group': 1},
      {'label': 'Near by\nTemples', 'icon': Icons.near_me, 'group': 3},
      {'label': 'Photos\n& Videos', 'icon': Icons.video_collection, 'group': 2},
      {'label': 'Rental\n& Rooms', 'icon': Icons.hotel, 'group': 4},
      {'label': 'Hotel &\nRestaurants', 'icon': Icons.restaurant, 'group': 5},
      {'label': 'Travel\nBooking', 'icon': Icons.directions_bus, 'group': 6},
      {'label': 'Bus & Train\nTimings', 'icon': Icons.train, 'group': 7},
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 20.h,
      children:
          actions.map((action) {
            final group = action['group'] as int;
            final isSelected = group != -1 && activeGroup == group;

            return SizedBox(
              width: (1.sw - 40.w - 48.w) / 4,
              child: GestureDetector(
                onTap: () {
                  if (group != -1) {
                    ref.read(_activeTabGroupProvider.notifier).group = group;
                  }
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary
                                : const Color(0xFFFFB27F).withAlpha(40),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      action['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _TempleDetailSection extends StatefulWidget {
  final dynamic temple;
  final int group;

  const _TempleDetailSection({required this.temple, required this.group});

  @override
  State<_TempleDetailSection> createState() => _TempleDetailSectionState();
}

class _TempleDetailSectionState extends State<_TempleDetailSection> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant _TempleDetailSection oldWidget) {
    if (oldWidget.group != widget.group) {
      _selectedIndex = 0;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = switch (widget.group) {
      0 => ['Temple History', 'Location Details'],
      1 => ['Worship Timing', 'Vazhipadu Details'],
      2 => ['Photos', 'Videos'],
      3 => ['Nearby Temples', 'Community'],
      4 => ['Rental', 'Rooms'],
      5 => ['Hotels', 'Restaurants'],
      6 => ['Travel', 'Booking'],
      7 => ['Bus Times', 'Train Times'],
      _ => ['Details', 'More'],
    };

    return Column(
      children: [
        Container(
          height: 48.h,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(child: _buildSegmentButton(tabs[0], 0)),
              Expanded(child: _buildSegmentButton(tabs[1], 1)),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _buildContent(),
      ],
    );
  }

  Widget _buildSegmentButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB200) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.group == 0) {
      return _selectedIndex == 0 ? _buildHistory() : _buildLocation();
    } else if (widget.group == 1) {
      return _selectedIndex == 0 ? _buildTiming() : _buildVazhipadu();
    } else if (widget.group == 2) {
      return _selectedIndex == 0 ? _buildPhotos() : _buildVideos();
    } else if (widget.group == 4 || widget.group == 5) {
      // Rental/Rooms and Hotel/Restaurants
      final hotel = widget.temple.hotel;
      final restaurant = widget.temple.restaurant;

      if (_selectedIndex == 0) {
        // First tab: Rental or Hotel
        if (hotel == null) {
          return const Center(child: Text('No information available'));
        }
        return Column(
          children: [
            _buildInfoRow(
              Icons.payments_outlined,
              'Price per Day',
              '₹${hotel.pricePerDay}',
            ),
            if (hotel.amenities.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                'Amenities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                children:
                    hotel.amenities.map((a) => Chip(label: Text(a))).toList(),
              ),
            ],
          ],
        );
      } else {
        // Second tab: Rooms or Restaurants
        if (restaurant == null) {
          return const Center(child: Text('No information available'));
        }
        return Column(
          children: [
            _buildInfoRow(
              restaurant.isPureVeg ? Icons.eco : Icons.kebab_dining,
              'Type',
              restaurant.isPureVeg ? 'Pure Veg' : 'Veg & Non-Veg',
            ),
            if (restaurant.menuItems.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                'Special Menus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              ...restaurant.menuItems.map(
                (m) => ListTile(title: Text(m), dense: true),
              ),
            ],
          ],
        );
      }
    } else {
      return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildHistory() {
    final history = widget.temple.temple?.history ?? widget.temple.description;

    if (history == null || history.isEmpty) {
      return const Center(child: Text('History details not yet available'));
    }

    return Text(
      history,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
    );
  }

  Widget _buildLocation() {
    return Column(
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: AppColors.surface,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 40.sp, color: AppColors.primary),
                SizedBox(height: 10.h),
                Text(
                  'Map View Placeholder',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.temple.addressText,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTiming() {
    final openTime = widget.temple.temple?.openTime;
    final closeTime = widget.temple.temple?.closeTime;

    if (openTime == null && closeTime == null) {
      return const Center(child: Text('Timing details not available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.access_time, 'Opening Time', openTime ?? 'N/A'),
        SizedBox(height: 12.h),
        _buildInfoRow(
          Icons.history_toggle_off,
          'Closing Time',
          closeTime ?? 'N/A',
        ),
        SizedBox(height: 20.h),
        Text(
          'Note: Timings may vary during festivals and special occasions.',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildVazhipadu() {
    final vazhipadu = widget.temple.temple?.vazhipaduData;

    if (vazhipadu == null) {
      return const Center(child: Text('No offerings listed yet'));
    }

    List<dynamic> items = [];
    if (vazhipadu is List) {
      items = vazhipadu;
    } else if (vazhipadu is Map && vazhipadu.containsKey('items')) {
      items = vazhipadu['items'] as List;
    }

    if (items.isEmpty) {
      return const Center(child: Text('No offerings listed yet'));
    }

    return Column(
      children:
          items.map((item) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name']?.toString() ?? 'Pooja',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${item['price'] ?? '0'}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotos() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.temple.photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Image.network(widget.temple.photos[index], fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildVideos() {
    return const Center(child: Text('No videos available yet'));
  }
}
