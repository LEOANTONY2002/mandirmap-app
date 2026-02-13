import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/home_repository.dart';

import 'package:geolocator/geolocator.dart';

// Current user location provider (FETCHING ACTUAL LOCATION)
final userLocationProvider = FutureProvider<Map<String, double>>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Default to Kannur if service is disabled
    return {'lat': 11.8745, 'lng': 75.3704};
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return {'lat': 11.8745, 'lng': 75.3704};
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return {'lat': 11.8745, 'lng': 75.3704};
  }

  final position = await Geolocator.getCurrentPosition();
  return {'lat': position.latitude, 'lng': position.longitude};
});

final nearbyTemplesProvider = FutureProvider<List<LocationModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final location = await ref.watch(userLocationProvider.future);

  return repository.getNearbyTemples(
    lat: location['lat']!,
    lng: location['lng']!,
  );
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
  final districts = await repository.getDistricts();

  // Set default selection if none exists
  if (ref.read(selectedDistrictProvider) == null && districts.isNotEmpty) {
    ref.read(selectedDistrictProvider.notifier).update(districts.first.id);
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
