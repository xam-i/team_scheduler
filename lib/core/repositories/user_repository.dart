import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../storage/local_storage.dart';

class UserRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  final _storage = SupabaseConfig.storage;

  Future<UserModel?> getCurrentUser() async {
    // Check local storage first
    final localUser = AppLocalStorage().getCurrentUser();
    if (localUser != null) return localUser;

    // For this demo, we'll create a mock user since we don't have authentication set up
    // In a real app, you would use Supabase auth
    return null; // This will trigger the onboarding flow
  }

  Future<UserModel> createUser({required String name, String? photoUrl}) async {
    try {
      // Generate a mock user ID for demo purposes
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      final userData = {'id': userId, 'name': name, 'photo_url': photoUrl};

      final response = await _client
          .from('users')
          .insert(userData)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // If database is not available, create a local user for demo
      print('Database error: $e. Creating local user for demo.');
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        id: userId,
        name: name,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );
      AppLocalStorage().addUser(user);
      return user;
    }
  }

  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (photoUrl != null) updateData['photo_url'] = photoUrl;

    final response = await _client
        .from('users')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client.from('users').select().order('name');
      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Database error: $e. Returning local users for demo.');
      return AppLocalStorage().getAllUsers();
    }
  }

  Future<String> uploadPhoto(String filePath, List<int> fileBytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _storage
          .from(SupabaseConfig.storageBucket)
          .uploadBinary(fileName, fileBytes);

      return _storage.from(SupabaseConfig.storageBucket).getPublicUrl(fileName);
    } catch (e) {
      print('Storage error: $e. Photo upload failed.');
      return ''; // Return empty string if upload fails
    }
  }
}
