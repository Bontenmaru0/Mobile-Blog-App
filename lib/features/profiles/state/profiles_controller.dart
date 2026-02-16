import 'dart:io';
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
  late ProfilesService _service;

  @override
  // fetch profile on app start
  Future<Profile?> build() async {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value;

    if (user == null) return null;

    _service = ref.read(profilesServiceProvider);

    try {
      final data = await _service.fetchProfile();
      if (data.isEmpty) return null;

      return Profile.fromJson(data.first);
    } catch (e) {
      // print('ProfilesController build error: $e');
      return null;
    }
  }

  // create
  Future<void> createProfile({
    required String id,
    required String fullName,
    required String nickName,
    required String bio,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = await _service.createProfile(
        id: id,
        fullName: fullName,
        nickname: nickName,
        bio: bio,
        avatarFile: avatarFile,
      );

      print("DATA FROM SERVICE: $data");
      print("TYPE: ${data.runtimeType}");

      return Profile.fromJson(data);
    });
  }

  // update
  Future<void> updateProfile({
    required String id,
    required String fullName,
    required String nickname,
    required String bio,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = await _service.updateProfile(
        id: id,
        fullName: fullName,
        nickname: nickname,
        bio: bio,
        avatarFile: avatarFile,
      );

      return Profile.fromJson(data);
    });
  }
}
