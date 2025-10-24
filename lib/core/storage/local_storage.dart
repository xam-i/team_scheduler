import '../models/user_model.dart';
import '../models/availability_model.dart';
import '../models/task_model.dart';

class AppLocalStorage {
  static final AppLocalStorage _instance = AppLocalStorage._internal();
  factory AppLocalStorage() => _instance;
  AppLocalStorage._internal();

  final List<UserModel> _users = [];
  final List<AvailabilityModel> _availabilities = [];
  final List<TaskModel> _tasks = [];

  // Initialize with some demo data
  void initializeDemoData() {
    if (_users.isEmpty) {
      _users.addAll([
        UserModel(
          id: 'demo_user_1',
          name: 'Alice Johnson',
          photoUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        UserModel(
          id: 'demo_user_2',
          name: 'Bob Smith',
          photoUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        UserModel(
          id: 'demo_user_3',
          name: 'Carol Davis',
          photoUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);
    }
  }

  // User methods
  void addUser(UserModel user) {
    _users.add(user);
  }

  List<UserModel> getAllUsers() {
    return List.from(_users);
  }

  UserModel? getCurrentUser() {
    return _users.isNotEmpty ? _users.first : null;
  }

  // Availability methods
  void addAvailability(AvailabilityModel availability) {
    _availabilities.add(availability);
  }

  List<AvailabilityModel> getUserAvailability(String userId) {
    return _availabilities.where((a) => a.userId == userId).toList();
  }

  List<AvailabilityModel> getMultipleUsersAvailability(List<String> userIds) {
    return _availabilities.where((a) => userIds.contains(a.userId)).toList();
  }

  void deleteAvailability(int id) {
    _availabilities.removeWhere((a) => a.id == id);
  }

  // Task methods
  void addTask(TaskModel task) {
    _tasks.add(task);
  }

  List<TaskModel> getAllTasks() {
    return List.from(_tasks);
  }

  List<TaskModel> getUserTasks(String userId) {
    return _tasks
        .where(
          (t) => t.createdBy == userId || t.collaboratorIds.contains(userId),
        )
        .toList();
  }

  void deleteTask(int taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
  }
}
