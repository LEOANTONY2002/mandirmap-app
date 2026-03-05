import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/home_repository.dart';

import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/providers/user_provider.dart';

// Current user location provider (FETCHING ACTUAL LOCATION)
final userLocationProvider = FutureProvider<Map<String, double>?>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // No default here anymore, return null to trigger fallback
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  final position = await Geolocator.getCurrentPosition();
  return {'lat': position.latitude, 'lng': position.longitude};
});

final nearbyTemplesProvider = FutureProvider<List<LocationModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final location = await ref.watch(userLocationProvider.future);

  if (location != null) {
    return repository.getNearbyTemples(
      lat: location['lat']!,
      lng: location['lng']!,
    );
  } else {
    // FALLBACK: Search by User's City (District) from profile
    final user = await ref.watch(userProvider.future);
    if (user?.district != null && user!.district!.isNotEmpty) {
      return repository.getLocationsByCategory(
        'TEMPLE',
        district: user.district,
      );
    }
    return [];
  }
});

final deitiesProvider = FutureProvider<List<DeityModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getDeities();
});

class SelectedDistrictNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? districtId) => state = districtId;
}

final selectedDistrictProvider =
    NotifierProvider<SelectedDistrictNotifier, String?>(
      SelectedDistrictNotifier.new,
    );

final districtsListProvider = FutureProvider<List<DistrictModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);

  // Filter by User's State from profile
  final user = await ref.watch(userProvider.future);
  final districts = await repository.getDistricts(state: user?.state);

  // Set default selection if none exists
  if (ref.read(selectedDistrictProvider) == null && districts.isNotEmpty) {
    String defaultId = districts.first.id;
    if (user?.district != null) {
      try {
        defaultId =
            districts
                .firstWhere(
                  (d) => d.name.toLowerCase() == user!.district!.toLowerCase(),
                )
                .id;
      } catch (_) {}
    }
    // Update selection. We use a microtask to ensure we don't trigger
    // builds during the current computation.
    Future.microtask(
      () => ref.read(selectedDistrictProvider.notifier).update(defaultId),
    );
  }

  return districts;
});

final festivalsProvider = FutureProvider<List<FestivalModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final district = ref.watch(selectedDistrictProvider);

  if (district == null) return [];

  // Enterprise approach: Always filter on the backend for performance and scalability
  return repository.getFestivals(district: district);
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchResultsProvider = FutureProvider<List<LocationModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repository = ref.watch(homeRepositoryProvider);
  return repository.searchLocations(query);
});

final hotelsProvider = FutureProvider<List<LocationModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getLocationsByCategory('HOTEL');
});

final restaurantsProvider = FutureProvider<List<LocationModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getLocationsByCategory('RESTAURANT');
});

final nearbyLocationsProvider = FutureProvider.family<
  List<LocationModel>,
  ({double lat, double lng, String category})
>((ref, params) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getNearbyLocations(
    lat: params.lat,
    lng: params.lng,
    category: params.category,
  );
});

final templesByDeityProvider = FutureProvider.family<
  List<LocationModel>,
  ({int deityId, double? lat, double? lng, String? district})
>((ref, params) async {
  final repository = ref.watch(homeRepositoryProvider);
  if (params.lat != null && params.lng != null) {
    return repository.getTemplesByDeity(
      params.deityId,
      params.lat!,
      params.lng!,
    );
  } else if (params.district != null) {
    return repository.getLocationsByCategory(
      'TEMPLE',
      district: params.district,
      deityId: params.deityId,
    );
  }
  return [];
});
