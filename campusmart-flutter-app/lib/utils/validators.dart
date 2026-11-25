/// Form rules. They mirror the backend rules, so mistakes are caught before a request is sent.
/// Each function returns an error message, or null when the value is fine.
class Validators {
  static String? fullName(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 2) return 'Enter your full name';
    if (text.length > 100) return 'Name is too long (100 characters at most)';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Accepts 07XXXXXXXX or 2567XXXXXXXX (spaces, + and dashes allowed), like the backend.
  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s\-+()]'), '');
    if (!RegExp(r'^(0\d{9}|256\d{9})$').hasMatch(digits)) {
      return 'Use 07XXXXXXXX or 2567XXXXXXXX';
    }
    return null;
  }

  static String? campus(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 2) return 'Enter your university or campus';
    if (text.length > 80) return 'Too long (80 characters at most)';
    return null;
  }

  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Use at least 8 characters';
    if (text.length > 72) return 'Use 72 characters at most';
    return null;
  }

  /// For the login screen, where the only rule is "not empty".
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  static String? Function(String?) sameAs(String Function() original) {
    return (value) => value == original() ? null : 'Passwords do not match';
  }
}
