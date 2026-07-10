import '../strings.dart';

abstract class Validators {
  Validators._();
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.emailRequired;
    if (!_emailRegex.hasMatch(trimmed)) return AppStrings.emailInvalid;
    return null;
  }
  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value != original) return AppStrings.passwordsDontMatch;
    return null;
  }
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.nameRequired;
    return null;
  }
  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
