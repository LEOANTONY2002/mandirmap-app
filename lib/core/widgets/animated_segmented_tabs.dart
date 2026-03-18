import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SegmentedTabItem {
  const SegmentedTabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class AnimatedSegmentedTabs extends StatelessWidget {
  const AnimatedSegmentedTabs({
    super.key,
    required this.controller,
    required this.items,
    this.height = 58,
    this.borderColor = const Color(0xFFFFB800),
    this.activeColor = const Color(0xFFFFC107),
    this.inactiveColor = const Color(0xFF1F2937),
  });

  final TabController controller;
  final List<SegmentedTabItem> items;
  final double height;
  final Color borderColor;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        final maxIndex = items.length - 1;
        final value = controller.animation!.value.clamp(0.0, maxIndex.toDouble());

        return Container(
          height: height.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / items.length;

              return Stack(
                children: [
                  Positioned(
                    left: value * segmentWidth,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: Padding(
                      padding: EdgeInsets.all(1.5.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _SegmentButton(
                            item: items[i],
                            selection: (1 - (value - i).abs()).clamp(0.0, 1.0),
                            activeColor: Colors.white,
                            inactiveColor: inactiveColor,
                            onTap: () => controller.animateTo(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.item,
    required this.selection,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final SegmentedTabItem item;
  final double selection;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = Color.lerp(inactiveColor, activeColor, selection)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: contentColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              item.label,
              style: TextStyle(
                color: contentColor,
                fontSize: 13.sp,
                fontWeight: selection > 0.5 ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
