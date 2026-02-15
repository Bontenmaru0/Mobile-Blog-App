import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profiles_service.dart';
import '../../../core/models/profile_model.dart';
import '../../auth/state/auth_controller.dart';

final profilesServiceProvider = Provider((ref) {
  return ProfilesService();
});

final profilesControllerProvider =
    AsyncNotifierProvider<ProfilesController, Profile?>(
  ProfilesController.new,
);

class ProfilesController extends AsyncNotifier<Profile?> {
  late final ProfilesService _service;

  @override
    Future<Profile?> build() async {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;

    if (user == null) return null;

    _service = ref.read(profilesServiceProvider);

    try {
      final data = await _service.fetchProfile();
      if (data == null || data.isEmpty) return null;

      return Profile.fromJson(data.first);
    } catch (e, st) {
      // Just log the error, but return null so HomeScreen behaves normally
      print('ProfilesController build error: $e\n$st');
      return null;
    }
  }


  // CREATE
  Future<void> createProfile({
    required String id,
    required String fullName,
    required String bio,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = await _service.createProfile(
        id: id,
        fullName: fullName,
        bio: bio,
      );

      return Profile.fromJson(data);
    });
  }

  // UPDATE
  Future<void> updateProfile({
    required String id,
    required String fullName,
    required String bio,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = await _service.updateProfile(
        id: id,
        fullName: fullName,
        bio: bio,
      );

      return Profile.fromJson(data);
    });
  }
}
