import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../theme.dart';
import '../utils/date_utils.dart';

class DayTimeline extends ConsumerStatefulWidget {
  const DayTimeline({super.key});
  @override
  ConsumerState<DayTimeline> createState() => _DayTimelineState();
}

class _DayTimelineState extends ConsumerState<DayTimeline> {
  late final Timer _ticker;
  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayTimelineProvider);
    final tasks = tasksAsync.value;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (tasks == null || tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
        child: Text(
          'No time-blocked tasks today — add a start/end time when creating a task to see it here.',
          style: AppTextStyles.caption(onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tasks.length; i++)
            _TimelineEntry(task: tasks[i], isLast: i == tasks.length - 1),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final TaskModel task;
  final bool isLast;
  const _TimelineEntry({required this.task, required this.isLast});
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final progress = task.progress ?? (task.isCompleted ? 1.0 : 0.0);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? onSurface : Colors.transparent,
                  border: Border.all(color: onSurface, width: 1.5),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 1.5, color: onSurface.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppDateUtils.formatTime(task.startTime!)} – ${AppDateUtils.formatTime(task.endTime!)}',
                    style: AppTextStyles.caption(onSurface.withValues(alpha: 0.55)),
                  ),
                  Text(
                    task.title,
                    style: AppTextStyles.body(onSurface).copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: onSurface.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(onSurface.withValues(alpha: 0.25 + (progress * 0.75))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
