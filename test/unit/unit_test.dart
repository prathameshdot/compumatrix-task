import 'package:flutter_test/flutter_test.dart';
import 'package:timer/models/task.dart';
import 'package:timer/utils/date_utils.dart';
import 'package:timer/utils/validators.dart';

void main() {
  TaskModel buildTask({TaskStatus status = TaskStatus.pending}) {
    return TaskModel(
      id: 't1',
      userId: 'u1',
      title: 'Write report',
      description: 'Quarterly report',
      status: status,
      dueDate: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 1),
    );
  }

  group('TaskModel', () {
    test('isCompleted reflects status', () {
      expect(buildTask().isCompleted, isFalse);
      expect(buildTask(status: TaskStatus.completed).isCompleted, isTrue);
    });

    test('copyWith only overrides provided fields', () {
      final original = buildTask();
      final updated = original.copyWith(title: 'Write final report');
      expect(updated.title, 'Write final report');
      expect(updated.description, original.description);
      expect(updated.status, original.status);
      expect(updated.dueDate, original.dueDate);
      expect(updated.id, original.id);
    });

    test('toMap/round trip preserves status name', () {
      final task = buildTask(status: TaskStatus.completed);
      expect(task.toMap()['status'], 'completed');
    });

    test('hasTimeWindow is false without both start and end time', () {
      expect(buildTask().hasTimeWindow, isFalse);
    });

    test('progress is null without a time window', () {
      expect(buildTask().progress, isNull);
    });

    test('progress is 0 before the window starts and clamps to 1 after it ends', () {
      final now = DateTime.now();
      final notStarted = buildTask().copyWith(
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      );
      expect(notStarted.progress, 0);
      final alreadyEnded = buildTask().copyWith(
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      expect(alreadyEnded.progress, 1);
    });

    test('copyWith clearStartTime/clearEndTime remove the time window', () {
      final now = DateTime.now();
      final withWindow = buildTask().copyWith(startTime: now, endTime: now.add(const Duration(hours: 1)));
      final cleared = withWindow.copyWith(clearStartTime: true, clearEndTime: true);
      expect(cleared.hasTimeWindow, isFalse);
    });
  });

  group('AppDateUtils.isOverdue', () {
    test('yesterday is overdue', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.isOverdue(yesterday), isTrue);
    });

    test('tomorrow is not overdue', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(AppDateUtils.isOverdue(tomorrow), isFalse);
    });
  });

  group('AppDateUtils.isToday', () {
    test('now is today', () {
      expect(AppDateUtils.isToday(DateTime.now()), isTrue);
    });

    test('next week is not today', () {
      expect(AppDateUtils.isToday(DateTime.now().add(const Duration(days: 7))), isFalse);
    });
  });

  group('AppDateUtils.isWithinNextDays', () {
    test('3 days from now is within the next 7 days', () {
      final date = DateTime.now().add(const Duration(days: 3));
      expect(AppDateUtils.isWithinNextDays(date, 7), isTrue);
    });

    test('10 days from now is not within the next 7 days', () {
      final date = DateTime.now().add(const Duration(days: 10));
      expect(AppDateUtils.isWithinNextDays(date, 7), isFalse);
    });
  });

  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejects malformed input', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty input', () {
      expect(Validators.password(''), isNotNull);
    });

    test('rejects passwords shorter than 6 characters', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('accepts a 6+ character password', () {
      expect(Validators.password('secret1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects mismatched values', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
    });

    test('accepts matching values', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });
}
