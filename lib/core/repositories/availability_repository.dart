import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/availability_model.dart';

class AvailabilityRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<AvailabilityModel>> getUserAvailability(String userId) async {
    final response = await _client
        .from('availability')
        .select()
        .eq('user_id', userId)
        .order('start_time');

    return (response as List)
        .map((json) => AvailabilityModel.fromJson(json))
        .toList();
  }

  Future<AvailabilityModel> addAvailability({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final availabilityData = {
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };

    final response = await _client
        .from('availability')
        .insert(availabilityData)
        .select()
        .single();

    return AvailabilityModel.fromJson(response);
  }

  Future<void> deleteAvailability(int id) async {
    await _client.from('availability').delete().eq('id', id);
  }

  Future<List<AvailabilityModel>> getMultipleUsersAvailability(
    List<String> userIds,
  ) async {
    final response = await _client
        .from('availability')
        .select()
        .inFilter('user_id', userIds)
        .order('start_time');

    return (response as List)
        .map((json) => AvailabilityModel.fromJson(json))
        .toList();
  }
}
