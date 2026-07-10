import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../icons.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../strings.dart';
import '../utils/date_utils.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';
import '../widgets/task_card.dart';
import '../widgets/task_list_skeleton.dart';
import 'add_edit_task_screen.dart';
import '../theme.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = AppDateUtils.startOfDay(DateTime.now());

  Future<void> _toggleComplete(TaskModel task) async {
    try {
      await ref.read(taskActionsProvider).toggleStatus(task);
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    final byDateAsync = ref.watch(tasksByDateProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<TaskModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => AppDateUtils.isSameDay(day, _selectedDay),
            eventLoader: (day) => byDateAsync.value?[AppDateUtils.startOfDay(day)] ?? const [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = AppDateUtils.startOfDay(selectedDay);
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
              weekendStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w700, fontSize: 16),
              leftChevronIcon: Icon(AppIcons.back, size: 18, color: onSurface),
              rightChevronIcon: Transform.rotate(angle: 3.1416, child: Icon(AppIcons.back, size: 18, color: onSurface)),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: onSurface),
              weekendTextStyle: TextStyle(color: onSurface),
              outsideTextStyle: TextStyle(color: onSurface.withValues(alpha: 0.3)),
              todayTextStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
              selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700),
              markerDecoration: BoxDecoration(color: onSurface, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: onSurface, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onSurface),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: byDateAsync.when(
              loading: () => const TaskListSkeleton(itemCount: 3),
              error: (error, _) => ErrorView(message: error.toString()),
              data: (byDate) {
                final selectedTasks = byDate[_selectedDay] ?? const <TaskModel>[];
                if (selectedTasks.isEmpty) {
                  return const EmptyView(
                    icon: AppIcons.emptyTasks,
                    title: AppStrings.noTasksFound,
                    subtitle: 'No tasks due on this day',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.xxl),
                  itemCount: selectedTasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final task = selectedTasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
                      ),
                      onToggleComplete: () => _toggleComplete(task),
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
