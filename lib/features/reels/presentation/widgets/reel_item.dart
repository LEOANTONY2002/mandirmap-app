import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/media_model.dart';
import '../../../../core/widgets/app_shimmer.dart';

class ReelItem extends StatefulWidget {
  final MediaModel media;
  final bool isPaused;
  const ReelItem({super.key, required this.media, this.isPaused = false});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.media.url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.media.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.6) {
          if (!widget.isPaused) _controller.play();
        } else {
          _controller.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: VideoPlayer(_controller),
            )
          else
            const AppShimmer(
              width: double.infinity,
              height: double.infinity,
              baseColor: Colors.black,
              highlightColor: Colors.grey,
            ),

          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Side Actions
          Positioned(
            right: 16.w,
            bottom: 100.h,
            child: Column(
              children: [
                _buildActionIcon(Icons.favorite, widget.media.likes.toString()),
                SizedBox(height: 20.h),
                _buildActionIcon(Icons.comment, '0'),
                SizedBox(height: 20.h),
                _buildActionIcon(Icons.share, 'Share'),
              ],
            ),
          ),

          // User Info & Caption
          Positioned(
            left: 16.w,
            right: 80.w,
            bottom: 30.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: AppNetworkImage(
                        url: widget.media.userAvatar,
                        height: 40.r,
                        width: 40.r,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.person,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.media.userName ?? 'Anonymous User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Blessings from ${widget.media.locationName ?? 'Sacred Temple'} 🙏 #mandirmap #spirituality',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32.r),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
      ],
    );
  }
}
