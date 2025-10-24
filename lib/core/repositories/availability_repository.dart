import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/availability_model.dart';
import '../storage/local_storage.dart';

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
      // If database is not available, return local availability for demo
      // In production, you might want to log this error
      return AppLocalStorage().getUserAvailability(userId);
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
      // If database is not available, create a local availability model for demo
      // In production, you might want to log this error
      final availability = AvailabilityModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        createdAt: DateTime.now(),
      );
      AppLocalStorage().addAvailability(availability); // Add to local storage
      return availability;
    }
  }

  Future<void> deleteAvailability(int id) async {
    try {
      await _client.from('availability').delete().eq('id', id);
    } catch (e) {
      // If database is not available, delete from local storage for demo
      // In production, you might want to log this error
      AppLocalStorage().deleteAvailability(id);
    }
  }

  Future<List<AvailabilityModel>> getMultipleUsersAvailability(
    List<String> userIds,
  ) async {
    try {
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
    } catch (e) {
      // If database is not available, return local availabilities for demo
      // In production, you might want to log this error
      return AppLocalStorage().getMultipleUsersAvailability(userIds);
    }
  }
}
