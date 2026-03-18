import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  const AppShimmer.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle,
      baseColor = null,
      highlightColor = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.surface,
      highlightColor: highlightColor ?? Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              shape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(borderRadius.r),
          shape: shape,
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double height;
  final EdgeInsets? padding;
  final bool isCard;
  final bool isVertical;
  final bool isCircleAvatar;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.height = 80,
    this.padding,
    this.isCard = true,
    this.isVertical = false,
    this.isCircleAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.all(20.w),
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child:
                isCard
                    ? CardShimmer(
                      height: height.h,
                      isVertical: isVertical,
                      isCircleAvatar: isCircleAvatar,
                    )
                    : AppShimmer(
                      width: double.infinity,
                      height: height.h,
                      borderRadius: 16,
                    ),
          ),
    );
  }
}

class CardShimmer extends StatelessWidget {
  final double height;
  final bool isVertical;
  final bool isCircleAvatar;

  const CardShimmer({
    super.key,
    required this.height,
    this.isVertical = false,
    this.isCircleAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer(
              width: double.infinity,
              height: height * 0.65,
              borderRadius: 16,
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(width: 200.w, height: 16.h, borderRadius: 4),
                  SizedBox(height: 8.h),
                  AppShimmer(width: 120.w, height: 12.h, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isCircleAvatar)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: AppShimmer.circle(size: height - 24.w),
            )
          else
            AppShimmer(width: height, height: height, borderRadius: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppShimmer(width: 150.w, height: 16.h, borderRadius: 4),
                  SizedBox(height: 8.h),
                  AppShimmer(width: 100.w, height: 12.h, borderRadius: 4),
                  SizedBox(height: 8.h),
                  AppShimmer(
                    width: double.infinity,
                    height: 12.h,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TempleDetailSkeleton extends StatelessWidget {
  const TempleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 280.h,
          pinned: true,
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          leading: Container(
            margin: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: AppShimmer(
              width: double.infinity,
              height: 280.h,
              borderRadius: 0,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 250.w, height: 26.h, borderRadius: 4),
                SizedBox(height: 32.h),
                Wrap(
                  spacing: 16.w,
                  runSpacing: 20.h,
                  children: List.generate(
                    8,
                    (index) => SizedBox(
                      width: (1.sw - 40.w - 48.w) / 4,
                      child: Column(
                        children: [
                          AppShimmer(
                            width: 48.w,
                            height: 48.w,
                            borderRadius: 12,
                          ),
                          SizedBox(height: 8.h),
                          AppShimmer(
                            width: 40.w,
                            height: 10.h,
                            borderRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                AppShimmer(width: 200.w, height: 20.h, borderRadius: 4),
                SizedBox(height: 16.h),
                AppShimmer(
                  width: double.infinity,
                  height: 150.h,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HotelDetailSkeleton extends StatelessWidget {
  const HotelDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 280.h,
          pinned: true,
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: AppShimmer(
              width: double.infinity,
              height: 280.h,
              borderRadius: 0,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 220.w, height: 24.h, borderRadius: 4),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    AppShimmer(width: 16.w, height: 16.w, borderRadius: 4),
                    SizedBox(width: 8.w),
                    AppShimmer(width: 150.w, height: 14.h, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 20.h),
                AppShimmer(
                  width: double.infinity,
                  height: 60.h,
                  borderRadius: 12,
                ),
                SizedBox(height: 24.h),
                AppShimmer(width: 100.w, height: 18.h, borderRadius: 4),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(
                    5,
                    (index) => AppShimmer(width: 70.w, height: 25.h, borderRadius: 20),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: AppShimmer(width: double.infinity, height: 45.h, borderRadius: 8),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppShimmer(width: double.infinity, height: 45.h, borderRadius: 8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AstrologerDetailSkeleton extends StatelessWidget {
  const AstrologerDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Astrologer Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AppShimmer.circle(size: 80.r),
                    SizedBox(height: 8.h),
                    AppShimmer(width: 40.w, height: 14.h, borderRadius: 4),
                  ],
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer(width: 120.w, height: 18.h, borderRadius: 4),
                      SizedBox(height: 8.h),
                      AppShimmer(width: 100.w, height: 14.h, borderRadius: 4),
                      SizedBox(height: 8.h),
                      AppShimmer(width: 80.w, height: 12.h, borderRadius: 4),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppShimmer(width: 50.w, height: 16.h, borderRadius: 4),
                    SizedBox(height: 10.h),
                    AppShimmer(width: 60.w, height: 30.h, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: AppShimmer(width: double.infinity, height: 45.h, borderRadius: 10),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: AppShimmer(width: double.infinity, height: 45.h, borderRadius: 10),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              AppShimmer(width: 100.w, height: 20.h, borderRadius: 4),
              SizedBox(width: 20.w),
              AppShimmer(width: 120.w, height: 20.h, borderRadius: 4),
            ],
          ),
          SizedBox(height: 20.h),
          // Tab Content simulator
          AppShimmer(width: double.infinity, height: 100.h, borderRadius: 15),
          SizedBox(height: 15.h),
          AppShimmer(width: double.infinity, height: 100.h, borderRadius: 15),
        ],
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final bool isCircle;
  final int crossAxisCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 0.7,
    this.isCircle = true,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 20.h,
      ),
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Column(
            children: [
              if (isCircle)
                Expanded(child: AppShimmer.circle(size: 80.r))
              else
                Expanded(
                  child: AppShimmer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 12,
                  ),
                ),
              SizedBox(height: 8.h),
              AppShimmer(width: 60.w, height: 12.h, borderRadius: 4),
            ],
          ),
    );
  }
}

class ShimmerBanner extends StatelessWidget {
  final double height;
  final EdgeInsets? margin;
  const ShimmerBanner({super.key, required this.height, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: AppShimmer(
        width: double.infinity,
        height: height,
        borderRadius: 20,
      ),
    );
  }
}
