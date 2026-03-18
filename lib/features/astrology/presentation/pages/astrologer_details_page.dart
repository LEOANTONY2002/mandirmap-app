import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/animated_segmented_tabs.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/models/astrologer_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../providers/astrology_providers.dart';

class AstrologerDetailsPage extends ConsumerStatefulWidget {
  final String id;
  const AstrologerDetailsPage({super.key, required this.id});

  @override
  ConsumerState<AstrologerDetailsPage> createState() =>
      _AstrologerDetailsPageState();
}

class _AstrologerDetailsPageState extends ConsumerState<AstrologerDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final astrologerAsync = ref.watch(astrologerDetailsProvider(widget.id));
    final currentUserAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: astrologerAsync.when(
        data: (astrologer) => currentUserAsync.when(
          data: (user) => _buildContent(astrologer, user),
          loading: () => const AstrologerDetailSkeleton(),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
        loading: () => const AstrologerDetailSkeleton(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _openReviewComposer(
    BuildContext context,
    AstrologerModel astrologer, {
    AstrologerReviewModel? review,
  }) async {
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => _AstrologerReviewFormPage(
              astrologerId: astrologer.id,
              reviewId: review?.id,
              initialRating: review?.rating ?? 5,
              initialComment: review?.comment ?? '',
              isEditing: review != null,
            ),
      ),
    );

    if (didChange == true) {
      await ref.refresh(astrologerDetailsProvider(astrologer.id).future);
    }
  }

  Widget _buildContent(AstrologerModel astrologer, UserModel? user) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _buildAstrologerCard(astrologer),
                      SizedBox(height: 20.h),
                      _buildActionButtons(astrologer),
                      SizedBox(height: 30.h),
                      _buildTabBar(),
                      SizedBox(
                        width: 0,
                        height: 0,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'User Reviews'),
                            Tab(text: 'Astrologer Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReviewsTab(astrologer, user),
                    _buildDetailsTab(astrologer),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAstrologerCard(AstrologerModel astrologer) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6), // Light yellowish background from Figma
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildAvatar(astrologer.avatarUrl),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.gold, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    astrologer.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        astrologer.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (astrologer.isVerified) ...[
                      SizedBox(width: 4.w),
                      Icon(Icons.check_circle, color: Colors.blue, size: 18.sp),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  astrologer.languages.join(", "),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${astrologer.experienceYears}+ Year of Experience',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                if (astrologer.distance != null)
                  Text(
                    '${(astrologer.distance! / 1000).toStringAsFixed(1)} Km away',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${astrologer.hourlyRate.toInt()}/Hr',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return Container(
      width: 80.r,
      height: 80.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: ClipOval(
        child: AppNetworkImage(
          url: url ?? '',
          fit: BoxFit.cover,
          fallbackIcon: Icons.person,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AstrologerModel astrologer) {
    return Row(
      children: [
        Expanded(
          child: _buildIconButton(
            'Call',
            Icons.call,
            const Color(0xFFFF7A45),
            () => _launchCaller(astrologer.phoneNumber),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: _buildIconButton(
            'WhatsApp',
            Icons.chat_bubble,
            const Color(0xFF25D366),
            () => _launchWhatsApp(astrologer.whatsappNumber),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchCaller(String? number) async {
    if (number == null) return;
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String? number) async {
    if (number == null) return;
    final String cleanNumber = number.replaceAll('+', '');
    final Uri url = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTabBar() {
    return AnimatedSegmentedTabs(
      controller: _tabController,
      items: const [
        SegmentedTabItem(
          label: 'Reviews',
          icon: Icons.star_rounded,
        ),
        SegmentedTabItem(
          label: 'Details',
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildReviewsTab(AstrologerModel astrologer, UserModel? user) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color:
                          index < astrologer.rating.floor()
                              ? Colors.black
                              : Colors.grey.shade300,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                GestureDetector(
                  onTap: () {
                    if (user != null) {
                      _openReviewComposer(context, astrologer);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to review.')),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Text('Add Review', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 5.w),
                        const Icon(Icons.add, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  astrologer.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${astrologer.totalRatings} Ratings',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        if (astrologer.reviews != null)
          ...astrologer.reviews!.map((review) => _buildReviewItem(review, astrologer, user)),
      ],
    );
  }

  Widget _buildReviewItem(dynamic review, AstrologerModel astrologer, UserModel? currentUser) {
    final bool isMyReview = currentUser != null && review.userId == currentUser.id;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: ClipOval(
                  child: review.user?.avatarUrl != null &&
                          review.user!.avatarUrl!.isNotEmpty
                      ? AppNetworkImage(
                          url: review.user!.avatarUrl!,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.person,
                        )
                      : Icon(Icons.person,
                          size: 16.sp, color: Colors.grey.shade600),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                (review.user?.fullName != null &&
                        review.user!.fullName.isNotEmpty)
                    ? review.user!.fullName
                    : 'Anonymous User',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const Spacer(),
              if (isMyReview)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openReviewComposer(
                        context,
                        astrologer,
                        review: review,
                      );
                    } else if (value == 'delete') {
                      _deleteReview(context, astrologer, review);
                    }
                  },
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color:
                    index < review.rating ? Colors.amber : Colors.grey.shade300,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review.comment ?? '',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(AstrologerModel astrologer) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        if (astrologer.photoUrls.isNotEmpty)
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: astrologer.photoUrls.length,
              itemBuilder:
                  (context, index) => Container(
                    width: 120.w,
                    margin: EdgeInsets.only(right: 15.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: AppNetworkImage(
                        url: astrologer.photoUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            ),
          ),
        SizedBox(height: 20.h),
        Text(
          astrologer.bio ?? '',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  void _deleteReview(BuildContext context, AstrologerModel astrologer, dynamic review) {
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Review'),
              content: const Text('Are you sure you want to delete this review?'),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            await ref
                                .read(astrologyRepositoryProvider)
                                .deleteReview(astrologer.id, review.id);

                            // Refresh the details provider and WAIT for it
                            final _ = await ref.refresh(
                                astrologerDetailsProvider(astrologer.id).future);

                            if (context.mounted) {
                              Navigator.pop(context); // close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Review deleted successfully!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error deleting review.')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AstrologerReviewFormPage extends ConsumerStatefulWidget {
  const _AstrologerReviewFormPage({
    required this.astrologerId,
    this.reviewId,
    required this.initialRating,
    required this.initialComment,
    required this.isEditing,
  });

  final String astrologerId;
  final String? reviewId;
  final int initialRating;
  final String initialComment;
  final bool isEditing;

  @override
  ConsumerState<_AstrologerReviewFormPage> createState() =>
      _AstrologerReviewFormPageState();
}

class _AstrologerReviewFormPageState
    extends ConsumerState<_AstrologerReviewFormPage> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  String? _errorMessage;

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
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(astrologyRepositoryProvider);
      if (widget.isEditing && widget.reviewId != null) {
        await repository.updateReview(
          widget.astrologerId,
          widget.reviewId!,
          _rating,
          _commentController.text.trim(),
        );
      } else {
        await repository.submitReview(
          widget.astrologerId,
          _rating,
          _commentController.text.trim(),
        );
      }

      if (!mounted) return;
      final didChange = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => _AstrologerReviewSuccessPage(rating: _rating),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(didChange == true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to save review. Please try again.';
      });
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
                hintText: 'Write your experience (optional)',
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
              if (_errorMessage != null) ...[
                SizedBox(height: 16.h),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ],
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

class _AstrologerReviewSuccessPage extends StatelessWidget {
  const _AstrologerReviewSuccessPage({required this.rating});

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
