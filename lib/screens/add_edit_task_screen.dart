import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../utils/validators.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});
  bool get isEditing => task != null;
  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  DateTime? _startTime;
  DateTime? _endTime;
  late TaskStatus _status;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _startTime = task?.startTime;
    _endTime = task?.endTime;
    _status = task?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showAppDateTimePicker(
      context,
      initialDateTime: _dueDate ?? DateTime.now(),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickStartTime() async {
    final anchor = _dueDate ?? DateTime.now();
    final initial = _startTime ?? DateTime(anchor.year, anchor.month, anchor.day, 9);
    final picked = await showAppDateTimePicker(
      context,
      initialDateTime: initial,
      mode: CupertinoDatePickerMode.time,
    );
    if (picked == null) return;
    setState(() => _startTime = DateTime(anchor.year, anchor.month, anchor.day, picked.hour, picked.minute));
  }

  Future<void> _pickEndTime() async {
    final anchor = _dueDate ?? DateTime.now();
    final initial = _endTime ?? DateTime(anchor.year, anchor.month, anchor.day, 10);
    final picked = await showAppDateTimePicker(
      context,
      initialDateTime: initial,
      mode: CupertinoDatePickerMode.time,
    );
    if (picked == null) return;
    setState(() => _endTime = DateTime(anchor.year, anchor.month, anchor.day, picked.hour, picked.minute));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      AppSnackbar.showError(context, AppStrings.dueDateRequired);
      return;
    }
    if (_startTime != null && _endTime != null && !_endTime!.isAfter(_startTime!)) {
      AppSnackbar.showError(context, 'End time must be after the start time.');
      return;
    }

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      AppSnackbar.showError(context, 'You\'re signed out. Please sign in again and retry.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          status: _status,
          dueDate: _dueDate,
          startTime: _startTime,
          endTime: _endTime,
          clearStartTime: _startTime == null,
          clearEndTime: _endTime == null,
        );
        await ref.read(taskActionsProvider).updateTask(updated);
        if (mounted) AppSnackbar.showSuccess(context, AppStrings.taskUpdated);
      } else {
        await ref.read(taskActionsProvider).createTask(
              uid: user.uid,
              title: _titleController.text,
              description: _descriptionController.text,
              dueDate: _dueDate!,
              startTime: _startTime,
              endTime: _endTime,
            );
        if (mounted) AppSnackbar.showSuccess(context, AppStrings.taskCreated);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.isEditing ? AppStrings.editTask : AppStrings.addTask),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _titleController,
                  label: AppStrings.taskTitle,
                  prefixIcon: AppIcons.title,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, AppStrings.titleRequired),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _descriptionController,
                  label: AppStrings.taskDescription,
                  prefixIcon: AppIcons.description,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: AppSizes.md),
                _PickerField(
                  label: AppStrings.dueDate,
                  icon: AppIcons.calendar,
                  value: _dueDate == null ? AppStrings.pickDueDate : AppDateUtils.formatDayTime(_dueDate!),
                  isPlaceholder: _dueDate == null,
                  onTap: _pickDueDate,
                ),
                const SizedBox(height: AppSizes.md),
                Text('Time block (optional)', style: AppTextStyles.bodyStrong(colorScheme.onSurface)),
                const SizedBox(height: AppSizes.xs),
                Text(
                  "Schedule this task to a slot on its due date — that's what "
                  "drives the countdown ring on the dashboard.",
                  style: AppTextStyles.caption(colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: 'Start',
                        icon: AppIcons.clock,
                        value: _startTime == null ? '--:--' : AppDateUtils.formatTime(_startTime!),
                        isPlaceholder: _startTime == null,
                        onTap: _pickStartTime,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _PickerField(
                        label: 'End',
                        icon: AppIcons.clock,
                        value: _endTime == null ? '--:--' : AppDateUtils.formatTime(_endTime!),
                        isPlaceholder: _endTime == null,
                        onTap: _pickEndTime,
                      ),
                    ),
                  ],
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(AppStrings.status, style: AppTextStyles.bodyStrong(colorScheme.onSurface)),
                  const SizedBox(height: AppSizes.xs),
                  SegmentedButton<TaskStatus>(
                    segments: const [
                      ButtonSegment(
                        value: TaskStatus.pending,
                        label: Text(AppStrings.pendingLabel),
                        icon: Icon(AppIcons.pending),
                      ),
                      ButtonSegment(
                        value: TaskStatus.inProgress,
                        label: Text(AppStrings.inProgressLabel),
                        icon: Icon(AppIcons.inProgress),
                      ),
                      ButtonSegment(
                        value: TaskStatus.completed,
                        label: Text(AppStrings.completedLabel),
                        icon: Icon(AppIcons.checkCircle),
                      ),
                    ],
                    selected: {_status},
                    onSelectionChanged: (selection) => setState(() => _status = selection.first),
                  ),
                ],
                const SizedBox(height: AppSizes.xl),
                PrimaryButton(
                  label: widget.isEditing ? AppStrings.updateTask : AppStrings.saveTask,
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(
          value,
          style: AppTextStyles.body(isPlaceholder ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface),
        ),
      ),
    );
  }
}
