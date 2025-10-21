import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

// Events
abstract class TaskEvent {}

class LoadAllTasks extends TaskEvent {}

class LoadUserTasks extends TaskEvent {
  final String userId;

  LoadUserTasks({required this.userId});
}

class CreateTask extends TaskEvent {
  final String title;
  final String? description;
  final String createdBy;
  final List<String> collaboratorIds;
  final DateTime? startTime;
  final DateTime? endTime;

  CreateTask({
    required this.title,
    this.description,
    required this.createdBy,
    required this.collaboratorIds,
    this.startTime,
    this.endTime,
  });
}

class DeleteTask extends TaskEvent {
  final int taskId;

  DeleteTask({required this.taskId});
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  TaskLoaded({required this.tasks});
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});
}

// Cubit
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;

  TaskCubit({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskInitial());

  Future<void> loadAllTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> loadUserTasks(String userId) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getUserTasks(userId);
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    required String createdBy,
    required List<String> collaboratorIds,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      await _taskRepository.createTask(
        title: title,
        description: description,
        createdBy: createdBy,
        collaboratorIds: collaboratorIds,
        startTime: startTime,
        endTime: endTime,
      );
      await loadAllTasks();
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = currentState.tasks
            .where((task) => task.id != taskId)
            .toList();
        emit(TaskLoaded(tasks: updatedTasks));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
