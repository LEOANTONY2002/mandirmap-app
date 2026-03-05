import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

/// A drop-in replacement for [Image.network] that shows a shimmer placeholder
/// while loading and a graceful icon fallback when the URL fails or is null.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.fallbackIconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stack) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _shimmer();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: fallbackIconSize.sp,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.surface,
            AppColors.border.withValues(alpha: 0.5),
            AppColors.surface,
          ],
        ),
      ),
    );
  }
}
