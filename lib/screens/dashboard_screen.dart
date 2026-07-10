import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/day_timeline.dart';
import '../widgets/state_views.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_list_skeleton.dart';
import '../widgets/task_stats_row.dart';
import 'add_edit_task_screen.dart';
import 'calendar_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _searchExpanded = false;
  Future<void> _toggleComplete(TaskModel task) async {
    try {
      await ref.read(taskActionsProvider).toggleStatus(task);
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    }
  }
  void _toggleSearch() {
    setState(() => _searchExpanded = !_searchExpanded);
    if (!_searchExpanded) {
      ref.read(taskFiltersProvider.notifier).update((s) => s.copyWith(query: ''));
    }
  }
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final hasActiveFilters = ref.watch(taskFiltersProvider.select((f) => f.isActive));
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: AppLogo(size: 28, filled: false)),
        actions: [
          AppIconButton(
            tooltip: AppStrings.searchTasks,
            icon: _searchExpanded ? AppIcons.close : AppIcons.search,
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: AppSizes.sm),
        ],
      ),
      body: Column(
        children: [
          const TaskStatsRow(),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _searchExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm),
              child: Row(
                children: [
                  Expanded(child: TaskSearchField(autofocus: _searchExpanded)),
                  const SizedBox(width: AppSizes.sm),
                  Badge(
                    isLabelVisible: hasActiveFilters,
                    smallSize: 8,
                    child: AppIconButton(
                      tooltip: AppStrings.filters,
                      icon: AppIcons.filter,
                      onPressed: () => showTaskFilterSheet(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
            child: Row(
              children: [
                Expanded(child: Text('Plan your day', style: AppTextStyles.bodyStrong(onSurface))),
                AppIconButton(
                  size: 36,
                  tooltip: 'Calendar',
                  icon: AppIcons.calendarView,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  ),
                ),
              ],
            ),
          ),
          const DayTimeline(),
          const Divider(height: 1),
          Expanded(
            child: tasksAsync.when(
              loading: () => const TaskListSkeleton(),
              error: (error, _) => ErrorView(message: error.toString()),
              data: (tasks) {
                if (tasks.isEmpty) {
                  final hasFilters = ref.read(taskFiltersProvider).isActive;
                  return EmptyView(
                    icon: hasFilters ? AppIcons.noResults : AppIcons.emptyTasks,
                    title: AppStrings.noTasksFound,
                    subtitle: hasFilters ? AppStrings.noResultsSubtitle : AppStrings.noTasksSubtitle,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xxl),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: const Icon(AppIcons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: AppStrings.deleteTask,
                          message: AppStrings.deleteTaskConfirm,
                        );
                        return confirmed;
                      },
                      onDismissed: (_) async {
                        try {
                          await ref.read(taskActionsProvider).deleteTask(taskId: task.id);
                          if (context.mounted) AppSnackbar.showSuccess(context, AppStrings.taskDeleted);
                        } catch (e) {
                          if (context.mounted) AppSnackbar.showError(context, e.toString());
                        }
                      },
                      child: TaskCard(
                        task: task,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
                        ),
                        onToggleComplete: () => _toggleComplete(task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
