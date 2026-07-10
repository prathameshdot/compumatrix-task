import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../services/auth_service.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AppLogo(size: 72),
                    const SizedBox(height: AppSizes.lg),
                    Text(AppStrings.welcomeBack, style: AppTextStyles.headline(colorScheme.onSurface)),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      AppStrings.loginSubtitle,
                      style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const _FeatureRow(),
                    const SizedBox(height: AppSizes.xl),
                    AppTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      prefixIcon: AppIcons.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? AppIcons.showPassword : AppIcons.hidePassword),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    PrimaryButton(
                      label: AppStrings.signIn,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  ),
                          child: Text(
                            AppStrings.signUp,
                            style: AppTextStyles.bodyStrong(colorScheme.primary).copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(child: _Feature(icon: AppIcons.calendar, label: AppStrings.featurePlan, subtitle: AppStrings.featurePlanSubtitle, color: onSurface)),
        Expanded(child: _Feature(icon: AppIcons.clock, label: AppStrings.featureTrack, subtitle: AppStrings.featureTrackSubtitle, color: onSurface)),
        Expanded(child: _Feature(icon: AppIcons.checkCircle, label: AppStrings.featureFinish, subtitle: AppStrings.featureFinishSubtitle, color: onSurface)),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _Feature({required this.icon, required this.label, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(label, style: AppTextStyles.caption(color).copyWith(fontWeight: FontWeight.w700)),
        Text(subtitle, style: AppTextStyles.caption(color.withValues(alpha: 0.55)), textAlign: TextAlign.center),
      ],
    );
  }
}
