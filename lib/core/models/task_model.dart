class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String createdBy;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final List<String> collaboratorIds;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.collaboratorIds = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      collaboratorIds:
          (json['collaborator_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'collaborator_ids': collaboratorIds,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    List<String>? collaboratorIds,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
    );
  }
}
