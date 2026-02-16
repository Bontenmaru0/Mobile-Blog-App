import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProfilesService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // helper: convert Supabase RPC row to Map<String, dynamic>
  Map<String, dynamic> _extractSingleRow(dynamic rpcResponse) {
    final list = rpcResponse as List<dynamic>;
    if (list.isEmpty) throw Exception("No data returned from RPC");
    return Map<String, dynamic>.from(list.first);
  }

  // fetch profile
  Future<List<Map<String, dynamic>>> fetchProfile() async {
    final response = await _supabase.rpc('get_user_profile');
    final list = response as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // create profile
  Future<Map<String, dynamic>> createProfile({
    required String id,
    required String fullName,
    required String nickname,
    required String bio,
    File? avatarFile,
  }) async {
    String? avatarUrl;

    if (avatarFile != null) {
      final fileName = '${_uuid.v4()}-${avatarFile.path.split('/').last}';
      final filePath = 'avatars/$fileName';

      await _supabase.storage
          .from('profile_images')
          .uploadBinary(filePath, await avatarFile.readAsBytes());

      avatarUrl = _supabase.storage.from('profile_images').getPublicUrl(filePath);
    }

    final response = await _supabase.rpc(
      'insert_profile_mobile',
      params: {
        'p_id': id,
        'p_full_name': fullName,
        'p_nickname': nickname.toLowerCase(),
        'p_bio': bio,
        'p_avatar_url': avatarUrl,
      },
    );

    return _extractSingleRow(response);
  }

  // update profile
  Future<Map<String, dynamic>> updateProfile({
    required String id,
    required String fullName,
    required String nickname,
    required String bio,
    File? avatarFile,
  }) async {
    String? avatarUrl;

    if (avatarFile != null) {
      final fileName = '${_uuid.v4()}-${avatarFile.path.split('/').last}';
      final filePath = 'avatars/$fileName';

      await _supabase.storage
          .from('profile_images')
          .uploadBinary(filePath, await avatarFile.readAsBytes());

      avatarUrl = _supabase.storage.from('profile_images').getPublicUrl(filePath);
    }

    final response = await _supabase.rpc(
      'update_profile_mobile',
      params: {
        'p_id': id,
        'p_full_name': fullName,
        'p_nickname': nickname.toLowerCase(),
        'p_bio': bio,
        'p_avatar_url': avatarUrl,
      },
    );

    return _extractSingleRow(response);
  }
}
