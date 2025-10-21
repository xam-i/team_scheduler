import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<TaskModel>> getAllTasks() async {
    final response = await _client
        .from('tasks')
        .select('''
          *,
          task_collaborators(user_id)
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final collaboratorIds =
          (json['task_collaborators'] as List<dynamic>?)
              ?.map((c) => c['user_id'] as String)
              .toList() ??
          [];

      return TaskModel.fromJson({...json, 'collaborator_ids': collaboratorIds});
    }).toList();
  }

  Future<List<TaskModel>> getUserTasks(String userId) async {
    final response = await _client
        .from('tasks')
        .select('''
          *,
          task_collaborators(user_id)
        ''')
        .or('created_by.eq.$userId,task_collaborators.user_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final collaboratorIds =
          (json['task_collaborators'] as List<dynamic>?)
              ?.map((c) => c['user_id'] as String)
              .toList() ??
          [];

      return TaskModel.fromJson({...json, 'collaborator_ids': collaboratorIds});
    }).toList();
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String createdBy,
    required List<String> collaboratorIds,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    // First create the task
    final taskData = {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };

    final taskResponse = await _client
        .from('tasks')
        .insert(taskData)
        .select()
        .single();

    final taskId = taskResponse['id'] as int;

    // Then add collaborators
    if (collaboratorIds.isNotEmpty) {
      final collaboratorData = collaboratorIds
          .map((userId) => {'task_id': taskId, 'user_id': userId})
          .toList();

      await _client.from('task_collaborators').insert(collaboratorData);
    }

    return TaskModel.fromJson({
      ...taskResponse,
      'collaborator_ids': collaboratorIds,
    });
  }

  Future<void> deleteTask(int taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
