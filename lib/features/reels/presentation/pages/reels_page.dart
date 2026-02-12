import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reels_repository.dart';
import '../../data/models/media_model.dart';
import '../widgets/reel_item.dart';
import '../../../../core/theme/app_colors.dart';

final reelsProvider = FutureProvider<List<MediaModel>>((ref) async {
  return ref.watch(reelsRepositoryProvider).getReels();
});

class ReelsPage extends ConsumerWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelsAsync = ref.watch(reelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: reelsAsync.when(
        data: (reels) {
          if (reels.isEmpty) {
            return const Center(
              child: Text(
                'No Reels found yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              return ReelItem(media: reels[index]);
            },
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        error:
            (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
      ),
    );
  }
}
