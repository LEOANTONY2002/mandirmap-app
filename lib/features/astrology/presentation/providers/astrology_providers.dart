import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/models/astrologer_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';

final nearbyAstrologersProvider = FutureProvider<List<AstrologerModel>>((
  ref,
) async {
  final repository = ref.watch(astrologyRepositoryProvider);
  final location = await ref.watch(userLocationProvider.future);
  final user = await ref.watch(userProvider.future);

  // TIER 1: GPS Nearby
  if (location != null) {
    final nearby = await repository.getNearbyAstrologers(
      lat: location['lat']!,
      lng: location['lng']!,
    );
    if (nearby.isNotEmpty) return nearby;
  }

  // TIER 2: Profile District
  if (user?.district != null && user!.district!.isNotEmpty) {
    print('[Astrology] Falling back to district: ${user.district}');
    final districtNearby = await repository.getNearbyAstrologers(
      district: user.district,
    );
    if (districtNearby.isNotEmpty) return districtNearby;
  }

  // TIER 3: Everyone
  print('[Astrology] Final fallback to everyone');
  return repository.getAstrologers();
});
