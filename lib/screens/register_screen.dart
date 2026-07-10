import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../icons.dart';
import '../services/auth_service.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils/validators.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(authControllerProvider).error;
      AppSnackbar.showError(context, error?.toString() ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AppLogo(size: 64),
                    const SizedBox(height: AppSizes.lg),
                    Text(AppStrings.createAccount, style: AppTextStyles.headline(colorScheme.onSurface)),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      AppStrings.registerSubtitle,
                      style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    AppTextField(
                      controller: _nameController,
                      label: AppStrings.fullName,
                      prefixIcon: AppIcons.person,
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSizes.md),
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
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? AppIcons.showPassword : AppIcons.hidePassword),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      prefixIcon: AppIcons.password,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? AppIcons.showPassword : AppIcons.hidePassword),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    PrimaryButton(
                      label: AppStrings.signUp,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppTextStyles.body(colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.of(context).pop(),
                          child: Text(
                            AppStrings.signIn,
                            style: AppTextStyles.bodyStrong(colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
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
