import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';

/// The signed-in user's hotel (name, room count). Reloads after a new login.
final currentHotelProvider = FutureProvider<Hotel>((ref) {
  ref.watch(signedInUserIdProvider);
  return ref.read(profileRepositoryProvider).getHotel();
});

/// The hotel's subscription. Only watch it when the user has
/// [Permissions.subscriptionView] - without it the server answers 403.
final subscriptionProvider = FutureProvider<Subscription>((ref) {
  ref.watch(signedInUserIdProvider);
  return ref.read(profileRepositoryProvider).getSubscription();
});
