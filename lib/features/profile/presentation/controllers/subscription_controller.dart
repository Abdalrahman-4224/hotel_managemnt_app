import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';

/// The signed-in user's hotel and subscription. Reloads after a new login.
final subscriptionProvider = FutureProvider<Subscription>((ref) {
  ref.watch(authControllerProvider.select((s) => s.user?.id));
  return ref.read(profileRepositoryProvider).getSubscription();
});
