import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../models/task_filters.dart';
import '../utils/app_exception.dart';
import '../utils/date_utils.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'user_service.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  TaskRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _tasks => _firestore.collection('tasks');
  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasks.where('userId', isEqualTo: uid).snapshots().map(
          (snapshot) => snapshot.docs.map(TaskModel.fromDoc).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
        );
  }

  Future<TaskModel> createTask({
    required String uid,
    required String title,
    required String description,
    required DateTime dueDate,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = _tasks.doc();
      final task = TaskModel(
        id: docRef.id,
        userId: uid,
        title: title.trim(),
        description: description.trim(),
        status: TaskStatus.pending,
        dueDate: dueDate,
        createdAt: now,
        startTime: startTime,
        endTime: endTime,
      );
      await docRef.set(task.toMap());
      return task;
    } catch (e) {
      throw const AppException('Could not create the task. Please try again.');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasks.doc(task.id).update(task.toMap());
    } catch (e) {
      throw const AppException('Could not update the task. Please try again.');
    }
  }

  Future<void> toggleStatus(TaskModel task) async {
    final newStatus = task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    try {
      await _tasks.doc(task.id).update({'status': newStatus.name});
    } catch (e) {
      throw const AppException('Could not update the task status. Please try again.');
    }
  }
  Future<void> deleteTask({required String taskId}) async {
    try {
      await _tasks.doc(taskId).delete();
    } catch (e) {
      throw const AppException('Could not delete the task. Please try again.');
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).watchTasks(user.uid);
});
final taskFiltersProvider = StateProvider<TaskFilters>((ref) => const TaskFilters());
final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final filters = ref.watch(taskFiltersProvider);
  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      if (filters.query.isNotEmpty &&
          !task.title.toLowerCase().contains(filters.query.toLowerCase())) {
        return false;
      }
      if (filters.status != null && task.status != filters.status) {
        return false;
      }
      switch (filters.dueDate) {
        case DueDateFilter.any:
          break;
        case DueDateFilter.today:
          if (!AppDateUtils.isToday(task.dueDate)) return false;
          break;
        case DueDateFilter.thisWeek:
          if (!AppDateUtils.isWithinNextDays(task.dueDate, 7)) return false;
          break;
        case DueDateFilter.overdue:
          if (!(AppDateUtils.isOverdue(task.dueDate) && !task.isCompleted)) return false;
          break;
      }
      return true;
    }).toList();
  });
});
final tasksByDateProvider = Provider<AsyncValue<Map<DateTime, List<TaskModel>>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  return tasksAsync.whenData((tasks) {
    final byDate = <DateTime, List<TaskModel>>{};
    for (final task in tasks) {
      final day = AppDateUtils.startOfDay(task.dueDate);
      byDate.putIfAbsent(day, () => []).add(task);
    }
    return byDate;
  });
});
final todayTimelineProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  return tasksAsync.whenData((tasks) {
    final today = tasks.where((task) => task.hasTimeWindow && AppDateUtils.isToday(task.dueDate)).toList()
      ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    return today;
  });
});
class TaskStats {
  final int pending;
  final int inProgress;
  final int completed;
  const TaskStats({required this.pending, required this.inProgress, required this.completed});
}
final taskStatsProvider = Provider<AsyncValue<TaskStats>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  return tasksAsync.whenData((tasks) {
    var pending = 0;
    var inProgress = 0;
    var completed = 0;
    for (final task in tasks) {
      switch (task.status) {
        case TaskStatus.pending:
          pending++;
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.completed:
          completed++;
      }
    }
    return TaskStats(pending: pending, inProgress: inProgress, completed: completed);
  });
});
class TaskActions {
  final TaskRepository _repository;
  final NotificationService _notifications;
  final Ref _ref;
  TaskActions(this._repository, this._notifications, this._ref);
  Future<void> _maybeScheduleReminder(TaskModel task) async {
    final profile = _ref.read(currentUserProfileProvider).value;
    if (profile != null && !profile.dueReminderEnabled) return;
    final leadMinutes = profile?.reminderLeadMinutes ?? 0;
    await _notifications.scheduleTaskDueReminder(
      taskId: task.id,
      title: task.title,
      dueDate: task.dueDate.subtract(Duration(minutes: leadMinutes)),
    );
  }
  Future<void> createTask({
    required String uid,
    required String title,
    required String description,
    required DateTime dueDate,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final task = await _repository.createTask(
      uid: uid,
      title: title,
      description: description,
      dueDate: dueDate,
      startTime: startTime,
      endTime: endTime,
    );
    await _maybeScheduleReminder(task);
  }
  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    await _notifications.cancelReminder(task.id);
    if (!task.isCompleted) {
      await _maybeScheduleReminder(task);
    }
  }
  Future<void> toggleStatus(TaskModel task) async {
    await _repository.toggleStatus(task);
    if (!task.isCompleted) {
      await _notifications.showTaskCompleted(task.id, task.title);
      await _notifications.cancelReminder(task.id);
    } else {
      await _maybeScheduleReminder(task);
    }
  }
  Future<void> deleteTask({required String taskId}) async {
    await _repository.deleteTask(taskId: taskId);
    await _notifications.cancelReminder(taskId);
  }
}
final taskActionsProvider = Provider<TaskActions>((ref) {
  return TaskActions(ref.watch(taskRepositoryProvider), NotificationService.instance, ref);
});
