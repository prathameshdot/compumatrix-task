import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/state_views.dart';

const List<int> _leadTimeOptions = [0, 5, 15, 30, 60];
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  Future<void> _editName(BuildContext context, WidgetRef ref, UserModel profile) async {
    final controller = TextEditingController(text: profile.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editName),
        content: AppTextField(controller: controller, label: AppStrings.yourName, prefixIcon: AppIcons.person),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || !context.mounted) return;
    try {
      await ref.read(userRepositoryProvider).updateDisplayName(profile.uid, newName);
      if (context.mounted) AppSnackbar.showSuccess(context, AppStrings.nameUpdated);
    } catch (e) {
      if (context.mounted) AppSnackbar.showError(context, e.toString());
    }
  }

  Future<void> _updatePref(BuildContext context, WidgetRef ref, String uid, String key, Object value) async {
    try {
      await ref.read(userRepositoryProvider).updatePrefs(uid, {key: value});
      if (context.mounted) AppSnackbar.showSuccess(context, AppStrings.prefsUpdated);
    } catch (e) {
      if (context.mounted) AppSnackbar.showError(context, e.toString());
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.signOutConfirmTitle,
      message: AppStrings.signOutConfirmMessage,
      confirmLabel: AppStrings.logout,
    );
    if (confirmed) await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (profile) {
          if (profile == null) return const ProfileSkeleton();
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                      child: Icon(AppIcons.person, size: 40, color: colorScheme.primary),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      profile.displayName.isEmpty ? profile.email : profile.displayName,
                      style: AppTextStyles.title(colorScheme.onSurface),
                    ),
                    Text(profile.email, style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6))),
                    TextButton(
                      onPressed: () => _editName(context, ref, profile),
                      child: const Text(AppStrings.editName),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(AppStrings.appearance, style: AppTextStyles.bodyStrong(colorScheme.onSurface)),
              const SizedBox(height: AppSizes.sm),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.themeLight), icon: Icon(AppIcons.lightMode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.themeDark), icon: Icon(AppIcons.darkMode)),
                  ButtonSegment(value: ThemeMode.system, label: Text(AppStrings.themeSystem)),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) => ref.read(themeModeProvider.notifier).set(selection.first),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(AppStrings.notificationPreferences, style: AppTextStyles.bodyStrong(colorScheme.onSurface)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.dueReminders),
                subtitle: const Text(AppStrings.dueRemindersSubtitle),
                value: profile.dueReminderEnabled,
                onChanged: (value) => _updatePref(context, ref, profile.uid, 'dueReminderEnabled', value),
              ),
              if (profile.dueReminderEnabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      Expanded(child: Text(AppStrings.reminderLeadTime, style: AppTextStyles.body(colorScheme.onSurface))),
                      DropdownButton<int>(
                        value: profile.reminderLeadMinutes,
                        items: _leadTimeOptions
                            .map((m) => DropdownMenuItem(value: m, child: Text(m == 0 ? 'At due time' : '$m min')))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _updatePref(context, ref, profile.uid, 'reminderLeadMinutes', value);
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSizes.lg),
              PrimaryButton(
                label: AppStrings.logout,
                icon: AppIcons.logout,
                onPressed: () => _signOut(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }
}
