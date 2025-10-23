import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/availability_model.dart';

class AvailabilityRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<AvailabilityModel>> getUserAvailability(String userId) async {
    try {
      final response = await _client
          .from('availability')
          .select()
          .eq('user_id', userId)
          .order('start_time');

      return (response as List)
          .map((json) => AvailabilityModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Database error: $e. Returning empty availability list for demo.');
      return [];
    }
  }

  Future<AvailabilityModel> addAvailability({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
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
    } catch (e) {
      print('Database error: $e. Creating local availability for demo.');
      // Create a local availability model for demo
      return AvailabilityModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteAvailability(int id) async {
    await _client.from('availability').delete().eq('id', id);
  }

  Future<List<AvailabilityModel>> getMultipleUsersAvailability(
    List<String> userIds,
  ) async {
    // For multiple users, we'll get all availability and filter in memory
    // This is not optimal but works for the demo
    final response = await _client
        .from('availability')
        .select()
        .order('start_time');

    final allAvailabilities = (response as List)
        .map((json) => AvailabilityModel.fromJson(json))
        .toList();

    // Filter by user IDs
    return allAvailabilities
        .where((availability) => userIds.contains(availability.userId))
        .toList();
  }
}
