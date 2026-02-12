import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/location_model.dart';
import '../../data/favorites_repository.dart';

final favoritesProvider = FutureProvider<List<LocationModel>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavorites();
});

final favoriteStatusProvider = FutureProvider.family<bool, String>((
  ref,
  locationId,
) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavoriteStatus(locationId);
});
