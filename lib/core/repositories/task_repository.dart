import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';
import '../storage/local_storage.dart';

class TaskRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<TaskModel>> getAllTasks() async {
    try {
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

        return TaskModel.fromJson({
          ...json,
          'collaborator_ids': collaboratorIds,
        });
      }).toList();
    } catch (e) {
      // If database is not available, return local tasks for demo
      // In production, you might want to log this error
      return AppLocalStorage().getAllTasks();
    }
  }

  Future<List<TaskModel>> getUserTasks(String userId) async {
    try {
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

        return TaskModel.fromJson({
          ...json,
          'collaborator_ids': collaboratorIds,
        });
      }).toList();
    } catch (e) {
      // If database is not available, return local user tasks for demo
      // In production, you might want to log this error
      return AppLocalStorage().getUserTasks(userId);
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String createdBy,
    required List<String> collaboratorIds,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
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
    } catch (e) {
      // If database is not available, create a local task model for demo
      // In production, you might want to log this error
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        createdBy: createdBy,
        startTime: startTime,
        endTime: endTime,
        createdAt: DateTime.now(),
        collaboratorIds: collaboratorIds,
      );
      AppLocalStorage().addTask(task); // Add to local storage
      return task;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      // If database is not available, delete from local storage for demo
      // In production, you might want to log this error
      AppLocalStorage().deleteTask(taskId);
    }
  }
}
