import 'package:flutter/material.dart';
import '../icons.dart';
import '../models/task.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.isCompleted;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggleComplete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: AppSizes.sm),
                  child: Icon(
                    isCompleted ? AppIcons.checkCircle : AppIcons.radioUnchecked,
                    color: isCompleted ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.35),
                    size: AppSizes.iconMd,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyStrong(colorScheme.onSurface).copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        StatusBadge(status: task.status, dueDate: task.dueDate),
                        const SizedBox(width: AppSizes.sm),
                        Icon(AppIcons.calendar, size: 13, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatDay(task.dueDate),
                          style: AppTextStyles.caption(colorScheme.onSurface.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
