import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/astrologer_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../providers/astrology_providers.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/providers/user_provider.dart';
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
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
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      tabs: const [Tab(text: 'User Reviews'), Tab(text: 'Astrologer Details')],
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
                      _showAddReviewDialog(context, astrologer);
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
                      _showAddReviewDialog(context, astrologer, review: review);
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

  void _showAddReviewDialog(BuildContext context, AstrologerModel astrologer, {AstrologerReviewModel? review}) {
    int rating = review?.rating ?? 5;
    final commentController = TextEditingController(text: review?.comment ?? '');
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(review == null ? 'Add Review' : 'Edit Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < rating ? Colors.amber : Colors.grey,
                          size: 32.sp,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  rating = index + 1;
                                  errorMessage = null;
                                });
                              },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: commentController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Write your experience (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                  ],
                ],
              ),
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
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            if (review == null) {
                              await ref
                                  .read(astrologyRepositoryProvider)
                                  .submitReview(
                                    astrologer.id,
                                    rating,
                                    commentController.text.trim(),
                                  );
                            } else {
                              await ref
                                  .read(astrologyRepositoryProvider)
                                  .updateReview(
                                    astrologer.id,
                                    review.id,
                                    rating,
                                    commentController.text.trim(),
                                  );
                            }

                            // Refresh the details provider and WAIT for it
                            final _ = await ref.refresh(
                                astrologerDetailsProvider(astrologer.id).future);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text(review == null ? 'Review added successfully!' : 'Review updated successfully!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() {
                                isLoading = false;
                                errorMessage =
                                    'Failed to save review. Please try again.';
                              });
                            }
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
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
