import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/astrologer_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';

final nearbyAstrologersProvider = FutureProvider<List<AstrologerModel>>((
  ref,
) async {
  final repository = ref.watch(astrologyRepositoryProvider);
  final location = await ref.watch(userLocationProvider.future);

  return repository.getNearbyAstrologers(
    lat: location['lat']!,
    lng: location['lng']!,
  );
});
