
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> fetchProfile() async {
    final response = await _supabase.rpc('get_user_profile');

    return response;
  }

  Future<dynamic> createProfile({
    required String id,
    required String fullName,
    required String bio,
  }) async {
    final response = await _supabase.rpc(
      'insert_profile',
      params: {
        'p_id': id,
        'p_full_name': fullName,
        'p_bio': bio,
      },
    );

    return response;
  }

  Future<dynamic> updateProfile({
    required String id,
    required String fullName,
    required String bio,
  }) async {
    final response = await _supabase.rpc(
      'update_profile',
      params: {
        'p_id': id,
        'p_full_name': fullName,
        'p_bio': bio,
      },
    );

    return response;
  }
}
