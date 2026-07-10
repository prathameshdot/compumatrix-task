import 'package:flutter/material.dart';
import '../icons.dart';
import '../models/task.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils/date_utils.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final DateTime dueDate;
  const StatusBadge({super.key, required this.status, required this.dueDate});
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final isOverdue = status != TaskStatus.completed && AppDateUtils.isOverdue(dueDate);
    final icon = isOverdue
        ? AppIcons.overdue
        : switch (status) {
            TaskStatus.pending => AppIcons.pending,
            TaskStatus.inProgress => AppIcons.inProgress,
            TaskStatus.completed => AppIcons.checkCircle,
          };
    final label = isOverdue ? AppStrings.overdueLabel : status.label;
    if (status == TaskStatus.completed) {
      return _pill(
        background: onSurface,
        foreground: surface,
        icon: icon,
        label: label,
        bold: false,
      );
    }
    final weight = isOverdue ? 1.0 : (status == TaskStatus.inProgress ? 0.85 : 0.55);
    return _pill(
      background: onSurface.withValues(alpha: 0.08),
      foreground: onSurface.withValues(alpha: weight),
      icon: icon,
      label: label,
      bold: isOverdue,
    );
  }
  Widget _pill({
    required Color background,
    required Color foreground,
    required IconData icon,
    required String label,
    required bool bold,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption(foreground).copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              decoration: bold ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}
