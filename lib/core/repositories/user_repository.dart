import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  final _storage = SupabaseConfig.storage;

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  Future<UserModel> createUser({required String name, String? photoUrl}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final userData = {'id': user.id, 'name': name, 'photo_url': photoUrl};

    final response = await _client
        .from('users')
        .insert(userData)
        .select()
        .single();

    return UserModel.fromJson(response);
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
    final response = await _client.from('users').select().order('name');

    return (response as List).map((json) => UserModel.fromJson(json)).toList();
  }

  Future<String> uploadPhoto(String filePath, List<int> fileBytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _storage
        .from(SupabaseConfig.storageBucket)
        .uploadBinary(fileName, fileBytes);

    return _storage.from(SupabaseConfig.storageBucket).getPublicUrl(fileName);
  }
}
