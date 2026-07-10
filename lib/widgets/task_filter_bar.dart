import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../models/task.dart';
import '../models/task_filters.dart';
import '../services/task_service.dart';
import '../strings.dart';
import '../theme.dart';

class TaskSearchField extends ConsumerStatefulWidget {
  final bool autofocus;
  const TaskSearchField({super.key, this.autofocus = false});
  @override
  ConsumerState<TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends ConsumerState<TaskSearchField> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(taskFiltersProvider).query);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = ref.watch(taskFiltersProvider.select((f) => f.query));
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: (value) {
        ref.read(taskFiltersProvider.notifier).update((state) => state.copyWith(query: value));
      },
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: AppStrings.searchTasks,
        prefixIcon: const Icon(AppIcons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(AppIcons.clear),
                onPressed: () {
                  _controller.clear();
                  ref.read(taskFiltersProvider.notifier).update((state) => state.copyWith(query: ''));
                },
              )
            : null,
      ),
    );
  }
}

class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(taskFiltersProvider);
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(AppStrings.filterByStatus, style: AppTextStyles.overline(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(width: AppSizes.xs),
        _StatusChip(label: AppStrings.all, selected: filters.status == null, onSelected: () {
          ref.read(taskFiltersProvider.notifier).update((s) => s.copyWith(clearStatus: true));
        }),
        _StatusChip(
          label: AppStrings.pendingLabel,
          selected: filters.status == TaskStatus.pending,
          onSelected: () => ref.read(taskFiltersProvider.notifier).update(
                (s) => s.copyWith(status: TaskStatus.pending),
              ),
        ),
        _StatusChip(
          label: AppStrings.inProgressLabel,
          selected: filters.status == TaskStatus.inProgress,
          onSelected: () => ref.read(taskFiltersProvider.notifier).update(
                (s) => s.copyWith(status: TaskStatus.inProgress),
              ),
        ),
        _StatusChip(
          label: AppStrings.completedLabel,
          selected: filters.status == TaskStatus.completed,
          onSelected: () => ref.read(taskFiltersProvider.notifier).update(
                (s) => s.copyWith(status: TaskStatus.completed),
              ),
        ),
        const SizedBox(width: AppSizes.md),
        Text(AppStrings.filterByDueDate, style: AppTextStyles.overline(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(width: AppSizes.xs),
        _DueDateChip(label: AppStrings.anyDate, value: DueDateFilter.any, current: filters.dueDate),
        _DueDateChip(label: AppStrings.today, value: DueDateFilter.today, current: filters.dueDate),
        _DueDateChip(label: AppStrings.thisWeek, value: DueDateFilter.thisWeek, current: filters.dueDate),
        _DueDateChip(label: AppStrings.overdueLabel, value: DueDateFilter.overdue, current: filters.dueDate),
        if (filters.isActive)
          TextButton(
            onPressed: () => ref.read(taskFiltersProvider.notifier).state = const TaskFilters(),
            child: Text(
              AppStrings.clearFilters,
              style: AppTextStyles.caption(Theme.of(context).colorScheme.onSurface).copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
      ],
    );
  }
}

Future<void> showTaskFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.filters, style: AppTextStyles.title(Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSizes.md),
            const TaskFilterBar(),
          ],
        ),
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _StatusChip({required this.label, required this.selected, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _DueDateChip extends ConsumerWidget {
  final String label;
  final DueDateFilter value;
  final DueDateFilter current;
  const _DueDateChip({required this.label, required this.value, required this.current});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      onSelected: (_) => ref.read(taskFiltersProvider.notifier).update((s) => s.copyWith(dueDate: value)),
    );
  }
}
