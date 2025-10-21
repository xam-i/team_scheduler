class TaskCollaboratorModel {
  final int id;
  final int taskId;
  final String userId;

  TaskCollaboratorModel({
    required this.id,
    required this.taskId,
    required this.userId,
  });

  factory TaskCollaboratorModel.fromJson(Map<String, dynamic> json) {
    return TaskCollaboratorModel(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'task_id': taskId, 'user_id': userId};
  }

  TaskCollaboratorModel copyWith({int? id, int? taskId, String? userId}) {
    return TaskCollaboratorModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
    );
  }
}
