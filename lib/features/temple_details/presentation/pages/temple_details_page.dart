import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/temple_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../rentals/presentation/pages/rental_rooms_page.dart';
import '../../../home/presentation/pages/restaurants_page.dart';

class TempleDetailsPage extends ConsumerWidget {
  const TempleDetailsPage({super.key, required this.templeId});

  final String templeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templeAsync = ref.watch(templeDetailsProvider(templeId));

    return templeAsync.when(
      data:
          (temple) => Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.h,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      temple.photos.isNotEmpty
                          ? temple.photos.first
                          : 'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?w=800&q=80',
                      fit: BoxFit.cover,
                    ),
                  ),
                  actions: [
                    Consumer(
                      builder: (context, ref, child) {
                        final statusAsync = ref.watch(
                          favoriteStatusProvider(templeId),
                        );
                        final isFav = statusAsync.asData?.value ?? false;

                        return IconButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(favoritesRepositoryProvider)
                                  .toggleFavorite(templeId);
                              ref.invalidate(favoriteStatusProvider(templeId));
                              ref.invalidate(favoritesProvider);
                            } catch (e) {
                              // Handle error
                            }
                          },
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                temple.name,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(26),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'show_in_map'.tr(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              temple.addressText,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        const _QuickActionGrid(),
                        SizedBox(height: 30.h),
                        _TempleTabs(
                          history:
                              temple.temple?.history ??
                              temple.description ??
                              '',
                          locationText: temple.addressText,
                          openTime: temple.temple?.openTime,
                          closeTime: temple.temple?.closeTime,
                          vazhipaduData: temple.temple?.vazhipaduData,
                          photos: temple.photos,
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
            appBar: AppBar(),
            body: Center(child: Text('Error: $err')),
          ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'temple_history', 'icon': Icons.history_edu},
      {'label': 'temple_timing', 'icon': Icons.access_time},
      {'label': 'nearby_temples', 'icon': Icons.near_me},
      {'label': 'videos', 'icon': Icons.video_collection},
      {'label': 'rental_houses', 'icon': Icons.hotel},
      {'label': 'hotel_foods', 'icon': Icons.restaurant},
      {'label': 'travel_booking', 'icon': Icons.directions_bus},
      {'label': 'bus_train_timings', 'icon': Icons.train},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.7,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final labelKey = actions[index]['label'] as String;
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
            }
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  actions[index]['icon'] as IconData,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                labelKey.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TempleTabs extends StatefulWidget {
  const _TempleTabs({
    required this.history,
    required this.locationText,
    this.openTime,
    this.closeTime,
    this.vazhipaduData,
    required this.photos,
  });

  final String history;
  final String locationText;
  final String? openTime;
  final String? closeTime;
  final Map<String, dynamic>? vazhipaduData;
  final List<String> photos;

  @override
  State<_TempleTabs> createState() => _TempleTabsState();
}

class _TempleTabsState extends State<_TempleTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'temple_history'.tr()),
            Tab(text: 'location_details'.tr()),
            Tab(text: 'temple_timing'.tr()),
            Tab(text: 'vazhipadu_details'.tr()),
            Tab(text: 'photos'.tr()),
            Tab(text: 'videos'.tr()),
          ],
        ),
        SizedBox(
          height: 350.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(),
              _buildLocationTab(),
              _buildTimingTab(),
              _buildVazhipaduTab(),
              _buildPhotosTab(),
              _buildVideosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Text(
        widget.history,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLocationTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: const Icon(
            Icons.map_outlined,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          widget.locationText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTimingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimingRow('morning_opening'.tr(), widget.openTime ?? '5:00 AM'),
          _buildTimingRow(
            'afternoon_closing'.tr(),
            widget.closeTime ?? '12:00 PM',
          ),
          _buildTimingRow('evening_opening'.tr(), '5:00 PM'),
          _buildTimingRow('night_closing'.tr(), '8:30 PM'),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String label, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVazhipaduTab() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      children: [
        _buildVazhipaduItem('Nirmalya Darshanam', '₹50'),
        _buildVazhipaduItem('Usha Pooja', '₹100'),
        _buildVazhipaduItem('Pushpanjali', '₹30'),
        _buildVazhipaduItem('Neyvilakku', '₹20'),
      ],
    );
  }

  Widget _buildVazhipaduItem(String name, String price) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withAlpha(128)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
      ),
      itemCount: widget.photos.length.clamp(4, 10),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: NetworkImage(
                index < widget.photos.length
                    ? widget.photos[index]
                    : 'https://images.unsplash.com/photo-1544198365-f5d60b6d8190?w=400&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    return Center(child: Text('coming_soon'.tr()));
  }
}
