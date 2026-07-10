import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../strings.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed;
  String get label => switch (this) {
        TaskStatus.pending => AppStrings.pendingLabel,
        TaskStatus.inProgress => AppStrings.inProgressLabel,
        TaskStatus.completed => AppStrings.completedLabel,
      };
  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

class TaskModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.startTime,
    this.endTime,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get hasTimeWindow => startTime != null && endTime != null;
  double? get progress {
    if (startTime == null || endTime == null) return null;
    final total = endTime!.difference(startTime!).inSeconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(startTime!).inSeconds;
    return (elapsed / total).clamp(0, 1).toDouble();
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? startTime,
    DateTime? endTime,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: TaskStatus.fromString(data['status'] as String? ?? 'pending'),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'startTime': startTime == null ? null : Timestamp.fromDate(startTime!),
      'endTime': endTime == null ? null : Timestamp.fromDate(endTime!),
    };
  }

  @override
  List<Object?> get props =>
      [id, userId, title, description, status, dueDate, createdAt, startTime, endTime];
}
