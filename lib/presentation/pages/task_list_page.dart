import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/task_cubit.dart';
import '../../core/bloc/user_cubit.dart';
import '../../core/models/task_model.dart';
import 'create_task_page.dart';

enum TaskFilter { all, created, mine }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded && userState.currentUser != null) {
      switch (_currentFilter) {
        case TaskFilter.all:
          context.read<TaskCubit>().loadAllTasks();
          break;
        case TaskFilter.created:
        case TaskFilter.mine:
          context.read<TaskCubit>().loadUserTasks(userState.currentUser!.id);
          break;
      }
    }
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded || userState.currentUser == null) {
      return tasks;
    }

    final currentUserId = userState.currentUser!.id;

    switch (_currentFilter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.created:
        return tasks.where((task) => task.createdBy == currentUserId).toList();
      case TaskFilter.mine:
        return tasks
            .where(
              (task) =>
                  task.createdBy == currentUserId ||
                  task.collaboratorIds.contains(currentUserId),
            )
            .toList();
    }
  }

  Future<void> _deleteTask(int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<TaskCubit>().deleteTask(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Add Task button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tasks', style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTaskPage(),
                      ),
                    );

                    if (result == true) {
                      _loadTasks();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Filter buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<TaskFilter>(
                    segments: const [
                      ButtonSegment<TaskFilter>(
                        value: TaskFilter.all,
                        label: Text('All'),
                      ),
                      ButtonSegment<TaskFilter>(
                        value: TaskFilter.created,
                        label: Text('Created'),
                      ),
                      ButtonSegment<TaskFilter>(
                        value: TaskFilter.mine,
                        label: Text('Mine'),
                      ),
                    ],
                    selected: {_currentFilter},
                    onSelectionChanged: (Set<TaskFilter> selection) {
                      setState(() {
                        _currentFilter = selection.first;
                      });
                      _loadTasks();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Task List
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading tasks',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTasks,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TaskLoaded) {
                  final filteredTasks = _filterTasks(state.tasks);

                  if (filteredTasks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create your first task to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.task_alt),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description != null) ...[
                                Text(task.description!),
                                const SizedBox(height: 4),
                              ],
                              if (task.startTime != null &&
                                  task.endTime != null) ...[
                                Text(
                                  'Duration: ${_getDuration(task.startTime!, task.endTime!)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Slot: ${_formatTimeSlot(task.startTime!, task.endTime!)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                              Text(
                                'Collaborators: ${task.collaboratorIds.length}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteTask(task.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('No data'));
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final minutes = duration.inMinutes;

    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  String _formatTimeSlot(DateTime start, DateTime end) {
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }
}
