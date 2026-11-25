/// A user as returned by the API (GET /auth/me and the `user` part of POST /auth/login).
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.campus,
    required this.role,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String campus;
  final String role;

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      campus: json['campus'] as String,
      role: json['role'] as String,
    );
  }
}
