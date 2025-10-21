class AvailabilityModel {
  final int id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  AvailabilityModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  AvailabilityModel copyWith({
    int? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
