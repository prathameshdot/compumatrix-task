import 'task.dart';

enum DueDateFilter { any, today, thisWeek, overdue }

class TaskFilters {
  final String query;
  final TaskStatus? status;
  final DueDateFilter dueDate;
  const TaskFilters({
    this.query = '',
    this.status,
    this.dueDate = DueDateFilter.any,
  });
  bool get isActive => query.isNotEmpty || status != null || dueDate != DueDateFilter.any;
  TaskFilters copyWith({
    String? query,
    TaskStatus? status,
    bool clearStatus = false,
    DueDateFilter? dueDate,
  }) {
    return TaskFilters(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
