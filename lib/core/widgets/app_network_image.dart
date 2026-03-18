import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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
      debugPrint('[AppNetworkImage] URL is null or empty');
      return _placeholder();
    }

    debugPrint('[AppNetworkImage] Loading URL: $url');

    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _shimmer(),
      errorWidget: (context, url, error) {
        debugPrint('[AppNetworkImage] Error loading image ($url): $error');
        return _placeholder();
      },
      fadeInDuration: const Duration(milliseconds: 300),
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
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surface,
      ),
    );
  }
}
