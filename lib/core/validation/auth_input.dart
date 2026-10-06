class AuthInput {
  const AuthInput._();

  static final RegExp emailPattern = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static const emptyLoginMessage = 'Please enter both email and password';
  static const invalidEmailMessage = 'Please enter a valid email address';
  static const emptyRegisterMessage = 'Please fill in all fields';
  static const shortPasswordMessage = 'Password must be at least 6 characters';
  static const passwordMismatchMessage = 'Passwords do not match';

  static String? loginIssue({required String email, required String password}) {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return emptyLoginMessage;
    }
    if (!emailPattern.hasMatch(trimmedEmail)) {
      return invalidEmailMessage;
    }
    return null;
  }

  static String? registerIssue({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedConfirm = confirmPassword.trim();
    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty ||
        trimmedConfirm.isEmpty) {
      return emptyRegisterMessage;
    }
    if (!emailPattern.hasMatch(trimmedEmail)) {
      return invalidEmailMessage;
    }
    if (trimmedPassword.length < 6) {
      return shortPasswordMessage;
    }
    if (trimmedPassword != trimmedConfirm) {
      return passwordMismatchMessage;
    }
    return null;
  }
}
