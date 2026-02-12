import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/temple_repository.dart';
import '../../../home/data/models/location_model.dart';

final templeDetailsProvider = FutureProvider.family<LocationModel, String>((
  ref,
  id,
) async {
  final repository = ref.watch(templeRepositoryProvider);
  return repository.getTempleDetails(id);
});
