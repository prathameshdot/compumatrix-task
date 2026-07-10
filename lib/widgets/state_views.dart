import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme.dart';

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: AppSizes.md),
            Text(title, style: AppTextStyles.title(colorScheme.onSurface), textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.xs),
            Text(
              subtitle,
              style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: colorScheme.onSurface),
            const SizedBox(height: AppSizes.md),
            Text(
              AppStrings.somethingWentWrong,
              style: AppTextStyles.title(colorScheme.onSurface),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              message,
              style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.md),
              OutlinedButton(onPressed: onRetry, child: const Text(AppStrings.tryAgain)),
            ],
          ],
        ),
      ),
    );
  }
}
