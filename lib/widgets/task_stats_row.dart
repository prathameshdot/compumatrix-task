import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../services/task_service.dart';
import '../strings.dart';
import '../theme.dart';

class TaskStatsRow extends ConsumerWidget {
  const TaskStatsRow({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(taskStatsProvider).value;
    if (stats == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
      child: Column(
        children: [
          _StatTile(
            icon: AppIcons.pending,
            count: stats.pending,
            label: AppStrings.pendingLabel,
            emphasize: true,
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(child: _StatTile(icon: AppIcons.checkCircle, count: stats.completed, label: AppStrings.completedLabel)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: _StatTile(icon: AppIcons.inProgress, count: stats.inProgress, label: AppStrings.inProgressLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final bool emphasize;
  const _StatTile({required this.icon, required this.count, required this.label, this.emphasize = false});
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final background = emphasize ? onSurface : Colors.transparent;
    final foreground = emphasize ? Theme.of(context).colorScheme.surface : onSurface;
    return Card(
      margin: EdgeInsets.zero,
      color: background,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: emphasize ? AppSizes.md : AppSizes.sm, horizontal: AppSizes.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconSm, color: foreground),
            const SizedBox(width: AppSizes.xs),
            Text('$count', style: AppTextStyles.title(foreground)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption(foreground.withValues(alpha: emphasize ? 0.85 : 0.6)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
